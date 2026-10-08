import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../logic/level_catalog.dart';
import '../providers/levels_provider.dart';
import '../widgets/level_bubble.dart';
import 'game_screen.dart';

// Layout constants
const _kBubbleSize = 64.0;
const _kRowHeight = 110.0;
const _kTopPad = 24.0;
const _kBottomPad = 40.0;

/// Returns the center Offset of a level bubble within the scroll content.
Offset _bubbleCenter(int level, double contentWidth) {
  final row = (level - 1) ~/ 5;
  final pos = (level - 1) % 5;
  final isLTR = row % 2 == 0;
  final col = isLTR ? pos : (4 - pos);
  final x = col * (contentWidth - _kBubbleSize) / 4 + _kBubbleSize / 2;
  final y = _kTopPad + row * _kRowHeight + _kBubbleSize / 2;
  return Offset(x, y);
}

class LevelMapScreen extends ConsumerWidget {
  const LevelMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(levelsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'LEVELS',
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth - 32;
          final totalHeight =
              _kTopPad + 10 * _kRowHeight + _kBubbleSize + _kBottomPad;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: contentWidth,
              height: totalHeight,
              child: Stack(
                children: [
                  // Path lines behind bubbles
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PathPainter(
                        progress: progress,
                        contentWidth: contentWidth,
                      ),
                    ),
                  ),
                  // Level bubbles
                  for (int n = 1; n <= 50; n++) _buildBubble(
                    context,
                    ref,
                    n,
                    contentWidth,
                    progress,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBubble(
    BuildContext context,
    WidgetRef ref,
    int n,
    double contentWidth,
    List<LevelProgress> progress,
  ) {
    final center = _bubbleCenter(n, contentWidth);
    final prog = progress[n - 1];
    final unlocked = n == 1 || progress[n - 2].stars > 0;

    return Positioned(
      left: center.dx - _kBubbleSize / 2,
      top: center.dy - _kBubbleSize / 2,
      width: _kBubbleSize,
      height: _kBubbleSize,
      child: LevelBubble(
        levelNumber: n,
        stars: prog.stars,
        unlocked: unlocked,
        onTap: unlocked
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        GameScreen(level: levelCatalog[n - 1]),
                  ),
                )
            : null,
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final List<LevelProgress> progress;
  final double contentWidth;

  const _PathPainter({required this.progress, required this.contentWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = const Color(0xFFFACC15)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final greyPaint = Paint()
      ..color = const Color(0xFF3A3A5A)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int n = 1; n < 50; n++) {
      final from = _bubbleCenter(n, contentWidth);
      final to = _bubbleCenter(n + 1, contentWidth);
      final completed = progress[n - 1].stars > 0;
      canvas.drawLine(from, to, completed ? goldPaint : greyPaint);
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) =>
      old.progress != progress || old.contentWidth != contentWidth;
}
