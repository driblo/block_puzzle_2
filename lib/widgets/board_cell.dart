import 'package:flutter/material.dart';

class BoardCell extends StatelessWidget {
  final Color? color;
  final bool isClearing;
  final bool isGhost;
  final bool isGhostInvalid;

  const BoardCell({
    super.key,
    this.color,
    this.isClearing = false,
    this.isGhost = false,
    this.isGhostInvalid = false,
  });

  @override
  Widget build(BuildContext context) {
    Color cellColor;

    if (isClearing) {
      cellColor = Colors.white;
    } else if (isGhost) {
      cellColor = isGhostInvalid
          ? Colors.red.withAlpha(120)
          : Colors.white.withAlpha(80);
    } else if (color != null) {
      cellColor = color!;
    } else {
      cellColor = const Color(0xFF252540);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
