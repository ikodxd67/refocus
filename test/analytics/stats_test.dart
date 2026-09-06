import 'package:flutter_test/flutter_test.dart';
import 'package:refocus/analytics/stats.dart';

void main() {
  group('pearson', () {
    test('matches a hand-computed correlation', () {
      // x̄=3, ȳ=4; Σdxdy=6, Σdx²=10, Σdy²=6 -> r = 6/√60
      final r = pearson([1, 2, 3, 4, 5], [2, 4, 5, 4, 5]);
      expect(r, isNotNull);
      expect(r!.r, closeTo(0.7745966692, 1e-9));
      expect(r.n, 5);
    });

    test('perfect positive and negative relationships', () {
      expect(pearson([1, 2, 3, 4], [2, 4, 6, 8])!.r, closeTo(1.0, 1e-12));
      expect(pearson([1, 2, 3, 4], [8, 6, 4, 2])!.r, closeTo(-1.0, 1e-12));
    });

    test('returns null rather than a fake zero when r is undefined', () {
      expect(pearson([1, 2], [3, 4]), isNull, reason: 'n < 3');
      expect(pearson([5, 5, 5], [1, 2, 3]), isNull, reason: 'no variance in x');
      expect(pearson([1, 2, 3], [7, 7, 7]), isNull, reason: 'no variance in y');
    });

    test('rejects mismatched sample lengths', () {
      expect(() => pearson([1, 2, 3], [1, 2]), throwsArgumentError);
    });

    test('p-value for r=0.7746, n=5 is around 0.124', () {
      // t = 2.1213 with df = 3 -> two-tailed p ≈ 0.1241
      final r = pearson([1, 2, 3, 4, 5], [2, 4, 5, 4, 5])!;
      expect(r.p, closeTo(0.1241, 0.002));
      expect(r.isSignificant, isFalse);
    });

    test('a strong correlation over more points is significant', () {
      final r = pearson(
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        [2, 4, 5, 4, 6, 7, 8, 8, 9, 11],
      )!;
      expect(r.r, greaterThan(0.9));
      expect(r.p, lessThan(0.05));
      expect(r.isSignificant, isTrue);
      expect(r.strength, 'very strong');
    });

    test('strength labels track |r|', () {
      expect(pearson([1, 2, 3, 4], [2, 4, 6, 8])!.strength, 'very strong');
      expect(pearson([1, 2, 3, 4], [8, 6, 4, 2])!.strength, 'very strong');
    });
  });

  group('regularizedIncompleteBeta', () {
    test('I_0.5(0.5, 0.5) is exactly 0.5 (arcsine distribution)', () {
      expect(regularizedIncompleteBeta(0.5, 0.5, 0.5), closeTo(0.5, 1e-10));
    });

    test('is symmetric: I_x(a,b) = 1 - I_(1-x)(b,a)', () {
      final left = regularizedIncompleteBeta(0.3, 2, 3);
      final right = regularizedIncompleteBeta(0.7, 3, 2);
      expect(left, closeTo(1 - right, 1e-10));
    });

    test('I_x(1,1) is the identity', () {
      expect(regularizedIncompleteBeta(0.25, 1, 1), closeTo(0.25, 1e-10));
      expect(regularizedIncompleteBeta(0.9, 1, 1), closeTo(0.9, 1e-10));
    });

    test('clamps at the boundaries', () {
      expect(regularizedIncompleteBeta(0, 2, 3), 0);
      expect(regularizedIncompleteBeta(1, 2, 3), 1);
    });
  });

  group('rollingMean', () {
    test('averages a trailing window, shrinking at the start', () {
      expect(rollingMean([1, 2, 3, 4], 2), [1.0, 1.5, 2.5, 3.5]);
    });

    test('window of 1 is the identity', () {
      expect(rollingMean([4, 7, 2], 1), [4.0, 7.0, 2.0]);
    });

    test('rejects a non-positive window', () {
      expect(() => rollingMean([1, 2], 0), throwsArgumentError);
    });
  });
}
