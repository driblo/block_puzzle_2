import 'package:flutter/material.dart';
import '../models/piece_definition.dart';

bool canPlace(
    List<List<Color?>> grid, PieceDefinition piece, int anchorRow, int anchorCol) {
  for (final (dr, dc) in piece.cells) {
    final r = anchorRow + dr;
    final c = anchorCol + dc;
    if (r < 0 || r >= 13 || c < 0 || c >= 10) return false;
    if (grid[r][c] != null) return false;
  }
  return true;
}

List<List<Color?>> placeOnGrid(
    List<List<Color?>> grid, PieceDefinition piece, int anchorRow, int anchorCol) {
  final next = [for (final row in grid) List<Color?>.from(row)];
  for (final (dr, dc) in piece.cells) {
    next[anchorRow + dr][anchorCol + dc] = piece.color;
  }
  return next;
}

bool hasAnyValidPlacement(List<List<Color?>> grid, PieceDefinition piece) {
  for (int r = 0; r < 13; r++) {
    for (int c = 0; c < 10; c++) {
      if (canPlace(grid, piece, r, c)) return true;
    }
  }
  return false;
}
