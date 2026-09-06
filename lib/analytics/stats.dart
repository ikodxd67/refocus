import 'dart:math' as math;

/// Result of a Pearson correlation, with the significance test that makes it
/// reportable rather than just a number.
class CorrelationResult {
  /// Pearson's r, in [-1, 1].
  final double r;

  /// Number of paired observations.
  final int n;

  /// Two-tailed p-value from the Student t test on r.
  final double p;

  const CorrelationResult({required this.r, required this.n, required this.p});

  bool get isSignificant => p < 0.05;

  /// Conventional verbal strength of |r|.
  String get strength {
    final a = r.abs();
    if (a < 0.1) return 'negligible';
    if (a < 0.3) return 'weak';
    if (a < 0.5) return 'moderate';
    if (a < 0.7) return 'strong';
    return 'very strong';
  }
}

/// Pearson correlation between two equal-length samples.
///
/// Returns null when there aren't enough points (n < 3) or when either sample
/// has zero variance — in both cases r is undefined, and reporting 0 would be
/// a lie rather than a result.
CorrelationResult? pearson(List<double> x, List<double> y) {
  if (x.length != y.length) {
    throw ArgumentError('pearson: samples must be the same length');
  }
  final n = x.length;
  if (n < 3) return null;

  final mx = _mean(x);
  final my = _mean(y);

  var sxy = 0.0, sxx = 0.0, syy = 0.0;
  for (var i = 0; i < n; i++) {
    final dx = x[i] - mx;
    final dy = y[i] - my;
    sxy += dx * dy;
    sxx += dx * dx;
    syy += dy * dy;
  }
  if (sxx == 0 || syy == 0) return null;

  var r = sxy / math.sqrt(sxx * syy);
  // guard against tiny floating point overshoot past ±1
  r = r.clamp(-1.0, 1.0);

  return CorrelationResult(r: r, n: n, p: _pValueForR(r, n));
}

/// Two-tailed p-value for a correlation coefficient.
///
/// t = r * sqrt((n-2) / (1 - r^2)) with df = n - 2, and the two-tailed tail
/// probability of the t distribution is exactly the regularized incomplete
/// beta I_{df/(df+t^2)}(df/2, 1/2).
double _pValueForR(double r, int n) {
  final df = n - 2;
  if (df <= 0) return 1;
  if (r.abs() >= 1) return 0;
  final t = r * math.sqrt(df / (1 - r * r));
  final x = df / (df + t * t);
  return regularizedIncompleteBeta(x, df / 2, 0.5).clamp(0.0, 1.0);
}

double _mean(List<double> v) {
  var s = 0.0;
  for (final e in v) {
    s += e;
  }
  return s / v.length;
}

/// Regularized incomplete beta function I_x(a, b), via the standard continued
/// fraction expansion. Used here only for the t-distribution tail.
double regularizedIncompleteBeta(double x, double a, double b) {
  if (x <= 0) return 0;
  if (x >= 1) return 1;

  final lnBeta = _lnGamma(a) + _lnGamma(b) - _lnGamma(a + b);
  final front = math.exp(a * math.log(x) + b * math.log(1 - x) - lnBeta);

  // The continued fraction converges quickly only on one side of this point.
  if (x < (a + 1) / (a + b + 2)) {
    return front * _betaContinuedFraction(a, b, x) / a;
  }
  return 1 - front * _betaContinuedFraction(b, a, 1 - x) / b;
}

double _betaContinuedFraction(double a, double b, double x) {
  const maxIterations = 300;
  const epsilon = 3e-14;
  const tiny = 1e-300;

  final qab = a + b;
  final qap = a + 1;
  final qam = a - 1;

  var c = 1.0;
  var d = 1 - qab * x / qap;
  if (d.abs() < tiny) d = tiny;
  d = 1 / d;
  var h = d;

  for (var m = 1; m <= maxIterations; m++) {
    final m2 = 2 * m;

    var num = m * (b - m) * x / ((qam + m2) * (a + m2));
    d = 1 + num * d;
    if (d.abs() < tiny) d = tiny;
    c = 1 + num / c;
    if (c.abs() < tiny) c = tiny;
    d = 1 / d;
    h *= d * c;

    num = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2));
    d = 1 + num * d;
    if (d.abs() < tiny) d = tiny;
    c = 1 + num / c;
    if (c.abs() < tiny) c = tiny;
    d = 1 / d;

    final delta = d * c;
    h *= delta;

    if ((delta - 1).abs() < epsilon) break;
  }
  return h;
}

/// Lanczos approximation of ln(Γ(x)).
double _lnGamma(double x) {
  const g = 7.0;
  const coefficients = <double>[
    0.99999999999980993,
    676.5203681218851,
    -1259.1392167224028,
    771.32342877765313,
    -176.61502916214059,
    12.507343278686905,
    -0.13857109526572012,
    9.9843695780195716e-6,
    1.5056327351493116e-7,
  ];

  if (x < 0.5) {
    // reflection formula
    return math.log(math.pi / math.sin(math.pi * x)) - _lnGamma(1 - x);
  }

  final z = x - 1;
  var a = coefficients[0];
  final t = z + g + 0.5;
  for (var i = 1; i < coefficients.length; i++) {
    a += coefficients[i] / (z + i);
  }
  return 0.5 * math.log(2 * math.pi) +
      (z + 0.5) * math.log(t) -
      t +
      math.log(a);
}

/// Simple moving average over [window] points; shorter windows at the start.
List<double> rollingMean(List<double> values, int window) {
  if (window < 1) throw ArgumentError('window must be >= 1');
  final out = <double>[];
  for (var i = 0; i < values.length; i++) {
    final start = math.max(0, i - window + 1);
    var sum = 0.0;
    for (var j = start; j <= i; j++) {
      sum += values[j];
    }
    out.add(sum / (i - start + 1));
  }
  return out;
}
