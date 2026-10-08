import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/level_catalog.dart';

final levelsProvider =
    StateNotifierProvider<LevelsNotifier, List<LevelProgress>>((ref) {
  return LevelsNotifier();
});

class LevelProgress {
  final int levelNumber;
  final int bestScore;
  final int stars; // 0–3

  const LevelProgress({
    required this.levelNumber,
    required this.bestScore,
    required this.stars,
  });
}

class LevelsNotifier extends StateNotifier<List<LevelProgress>> {
  LevelsNotifier()
      : super(List.generate(
            50,
            (i) => LevelProgress(
                levelNumber: i + 1, bestScore: 0, stars: 0))) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = List.generate(50, (i) {
      final n = i + 1;
      return LevelProgress(
        levelNumber: n,
        bestScore: prefs.getInt('level_best_$n') ?? 0,
        stars: prefs.getInt('level_stars_$n') ?? 0,
      );
    });
  }

  bool isUnlocked(int n) {
    if (n <= 1) return true;
    return state[n - 2].stars > 0;
  }

  Future<void> saveLevelResult(int levelNumber, int score) async {
    final def = levelCatalog[levelNumber - 1];
    final newStars = def.starsForScore(score);
    final prev = state[levelNumber - 1];

    final updatedStars =
        newStars > prev.stars ? newStars : prev.stars;
    final updatedBest =
        score > prev.bestScore ? score : prev.bestScore;

    if (updatedStars == prev.stars && updatedBest == prev.bestScore) return;

    final updated = List<LevelProgress>.from(state);
    updated[levelNumber - 1] = LevelProgress(
      levelNumber: levelNumber,
      bestScore: updatedBest,
      stars: updatedStars,
    );
    state = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level_stars_$levelNumber', updatedStars);
    await prefs.setInt('level_best_$levelNumber', updatedBest);
  }
}
