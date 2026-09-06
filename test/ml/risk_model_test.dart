import 'package:flutter_test/flutter_test.dart';
import 'package:refocus/analytics/models.dart';
import 'package:refocus/ml/model_evaluation.dart';
import 'package:refocus/ml/risk_model.dart';

PauseContext _ctx({
  required DateTime at,
  String reason = 'bored',
  int opensBefore = 0,
  int? gap,
  double recentRelapse = 0,
}) =>
    PauseContext(
      timestamp: at,
      reason: reason,
      opensBefore: opensBefore,
      minutesSinceLastOpen: gap,
      recentRelapseRate: recentRelapse,
    );

PauseRecord _rec(DateTime at, {required bool wentHome, String reason = 'bored'}) =>
    PauseRecord(
      timestamp: at,
      packageName: 'com.zhiliaoapp.musically',
      appName: 'TikTok',
      reason: reason,
      wentHome: wentHome,
      hourOfDay: at.hour,
      weekday: at.weekday,
      opensBefore: 0,
    );

void main() {
  group('features', () {
    test('encodes the hour cyclically so 23:00 and 01:00 are close', () {
      final a = RiskModel.features(_ctx(at: DateTime(2026, 3, 1, 23)));
      final b = RiskModel.features(_ctx(at: DateTime(2026, 3, 2, 1)));
      final distance = (a['hour_sin']! - b['hour_sin']!).abs() +
          (a['hour_cos']! - b['hour_cos']!).abs();
      expect(distance, lessThan(0.6));
    });

    test('flags late night and weekend', () {
      final lateSaturday =
          RiskModel.features(_ctx(at: DateTime(2026, 3, 7, 23)));
      expect(lateSaturday['late_night'], 1.0);
      expect(lateSaturday['weekend'], 1.0);

      final middayTuesday =
          RiskModel.features(_ctx(at: DateTime(2026, 3, 3, 13)));
      expect(middayTuesday['late_night'], 0.0);
      expect(middayTuesday['weekend'], 0.0);
    });

    test('short_gap decays from 1 to 0 over two hours', () {
      final immediate =
          RiskModel.features(_ctx(at: DateTime(2026, 3, 1, 12), gap: 0));
      final hour = RiskModel.features(_ctx(at: DateTime(2026, 3, 1, 12), gap: 60));
      final longAgo =
          RiskModel.features(_ctx(at: DateTime(2026, 3, 1, 12), gap: 500));
      expect(immediate['short_gap'], 1.0);
      expect(hour['short_gap'], closeTo(0.5, 1e-9));
      expect(longAgo['short_gap'], 0.0);
    });

    test('one-hot encodes the stated reason', () {
      final f = RiskModel.features(_ctx(at: DateTime(2026, 3, 1), reason: 'habit'));
      expect(f['reason_habit'], 1.0);
      expect(f['reason_bored'], 0.0);
    });
  });

  group('prediction', () {
    test('an untrained model abstains and sits at 0.5', () {
      final m = RiskModel.untrained();
      expect(m.isReady, isFalse);
      expect(m.predict(_ctx(at: DateTime(2026, 3, 1, 23))), closeTo(0.5, 1e-12));
    });

    test('always returns a probability', () {
      final m = RiskModel(
        weights: {for (final f in RiskModel.featureNames) f: 99.0},
        trainedOn: 100,
      );
      final p = m.predict(_ctx(at: DateTime(2026, 3, 1, 23)));
      expect(p, greaterThanOrEqualTo(0.0));
      expect(p, lessThanOrEqualTo(1.0));
    });
  });

  group('training', () {
    test('learns a separable late-night pattern', () {
      final records = <PauseRecord>[];
      for (var d = 0; d < 30; d++) {
        // late night -> always pushed through
        records.add(_rec(DateTime(2026, 3, 1 + d, 23), wentHome: false));
        // midday -> always backed out
        records.add(_rec(DateTime(2026, 3, 1 + d, 12), wentHome: true));
      }
      final model = RiskModel.train(records);

      expect(model.isReady, isTrue);
      expect(model.predict(_ctx(at: DateTime(2026, 4, 1, 23))),
          greaterThan(0.65));
      expect(model.predict(_ctx(at: DateTime(2026, 4, 1, 12))), lessThan(0.35));
    });

    test('an online update moves the prediction the right way', () {
      var model = RiskModel.train([
        for (var d = 0; d < 20; d++)
          _rec(DateTime(2026, 3, 1 + d, 12), wentHome: true),
      ]);
      final ctx = _ctx(at: DateTime(2026, 4, 1, 12));
      final before = model.predict(ctx);

      for (var i = 0; i < 20; i++) {
        model = model.updatedWith(ctx, true); // they kept opening it anyway
      }
      expect(model.predict(ctx), greaterThan(before));
      expect(model.trainedOn, greaterThan(20));
    });

    test('explanations are ranked by effect and exclude the bias term', () {
      final model = RiskModel.train([
        for (var d = 0; d < 30; d++) ...[
          _rec(DateTime(2026, 3, 1 + d, 23), wentHome: false),
          _rec(DateTime(2026, 3, 1 + d, 12), wentHome: true),
        ],
      ]);
      final reasons = model.explain(_ctx(at: DateTime(2026, 4, 1, 23)));
      expect(reasons, isNotEmpty);
      expect(reasons.map((r) => r.feature), isNot(contains('bias')));
      for (var i = 1; i < reasons.length; i++) {
        expect(reasons[i - 1].contribution.abs(),
            greaterThanOrEqualTo(reasons[i].contribution.abs()));
      }
    });
  });

  group('buildSamples', () {
    test('the first sample has no history to look back on', () {
      final samples = RiskModel.buildSamples([
        _rec(DateTime(2026, 3, 1, 10), wentHome: false),
        _rec(DateTime(2026, 3, 1, 11), wentHome: false),
      ]);
      expect(samples.first.x['recent_relapse'], 0.0);
      // the second one can see the first outcome
      expect(samples[1].x['recent_relapse'], 1.0);
    });

    test('labels 1 for pushing through and 0 for backing out', () {
      final samples = RiskModel.buildSamples([
        _rec(DateTime(2026, 3, 1, 10), wentHome: true),
        _rec(DateTime(2026, 3, 1, 11), wentHome: false),
      ]);
      expect(samples[0].y, 0.0);
      expect(samples[1].y, 1.0);
    });

    test('does not leak the current outcome into its own features', () {
      // Two logs identical except for the LAST outcome; the last sample's
      // features must be byte-identical between them.
      final base = [
        _rec(DateTime(2026, 3, 1, 10), wentHome: true),
        _rec(DateTime(2026, 3, 1, 11), wentHome: true),
      ];
      final a = RiskModel.buildSamples(
          [...base, _rec(DateTime(2026, 3, 1, 12), wentHome: true)]);
      final b = RiskModel.buildSamples(
          [...base, _rec(DateTime(2026, 3, 1, 12), wentHome: false)]);
      expect(a.last.x, equals(b.last.x));
      expect(a.last.y, isNot(equals(b.last.y)));
    });
  });

  group('rocAuc', () {
    test('perfect ranking scores 1.0', () {
      expect(
        ModelEvaluator.rocAuc([0.1, 0.2, 0.8, 0.9], [0, 0, 1, 1]),
        closeTo(1.0, 1e-12),
      );
    });

    test('exactly wrong ranking scores 0.0', () {
      expect(
        ModelEvaluator.rocAuc([0.9, 0.8, 0.2, 0.1], [0, 0, 1, 1]),
        closeTo(0.0, 1e-12),
      );
    });

    test('all-tied scores are coin-flipping', () {
      expect(
        ModelEvaluator.rocAuc([0.5, 0.5, 0.5, 0.5], [0, 1, 0, 1]),
        closeTo(0.5, 1e-12),
      );
    });
  });

  group('evaluate', () {
    const evaluator = ModelEvaluator();

    test('refuses to score too little data', () {
      expect(evaluator.evaluate([_rec(DateTime(2026, 3, 1), wentHome: true)]),
          isNull);
    });

    test('refuses when the test window has only one class', () {
      final records = [
        for (var d = 0; d < 40; d++)
          _rec(DateTime(2026, 3, 1 + d, 12), wentHome: true),
      ];
      expect(evaluator.evaluate(records), isNull);
    });

    test('beats the majority-class baseline on a learnable pattern', () {
      final records = <PauseRecord>[];
      for (var d = 0; d < 40; d++) {
        records.add(_rec(DateTime(2026, 3, 1 + d, 23), wentHome: false));
        records.add(_rec(DateTime(2026, 3, 1 + d, 12), wentHome: true));
        records.add(_rec(DateTime(2026, 3, 1 + d, 13), wentHome: true));
      }
      final result = evaluator.evaluate(records)!;

      expect(result.trainSize + result.testSize, records.length);
      expect(result.auc, greaterThan(0.9));
      expect(result.accuracy, greaterThan(result.baselineAccuracy));
      expect(result.beatsBaseline, isTrue);
    });
  });
}
