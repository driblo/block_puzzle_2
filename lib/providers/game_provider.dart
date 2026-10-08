import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';
import '../models/piece_instance.dart';
import '../models/level_definition.dart';
import '../logic/piece_catalog.dart';
import '../logic/placement_checker.dart';
import '../logic/line_clear_engine.dart';
import '../logic/scoring_engine.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier()
      : super(GameState(
          grid: _emptyGrid(),
          tray: [null, null, null],
          score: 0,
          bestScore: 0,
        )) {
    _init();
  }

  static final _rng = Random();

  static List<List<Color?>> _emptyGrid() =>
      List.generate(13, (_) => List.filled(10, null));

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final best = prefs.getInt('best_score') ?? 0;
    state = state.copyWith(bestScore: best);
    startNewGame();
  }

  void startNewGame() {
    state = GameState(
      grid: _emptyGrid(),
      tray: _pickThree(),
      score: 0,
      bestScore: state.bestScore,
    );
  }

  void startLevel(LevelDefinition level) {
    state = GameState(
      grid: _emptyGrid(),
      tray: _pickThree(),
      score: 0,
      bestScore: state.bestScore,
      currentLevel: level,
    );
  }

  List<PieceInstance?> _pickThree() {
    return List.generate(3, (i) {
      final def = pieceCatalog[_rng.nextInt(pieceCatalog.length)];
      return PieceInstance(
        id: '${DateTime.now().microsecondsSinceEpoch}_$i',
        definition: def,
      );
    });
  }

  void updateGhost(int trayIndex, int row, int col) {
    if (state.ghostAnchor == (row, col) &&
        state.ghostTrayIndex == trayIndex) {
      return;
    }
    state = state.withGhost((row, col), trayIndex);
  }

  void clearGhost() {
    if (state.ghostAnchor == null) return;
    state = state.withGhost(null, null);
  }

  Future<void> placePiece(int trayIndex, int row, int col) async {
    final piece = state.tray[trayIndex];
    if (piece == null || piece.isPlaced) return;
    if (!canPlace(state.grid, piece.definition, row, col)) return;
    if (state.status == GameStatus.levelComplete) return;

    final currentLevel = state.currentLevel;

    // 1. Place piece on grid
    var newGrid = placeOnGrid(state.grid, piece.definition, row, col);

    // 2. Mark tray slot as placed
    final newTray = List<PieceInstance?>.from(state.tray);
    newTray[trayIndex] = piece.markPlaced();

    // 3. Detect full lines
    final fullRows = detectFullRows(newGrid);
    final fullCols = detectFullCols(newGrid);
    final clearing = linesToCells(fullRows, fullCols);

    // 4. Calculate score
    final lineCount = fullRows.length + fullCols.length;
    final delta = scoreForPlacement(piece.definition.cellCount) +
        scoreForClear(lineCount);
    final newScore = state.score + delta;
    final newBest = max(newScore, state.bestScore);

    // 5. Animate line clears
    if (clearing.isNotEmpty) {
      state = GameState(
        grid: newGrid,
        tray: newTray,
        score: newScore,
        bestScore: newBest,
        clearingCells: clearing,
        currentLevel: currentLevel,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      newGrid = clearCells(newGrid, clearing);
    }

    // 6. Refill tray if all slots used
    final allPlaced = newTray.every((p) => p == null || p.isPlaced);
    final finalTray = allPlaced ? _pickThree() : newTray;

    // 7. Check level complete (score target reached)
    final isLevelComplete =
        currentLevel != null && newScore >= currentLevel.star1;

    // 8. Check game over (only if level not complete)
    final activePieces =
        finalTray.whereType<PieceInstance>().where((p) => !p.isPlaced);
    final isGameOver = !isLevelComplete &&
        activePieces.isNotEmpty &&
        activePieces.every((p) => !hasAnyValidPlacement(newGrid, p.definition));

    state = GameState(
      grid: newGrid,
      tray: finalTray,
      score: newScore,
      bestScore: newBest,
      currentLevel: currentLevel,
      status: isLevelComplete
          ? GameStatus.levelComplete
          : isGameOver
              ? GameStatus.gameOver
              : GameStatus.playing,
    );

    final prefs = await SharedPreferences.getInstance();
    if (newBest > (prefs.getInt('best_score') ?? 0)) {
      await prefs.setInt('best_score', newBest);
    }
  }
}
