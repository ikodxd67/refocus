import 'dart:math' as math;

import '../analytics/models.dart';

/// Everything known at the moment the pause is about to start — i.e. right
/// after the user taps their intention, and before they decide what to do.
///
/// Nothing in here may depend on the outcome; that is what keeps training
/// honest.
class PauseContext {
  final DateTime timestamp;
  final String reason;
  final int opensBefore;
  final int? minutesSinceLastOpen;

  /// Share of recent pauses the user pushed through, computed from history
  /// strictly before this moment.
  final double recentRelapseRate;

  const PauseContext({
    required this.timestamp,
    required this.reason,
    required this.opensBefore,
    required this.minutesSinceLastOpen,
    required this.recentRelapseRate,
  });
}

/// One weighted reason the model gave the score it gave.
class FeatureContribution {
  final String feature;
  final String label;
  final double contribution; // w_i * x_i, signed

  const FeatureContribution({
    required this.feature,
    required this.label,
    required this.contribution,
  });
}

/// On-device logistic regression predicting P(the user opens the app anyway).
///
/// Deliberately a linear model rather than a neural net: it trains usefully on
/// the few hundred events one person generates, runs in microseconds, needs no
/// runtime, and — most importantly — every prediction can be explained back to
/// the user as a list of weighted reasons.
class RiskModel {
  /// Below this many observations the model abstains instead of guessing.
  static const minObservations = 15;

  static const featureNames = <String>[
    'bias',
    'hour_sin',
    'hour_cos',
    'late_night',
    'weekend',
    'opens_before',
    'short_gap',
    'recent_relapse',
    'reason_bored',
    'reason_habit',
    'reason_quickBreak',
    'reason_specific',
  ];

  static const featureLabels = <String, String>{
    'bias': 'Baseline',
    'hour_sin': 'Time of day',
    'hour_cos': 'Time of day',
    'late_night': 'Late night',
    'weekend': 'Weekend',
    'opens_before': 'Opens already today',
    'short_gap': 'Reopened quickly',
    'recent_relapse': 'Recent slips',
    'reason_bored': 'Reason: bored',
    'reason_habit': 'Reason: habit',
    'reason_quickBreak': 'Reason: a break',
    'reason_specific': 'Reason: something specific',
  };

  final Map<String, double> weights;
  final int trainedOn;

  const RiskModel({required this.weights, required this.trainedOn});

  factory RiskModel.untrained() => RiskModel(
        weights: {for (final f in featureNames) f: 0.0},
        trainedOn: 0,
      );

  bool get isReady => trainedOn >= minObservations;

  // ---------------------------------------------------------------------------
  // Features
  // ---------------------------------------------------------------------------

  /// Maps a context onto the feature vector. Values are kept in roughly
  /// [-1, 1] so a single learning rate works for all of them.
  static Map<String, double> features(PauseContext c) {
    final hour = c.timestamp.hour + c.timestamp.minute / 60.0;
    final angle = 2 * math.pi * hour / 24.0;
    final gap = c.minutesSinceLastOpen;

    return {
      'bias': 1.0,
      // Cyclical encoding, so 23:00 and 01:00 are near neighbours.
      'hour_sin': math.sin(angle),
      'hour_cos': math.cos(angle),
      'late_night': (c.timestamp.hour >= 22 || c.timestamp.hour < 4) ? 1.0 : 0.0,
      'weekend': c.timestamp.weekday >= 6 ? 1.0 : 0.0,
      'opens_before': math.min(c.opensBefore, 10) / 10.0,
      // 1.0 when they came straight back, decaying to 0 after two hours.
      'short_gap':
          gap == null ? 0.0 : 1.0 - math.min(gap, 120) / 120.0,
      'recent_relapse': c.recentRelapseRate,
      'reason_bored': c.reason == 'bored' ? 1.0 : 0.0,
      'reason_habit': c.reason == 'habit' ? 1.0 : 0.0,
      'reason_quickBreak': c.reason == 'quickBreak' ? 1.0 : 0.0,
      'reason_specific': c.reason == 'specific' ? 1.0 : 0.0,
    };
  }

  // ---------------------------------------------------------------------------
  // Inference
  // ---------------------------------------------------------------------------

  /// P(user opens the app anyway), in [0, 1].
  double predict(PauseContext context) => _predictRaw(features(context));

  double _predictRaw(Map<String, double> x) {
    var z = 0.0;
    for (final entry in x.entries) {
      z += (weights[entry.key] ?? 0.0) * entry.value;
    }
    return _sigmoid(z);
  }

  /// The strongest signed reasons behind a prediction, biggest effect first.
  /// `bias` is excluded — it explains nothing about *this* moment.
  List<FeatureContribution> explain(PauseContext context, {int take = 4}) {
    final x = features(context);
    final out = <FeatureContribution>[];
    for (final entry in x.entries) {
      if (entry.key == 'bias') continue;
      final c = (weights[entry.key] ?? 0.0) * entry.value;
      if (c.abs() < 1e-6) continue;
      out.add(FeatureContribution(
        feature: entry.key,
        label: featureLabels[entry.key] ?? entry.key,
        contribution: c,
      ));
    }
    out.sort((a, b) => b.contribution.abs().compareTo(a.contribution.abs()));
    return out.take(take).toList();
  }

  // ---------------------------------------------------------------------------
  // Training
  // ---------------------------------------------------------------------------

  /// One gradient step on a single observation — used to keep learning as the
  /// user goes, without retraining from scratch every time.
  RiskModel updatedWith(
    PauseContext context,
    bool openedAnyway, {
    double learningRate = 0.05,
    double l2 = 1e-4,
  }) {
    final x = features(context);
    final p = _predictRaw(x);
    final error = p - (openedAnyway ? 1.0 : 0.0);

    final next = Map<String, double>.from(weights);
    for (final entry in x.entries) {
      final w = next[entry.key] ?? 0.0;
      final penalty = entry.key == 'bias' ? 0.0 : l2 * w;
      next[entry.key] = w - learningRate * (error * entry.value + penalty);
    }
    return RiskModel(weights: next, trainedOn: trainedOn + 1);
  }

  /// Batch training over the whole event log.
  ///
  /// Records must be in chronological order; features for each record are
  /// derived only from the records before it, so there is no leakage of future
  /// outcomes into the inputs.
  static RiskModel train(
    List<PauseRecord> records, {
    int epochs = 25,
    double learningRate = 0.08,
    double l2 = 1e-4,
  }) {
    final samples = buildSamples(records);
    if (samples.isEmpty) return RiskModel.untrained();

    var weights = {for (final f in featureNames) f: 0.0};

    for (var epoch = 0; epoch < epochs; epoch++) {
      for (final s in samples) {
        var z = 0.0;
        for (final e in s.x.entries) {
          z += (weights[e.key] ?? 0.0) * e.value;
        }
        final error = _sigmoid(z) - s.y;
        for (final e in s.x.entries) {
          final w = weights[e.key] ?? 0.0;
          final penalty = e.key == 'bias' ? 0.0 : l2 * w;
          weights[e.key] = w - learningRate * (error * e.value + penalty);
        }
      }
    }

    return RiskModel(weights: weights, trainedOn: samples.length);
  }

  /// Converts the raw event log into training rows, computing the rolling
  /// relapse rate causally as it walks forward through time.
  static List<TrainingSample> buildSamples(
    List<PauseRecord> records, {
    int relapseWindow = 10,
  }) {
    final samples = <TrainingSample>[];
    final recentOutcomes = <double>[]; // 1.0 = pushed through

    for (final r in records) {
      final rate = recentOutcomes.isEmpty
          ? 0.0
          : recentOutcomes.reduce((a, b) => a + b) / recentOutcomes.length;

      samples.add(TrainingSample(
        x: features(PauseContext(
          timestamp: r.timestamp,
          reason: r.reason,
          opensBefore: r.opensBefore,
          minutesSinceLastOpen: r.minutesSinceLastOpen,
          recentRelapseRate: rate,
        )),
        y: r.wentHome ? 0.0 : 1.0,
      ));

      recentOutcomes.add(r.wentHome ? 0.0 : 1.0);
      if (recentOutcomes.length > relapseWindow) recentOutcomes.removeAt(0);
    }
    return samples;
  }

  /// Score a feature vector directly (used by evaluation).
  static double scoreWith(Map<String, double> weights, Map<String, double> x) {
    var z = 0.0;
    for (final e in x.entries) {
      z += (weights[e.key] ?? 0.0) * e.value;
    }
    return _sigmoid(z);
  }

  static double _sigmoid(double z) => 1 / (1 + math.exp(-z.clamp(-30.0, 30.0)));
}

class TrainingSample {
  final Map<String, double> x;
  final double y; // 1.0 = opened anyway
  const TrainingSample({required this.x, required this.y});
}
