import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/piece_tray.dart';
import '../widgets/score_display.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final gridKey = GlobalKey();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Cell size constrained by both width (with 32px side padding)
            // and height (header ~80, tray ~140, spacing ~32 → 15 rows)
            const sidePad = 16.0;
            final maxFromWidth = (constraints.maxWidth - sidePad * 2) / 10;
            final maxFromHeight =
                (constraints.maxHeight - 80 - 140 - 32) / 13;
            final cellSize = maxFromWidth.clamp(0.0, maxFromHeight);
            final trayCellSize = (constraints.maxWidth / 3 - 24) / 5;

            return Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 16),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white54),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          ScoreDisplay(
                            score: state.score,
                            bestScore: state.bestScore,
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh,
                                color: Colors.white54),
                            onPressed: () =>
                                ref.read(gameProvider.notifier).startNewGame(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Grid with side padding
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: sidePad),
                      child: Center(
                        child: GameBoard(
                          cellSize: cellSize,
                          gridKey: gridKey,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Piece tray
                    Container(
                      height: 120 + trayCellSize * 2,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: PieceTray(cellSize: trayCellSize, boardCellSize: cellSize),
                    ),
                    const SizedBox(height: 56),
                  ],
                ),
                // Game over overlay
                if (state.status == GameStatus.gameOver)
                  _GameOverOverlay(
                    score: state.score,
                    bestScore: state.bestScore,
                    onReplay: () =>
                        ref.read(gameProvider.notifier).startNewGame(),
                    onHome: () => Navigator.of(context).pop(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatefulWidget {
  final int score;
  final int bestScore;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const _GameOverOverlay({
    required this.score,
    required this.bestScore,
    required this.onReplay,
    required this.onHome,
  });

  @override
  State<_GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<_GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: 40.0, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: child,
        ),
      ),
      child: Container(
        color: Colors.black.withAlpha(180),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF252540),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF818CF8).withAlpha(80),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GAME OVER',
                  style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 24),
                _StatRow(label: 'Score', value: widget.score),
                const SizedBox(height: 8),
                _StatRow(label: 'Best', value: widget.bestScore),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _OverlayButton(
                      label: 'HOME',
                      onTap: widget.onHome,
                      color: const Color(0xFF2A2A4A),
                    ),
                    const SizedBox(width: 16),
                    _OverlayButton(
                      label: 'PLAY AGAIN',
                      onTap: widget.onReplay,
                      color: const Color(0xFF818CF8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.nunito(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        Text('$value',
            style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _OverlayButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
