import 'package:flutter/material.dart';

class PieceDefinition {
  final String name;
  final List<(int, int)> cells; // (row, col) offsets from top-left anchor
  final Color color;

  const PieceDefinition({
    required this.name,
    required this.cells,
    required this.color,
  });

  int get rowSpan =>
      cells.map((c) => c.$1).reduce((a, b) => a > b ? a : b) + 1;

  int get colSpan =>
      cells.map((c) => c.$2).reduce((a, b) => a > b ? a : b) + 1;

  int get cellCount => cells.length;
}
