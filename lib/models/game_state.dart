import 'package:flutter/material.dart';
import 'piece_instance.dart';

enum GameStatus { playing, gameOver }

class GameState {
  final List<List<Color?>> grid; // 10×10, null = empty
  final List<PieceInstance?> tray; // 3 slots, null = empty slot
  final int score;
  final int bestScore;
  final GameStatus status;
  final (int, int)? ghostAnchor; // (row, col) where ghost piece top-left would land
  final int? ghostTrayIndex; // which tray piece is being dragged
  final Set<(int, int)> clearingCells; // cells mid-clear animation

  const GameState({
    required this.grid,
    required this.tray,
    required this.score,
    required this.bestScore,
    this.status = GameStatus.playing,
    this.ghostAnchor,
    this.ghostTrayIndex,
    this.clearingCells = const {},
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
    );
  }
}
