import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/game_state.dart';
import '../models/level_definition.dart';
import '../logic/level_catalog.dart';
import '../providers/game_provider.dart';
import '../providers/levels_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/piece_tray.dart';
import '../widgets/score_display.dart';

class GameScreen extends ConsumerStatefulWidget {
  final LevelDefinition? level;
  const GameScreen({super.key, this.level});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.level != null) {
        ref.read(gameProvider.notifier).startLevel(widget.level!);
      } else {
        ref.read(gameProvider.notifier).startNewGame();
      }
    });
  }

  void _restart() {
    if (widget.level != null) {
      ref.read(gameProvider.notifier).startLevel(widget.level!);
    } else {
      ref.read(gameProvider.notifier).startNewGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final gridKey = GlobalKey();

    ref.listen<GameState>(gameProvider, (prev, next) {
      if (widget.level == null) return;
      final wasPlaying = prev?.status == GameStatus.playing;
      final ended = next.status == GameStatus.levelComplete ||
          next.status == GameStatus.gameOver;
      if (wasPlaying && ended) {
        ref
            .read(levelsProvider.notifier)
            .saveLevelResult(widget.level!.number, next.score);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
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
                          if (widget.level != null)
                            _LevelHeader(
                                level: widget.level!, score: state.score)
                          else
                            ScoreDisplay(
                              score: state.score,
                              bestScore: state.bestScore,
                            ),
                          IconButton(
                            icon: const Icon(Icons.refresh,
                                color: Colors.white54),
                            onPressed: _restart,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: sidePad),
                      child: Center(
                        child: GameBoard(
                          cellSize: cellSize,
                          gridKey: gridKey,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 120 + trayCellSize * 2,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: PieceTray(
                          cellSize: trayCellSize, boardCellSize: cellSize),
                    ),
                    const SizedBox(height: 56),
                  ],
                ),
                if (state.status == GameStatus.gameOver)
                  _GameOverOverlay(
                    score: state.score,
                    bestScore: state.bestScore,
                    onReplay: _restart,
                    onHome: () => Navigator.of(context).pop(),
                  ),
                if (state.status == GameStatus.levelComplete &&
                    widget.level != null)
                  _LevelCompleteOverlay(
                    level: widget.level!,
                    score: state.score,
                    onRetry: _restart,
                    onNext: widget.level!.number < 50
                        ? () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => GameScreen(
                                  level: levelCatalog[widget.level!.number],
                                ),
                              ),
                            )
                        : null,
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

// ── Level header (shown instead of ScoreDisplay in level mode) ────────────────

class _LevelHeader extends StatelessWidget {
  final LevelDefinition level;
  final int score;
  const _LevelHeader({required this.level, required this.score});

  @override
  Widget build(BuildContext context) {
    final stars = level.starsForScore(score);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'LEVEL ${level.number}',
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white54,
            letterSpacing: 2,
          ),
        ),
        Text(
          '$score',
          style: GoogleFonts.nunito(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Icon(
              i < stars ? Icons.star : Icons.star_border,
              size: 13,
              color: i < stars ? const Color(0xFFFACC15) : Colors.white24,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Level complete overlay ────────────────────────────────────────────────────

class _LevelCompleteOverlay extends StatefulWidget {
  final LevelDefinition level;
  final int score;
  final VoidCallback onRetry;
  final VoidCallback? onNext;
  final VoidCallback onHome;

  const _LevelCompleteOverlay({
    required this.level,
    required this.score,
    required this.onRetry,
    required this.onHome,
    this.onNext,
  });

  @override
  State<_LevelCompleteOverlay> createState() => _LevelCompleteOverlayState();
}

class _LevelCompleteOverlayState extends State<_LevelCompleteOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _starsCtrl;
  late final Animation<double> _fade;
  late final List<Animation<double>> _starScales;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _starsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _starScales = List.generate(3, (i) {
      final start = i * 0.30;
      final end = start + 0.40;
      return CurvedAnimation(
        parent: _starsCtrl,
        curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.elasticOut),
      );
    });

    _fadeCtrl.forward();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _starsCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _starsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final earned = widget.level.starsForScore(widget.score);
    return AnimatedBuilder(
      animation: _fadeCtrl,
      builder: (context, child) =>
          Opacity(opacity: _fade.value, child: child),
      child: Container(
        color: Colors.black.withAlpha(180),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            decoration: BoxDecoration(
              color: const Color(0xFF252540),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFFACC15).withAlpha(80),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFACC15).withAlpha(30),
                  blurRadius: 32,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LEVEL ${widget.level.number}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'COMPLETE!',
                  style: GoogleFonts.nunito(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final isEarned = i < earned;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: AnimatedBuilder(
                        animation: _starScales[i],
                        builder: (context, _) => Transform.scale(
                          scale: isEarned
                              ? _starScales[i].value.clamp(0.0, 1.3)
                              : 1.0,
                          child: Icon(
                            isEarned ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 56,
                            color: isEarned
                                ? const Color(0xFFFACC15)
                                : Colors.white12,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                _ThresholdRow(level: widget.level, score: widget.score),
                const SizedBox(height: 8),
                _StatRow(label: 'Score', value: widget.score),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _OverlayButton(
                      label: 'HOME',
                      onTap: widget.onHome,
                      color: const Color(0xFF2A2A4A),
                    ),
                    const SizedBox(width: 10),
                    _OverlayButton(
                      label: 'RETRY',
                      onTap: widget.onRetry,
                      color: const Color(0xFF3A3A5A),
                    ),
                    if (widget.onNext != null) ...[
                      const SizedBox(width: 10),
                      _OverlayButton(
                        label: 'NEXT',
                        onTap: widget.onNext!,
                        color: const Color(0xFFFACC15),
                        textColor: const Color(0xFF1A1A2E),
                      ),
                    ],
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

class _ThresholdRow extends StatelessWidget {
  final LevelDefinition level;
  final int score;
  const _ThresholdRow({required this.level, required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StarThreshold(
            threshold: level.star1, score: score, color: const Color(0xFFF97316)),
        const SizedBox(width: 12),
        _StarThreshold(
            threshold: level.star2, score: score, color: const Color(0xFF818CF8)),
        const SizedBox(width: 12),
        _StarThreshold(
            threshold: level.star3, score: score, color: const Color(0xFFFACC15)),
      ],
    );
  }
}

class _StarThreshold extends StatelessWidget {
  final int threshold;
  final int score;
  final Color color;
  const _StarThreshold(
      {required this.threshold, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    final reached = score >= threshold;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: 12,
            color: reached ? color : Colors.white24),
        const SizedBox(width: 2),
        Text(
          '$threshold',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: reached ? color : Colors.white24,
          ),
        ),
      ],
    );
  }
}

// ── Game over overlay ─────────────────────────────────────────────────────────

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

// ── Shared widgets ────────────────────────────────────────────────────────────

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
  final Color textColor;

  const _OverlayButton({
    required this.label,
    required this.onTap,
    required this.color,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
