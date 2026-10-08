import 'package:flutter/material.dart';
import 'piece_instance.dart';
import 'level_definition.dart';

enum GameStatus { playing, gameOver, levelComplete }

class GameState {
  final List<List<Color?>> grid;
  final List<PieceInstance?> tray;
  final int score;
  final int bestScore;
  final GameStatus status;
  final (int, int)? ghostAnchor;
  final int? ghostTrayIndex;
  final Set<(int, int)> clearingCells;
  final LevelDefinition? currentLevel; // null = endless mode

  const GameState({
    required this.grid,
    required this.tray,
    required this.score,
    required this.bestScore,
    this.status = GameStatus.playing,
    this.ghostAnchor,
    this.ghostTrayIndex,
    this.clearingCells = const {},
    this.currentLevel,
  });

  GameState copyWith({
    List<List<Color?>>? grid,
    List<PieceInstance?>? tray,
    int? score,
    int? bestScore,
    GameStatus? status,
    Set<(int, int)>? clearingCells,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      tray: tray ?? this.tray,
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      status: status ?? this.status,
      ghostAnchor: ghostAnchor,
      ghostTrayIndex: ghostTrayIndex,
      clearingCells: clearingCells ?? this.clearingCells,
      currentLevel: currentLevel,
    );
  }

  GameState withGhost((int, int)? anchor, int? trayIndex) {
    return GameState(
      grid: grid,
      tray: tray,
      score: score,
      bestScore: bestScore,
      status: status,
      clearingCells: clearingCells,
      ghostAnchor: anchor,
      ghostTrayIndex: trayIndex,
      currentLevel: currentLevel,
    );
  }
}
