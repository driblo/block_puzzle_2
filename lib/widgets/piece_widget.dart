import 'package:flutter/material.dart';
import '../models/piece_definition.dart';

class PieceWidget extends StatelessWidget {
  final PieceDefinition definition;
  final double cellSize;
  final double opacity;

  const PieceWidget({
    super.key,
    required this.definition,
    required this.cellSize,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: definition.colSpan * cellSize,
        height: definition.rowSpan * cellSize,
        child: CustomPaint(
          painter: _PiecePainter(definition: definition, cellSize: cellSize),
        ),
      ),
    );
  }
}

class _PiecePainter extends CustomPainter {
  final PieceDefinition definition;
  final double cellSize;

  const _PiecePainter({required this.definition, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = definition.color;
    final borderPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final (row, col) in definition.cells) {
      final rect = Rect.fromLTWH(
        col * cellSize + 1,
        row * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
      canvas.drawRRect(rRect, fillPaint);
      canvas.drawRRect(rRect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_PiecePainter old) =>
      old.definition != definition || old.cellSize != cellSize;
}
