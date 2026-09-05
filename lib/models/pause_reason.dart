/// Why the user is opening the app right now — the "intention" tap (step 1).
enum PauseReason {
  bored('Just bored', '😐'),
  quickBreak('A quick break', '☕'),
  specific('Something specific', '🔍'),
  habit('Just a habit', '🔁');

  const PauseReason(this.label, this.emoji);

  final String label;
  final String emoji;

  String get id => name;

  static PauseReason fromId(String? id) =>
      PauseReason.values.firstWhere((r) => r.name == id,
          orElse: () => PauseReason.bored);
}
