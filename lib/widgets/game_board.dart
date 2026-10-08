import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/piece_instance.dart';
import '../providers/game_provider.dart';
import '../logic/placement_checker.dart';
import 'board_cell.dart';

class GameBoard extends ConsumerWidget {
  final double cellSize;
  final GlobalKey gridKey;

  const GameBoard({
    super.key,
    required this.cellSize,
    required this.gridKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    // Pre-compute ghost cells and validity
    Set<(int, int)> ghostCells = {};
    bool ghostValid = false;

    if (state.ghostAnchor != null && state.ghostTrayIndex != null) {
      final piece = state.tray[state.ghostTrayIndex!];
      if (piece != null && !piece.isPlaced) {
        final (ar, ac) = state.ghostAnchor!;
        ghostCells = piece.definition.cells
            .map((cell) => (ar + cell.$1, ac + cell.$2))
            .toSet();
        ghostValid = canPlace(state.grid, piece.definition, ar, ac);
      }
    }

    return DragTarget<PieceInstance>(
      onMove: (details) {
        final trayIndex = state.tray.indexWhere(
            (p) => p != null && !p.isPlaced && p.id == details.data.id);
        if (trayIndex < 0) return;

        final box =
            gridKey.currentContext?.findRenderObject() as RenderBox?;
        if (box == null) return;

        final pointer = box.globalToLocal(details.offset);
        final piece = details.data.definition;
        final rawCol = ((pointer.dx - piece.colSpan * cellSize / 2) / cellSize).round();
        final rawRow = ((pointer.dy - piece.rowSpan * cellSize - cellSize * 2.0) / cellSize).round();
        final col = rawCol.clamp(0, 10 - piece.colSpan);
        final row = rawRow.clamp(0, 13 - piece.rowSpan);
        notifier.updateGhost(trayIndex, row, col);
      },
      onLeave: (_) => notifier.clearGhost(),
      onAcceptWithDetails: (details) {
        if (state.ghostAnchor == null || state.ghostTrayIndex == null) return;
        if (!ghostValid) return;
        final (r, c) = state.ghostAnchor!;
        notifier.placePiece(state.ghostTrayIndex!, r, c);
        notifier.clearGhost();
      },
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          key: gridKey,
          width: cellSize * 10,
          height: cellSize * 13,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
            ),
            itemCount: 130,
            itemBuilder: (ctx, i) {
              final row = i ~/ 10;
              final col = i % 10;
              final coord = (row, col);
              final isClearing = state.clearingCells.contains(coord);
              final isGhost = ghostCells.contains(coord);

              return BoardCell(
                color: state.grid[row][col],
                isClearing: isClearing,
                isGhost: isGhost && !isClearing,
                isGhostInvalid: isGhost && !ghostValid,
              );
            },
          ),
        );
      },
    );
  }
}
