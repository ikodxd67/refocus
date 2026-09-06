import '../analytics/models.dart';
import 'risk_model.dart';

/// How well the risk model actually performs on data it did not train on.
class EvaluationResult {
  final int trainSize;
  final int testSize;

  /// Share of test predictions correct at a 0.5 threshold.
  final double accuracy;

  /// What you'd get by always guessing the majority class — the bar the model
  /// has to clear to be worth anything.
  final double baselineAccuracy;

  /// Area under the ROC curve; 0.5 is coin-flipping.
  final double auc;

  const EvaluationResult({
    required this.trainSize,
    required this.testSize,
    required this.accuracy,
    required this.baselineAccuracy,
    required this.auc,
  });

  /// Percentage points gained over always guessing the majority class.
  double get lift => accuracy - baselineAccuracy;

  bool get beatsBaseline => accuracy > baselineAccuracy && auc > 0.5;
}

/// Trains on the earlier part of the log and tests on the later part.
///
/// The split is chronological, not random: these are time-ordered behavioural
/// events, and a random split would let the model learn from the user's future
/// and report a score it could never achieve in production.
class ModelEvaluator {
  const ModelEvaluator();

  /// Returns null when there isn't enough data, or when the test window
  /// contains only one class (AUC is undefined and accuracy is meaningless).
  EvaluationResult? evaluate(
    List<PauseRecord> records, {
    double trainFraction = 0.7,
    int minTest = 5,
  }) {
    final samples = RiskModel.buildSamples(records);
    final splitAt = (samples.length * trainFraction).floor();
    final testSize = samples.length - splitAt;
    if (splitAt < RiskModel.minObservations || testSize < minTest) return null;

    final trainRecords = records.sublist(0, splitAt);
    final testSamples = samples.sublist(splitAt);

    final positives = testSamples.where((s) => s.y == 1.0).length;
    final negatives = testSamples.length - positives;
    if (positives == 0 || negatives == 0) return null;

    final model = RiskModel.train(trainRecords);

    var correct = 0;
    final scores = <double>[];
    final labels = <double>[];
    for (final s in testSamples) {
      final p = RiskModel.scoreWith(model.weights, s.x);
      scores.add(p);
      labels.add(s.y);
      if ((p >= 0.5 ? 1.0 : 0.0) == s.y) correct++;
    }

    final majority = positives >= negatives ? positives : negatives;

    return EvaluationResult(
      trainSize: splitAt,
      testSize: testSamples.length,
      accuracy: correct / testSamples.length,
      baselineAccuracy: majority / testSamples.length,
      auc: rocAuc(scores, labels),
    );
  }

  /// Rank-based (Mann-Whitney U) AUC, with average ranks for ties.
  static double rocAuc(List<double> scores, List<double> labels) {
    final n = scores.length;
    final order = List<int>.generate(n, (i) => i)
      ..sort((a, b) => scores[a].compareTo(scores[b]));

    // Average ranks over tied score groups so ties contribute 0.5 each.
    final ranks = List<double>.filled(n, 0);
    var i = 0;
    while (i < n) {
      var j = i;
      while (j + 1 < n && scores[order[j + 1]] == scores[order[i]]) {
        j++;
      }
      final avgRank = (i + j) / 2.0 + 1.0; // ranks are 1-based
      for (var k = i; k <= j; k++) {
        ranks[order[k]] = avgRank;
      }
      i = j + 1;
    }

    var positives = 0;
    var rankSumPositive = 0.0;
    for (var k = 0; k < n; k++) {
      if (labels[k] == 1.0) {
        positives++;
        rankSumPositive += ranks[k];
      }
    }
    final negatives = n - positives;
    if (positives == 0 || negatives == 0) return 0.5;

    return (rankSumPositive - positives * (positives + 1) / 2) /
        (positives * negatives);
  }
}
