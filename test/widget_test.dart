import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:block_puzzle_2/logic/placement_checker.dart';
import 'package:block_puzzle_2/logic/line_clear_engine.dart';
import 'package:block_puzzle_2/logic/scoring_engine.dart';
import 'package:block_puzzle_2/logic/piece_catalog.dart';

List<List<Color?>> _emptyGrid() =>
    List.generate(13, (_) => List<Color?>.filled(10, null));

void main() {
  group('placement_checker', () {
    test('can place on empty grid', () {
      final grid = _emptyGrid();
      final piece = pieceCatalog.first; // dot
      expect(canPlace(grid, piece, 0, 0), isTrue);
    });

    test('rejects out of bounds', () {
      final grid = _emptyGrid();
      final h5 = pieceCatalog.firstWhere((p) => p.name == 'h5');
      expect(canPlace(grid, h5, 0, 6), isFalse);
    });

    test('rejects occupied cell', () {
      final grid = _emptyGrid();
      grid[0][0] = const Color(0xFF000000);
      final dot = pieceCatalog.firstWhere((p) => p.name == 'dot');
      expect(canPlace(grid, dot, 0, 0), isFalse);
    });
  });

  group('line_clear_engine', () {
    test('detects full row', () {
      final grid = _emptyGrid();
      for (int c = 0; c < 10; c++) {
        grid[3][c] = const Color(0xFF000000);
      }
      expect(detectFullRows(grid), contains(3));
    });

    test('detects full column', () {
      final grid = _emptyGrid();
      for (int r = 0; r < 13; r++) {
        grid[r][5] = const Color(0xFF000000);
      }
      expect(detectFullCols(grid), contains(5));
    });
  });

  group('scoring_engine', () {
    test('1 line = 10pts', () => expect(scoreForClear(1), 10));
    test('2 lines = 30pts', () => expect(scoreForClear(2), 30));
    test('3 lines = 60pts', () => expect(scoreForClear(3), 60));
    test('placement score = cell count', () {
      final sq = pieceCatalog.firstWhere((p) => p.name == 'sq');
      expect(scoreForPlacement(sq.cellCount), 4);
    });
  });
}
