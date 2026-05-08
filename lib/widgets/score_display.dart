import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreDisplay extends StatefulWidget {
  final int score;
  final int bestScore;

  const ScoreDisplay({super.key, required this.score, required this.bestScore});

  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay>
    with SingleTickerProviderStateMixin {
  late int _displayed;
  late AnimationController _ctrl;
  late Animation<int> _anim;

  @override
  void initState() {
    super.initState();
    _displayed = widget.score;
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _anim = IntTween(begin: widget.score, end: widget.score)
        .animate(_ctrl);
    _ctrl.addListener(() {
      setState(() => _displayed = _anim.value);
    });
  }

  @override
  void didUpdateWidget(ScoreDisplay old) {
    super.didUpdateWidget(old);
    if (widget.score != old.score) {
      _anim = IntTween(begin: _displayed, end: widget.score)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.nunito(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ScoreBox(label: 'SCORE', value: _displayed, style: style),
        const SizedBox(width: 32),
        _ScoreBox(label: 'BEST', value: widget.bestScore, style: style),
      ],
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int value;
  final TextStyle style;

  const _ScoreBox({
    required this.label,
    required this.value,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: style.copyWith(fontSize: 11, color: Colors.white54)),
          const SizedBox(height: 2),
          Text('$value', style: style.copyWith(fontSize: 22)),
        ],
      ),
    );
  }
}
