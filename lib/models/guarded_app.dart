/// One app the user can choose to guard (pause on launch).
///
/// [emoji] and [colorHex] are a lightweight stand-in for the real app icon so
/// the list looks familiar without shipping third-party logos. On Android the
/// real launcher icon can be swapped in later via the platform channel.
class GuardedApp {
  final String packageName; // e.g. com.zhiliaoapp.musically (TikTok)
  final String name;
  final String emoji;
  final int colorHex;
  bool guarded;

  GuardedApp({
    required this.packageName,
    required this.name,
    required this.emoji,
    required this.colorHex,
    this.guarded = false,
  });

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'name': name,
        'emoji': emoji,
        'colorHex': colorHex,
        'guarded': guarded,
      };

  factory GuardedApp.fromJson(Map<String, dynamic> j) => GuardedApp(
        packageName: j['packageName'] as String,
        name: j['name'] as String,
        emoji: j['emoji'] as String? ?? '📱',
        colorHex: j['colorHex'] as int? ?? 0xFF334155,
        guarded: j['guarded'] as bool? ?? false,
      );

  /// A small starter set of the usual short-form culprits.
  static List<GuardedApp> defaults() => [
        GuardedApp(
          packageName: 'com.zhiliaoapp.musically',
          name: 'TikTok',
          emoji: '♪',
          colorHex: 0xFF111111,
          guarded: true,
        ),
        GuardedApp(
          packageName: 'com.instagram.android',
          name: 'Instagram',
          emoji: '◎',
          colorHex: 0xFFDD2A7B,
          guarded: true,
        ),
        GuardedApp(
          packageName: 'com.google.android.youtube',
          name: 'YouTube',
          emoji: '▶',
          colorHex: 0xFFFF0000,
          guarded: false,
        ),
        GuardedApp(
          packageName: 'com.twitter.android',
          name: 'X',
          emoji: '✕',
          colorHex: 0xFF1DA1F2,
          guarded: false,
        ),
      ];
}
