import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/piece_instance.dart';
import '../providers/game_provider.dart';
import 'piece_widget.dart';

class PieceTray extends ConsumerWidget {
  final double cellSize;
  final double boardCellSize;

  const PieceTray({super.key, required this.cellSize, required this.boardCellSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tray = ref.watch(gameProvider).tray;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (i) => _TraySlot(
        piece: tray[i],
        cellSize: cellSize,
        boardCellSize: boardCellSize,
      )),
    );
  }
}

class _TraySlot extends StatelessWidget {
  final PieceInstance? piece;
  final double cellSize;
  final double boardCellSize;

  const _TraySlot({
    required this.piece,
    required this.cellSize,
    required this.boardCellSize,
  });

  @override
  Widget build(BuildContext context) {
    final slotSize = cellSize * 5;

    if (piece == null || piece!.isPlaced) {
      return SizedBox(width: slotSize, height: slotSize);
    }

    final def = piece!.definition;

    // Piece appears centered horizontally and fully above the finger.
    // Uses board cell size so the ghost and feedback are in the same units.
    final feedbackOffset = Offset(
      -def.colSpan * boardCellSize / 2,
      -def.rowSpan * boardCellSize - boardCellSize * 0.5,
    );

    return Draggable<PieceInstance>(
      data: piece,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedbackOffset: feedbackOffset,
      feedback: Material(
        color: Colors.transparent,
        child: PieceWidget(
          definition: def,
          cellSize: boardCellSize,
          opacity: 0.9,
        ),
      ),
      childWhenDragging: SizedBox(
        width: slotSize,
        height: slotSize + cellSize * 2, // extra bottom touch area
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: slotSize,
            height: slotSize,
            child: Center(
              child: PieceWidget(
                definition: def,
                cellSize: cellSize,
                opacity: 0.25,
              ),
            ),
          ),
        ),
      ),
      child: SizedBox(
        width: slotSize,
        height: slotSize + cellSize * 2, // extra bottom touch area
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: slotSize,
            height: slotSize,
            child: Center(
              child: PieceWidget(
                definition: def,
                cellSize: cellSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
