class LevelDefinition {
  final int number;  // 1–50
  final int star1;   // score for 1 star (pass threshold)
  final int star2;
  final int star3;

  const LevelDefinition({
    required this.number,
    required this.star1,
    required this.star2,
    required this.star3,
  });

  int starsForScore(int score) {
    if (score >= star3) return 3;
    if (score >= star2) return 2;
    if (score >= star1) return 1;
    return 0;
  }
}
