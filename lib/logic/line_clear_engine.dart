import 'package:flutter/material.dart';

List<int> detectFullRows(List<List<Color?>> grid) {
  final full = <int>[];
  for (int r = 0; r < 13; r++) {
    if (grid[r].every((c) => c != null)) full.add(r);
  }
  return full;
}

List<int> detectFullCols(List<List<Color?>> grid) {
  final full = <int>[];
  for (int c = 0; c < 10; c++) {
    if (grid.every((row) => row[c] != null)) full.add(c);
  }
  return full;
}

Set<(int, int)> linesToCells(List<int> rows, List<int> cols) {
  final cells = <(int, int)>{};
  for (final r in rows) {
    for (int c = 0; c < 10; c++) {
      cells.add((r, c));
    }
  }
  for (final c in cols) {
    for (int r = 0; r < 13; r++) {
      cells.add((r, c));
    }
  }
  return cells;
}

List<List<Color?>> clearCells(List<List<Color?>> grid, Set<(int, int)> cells) {
  final next = [for (final row in grid) List<Color?>.from(row)];
  for (final (r, c) in cells) {
    next[r][c] = null;
  }
  return next;
}
