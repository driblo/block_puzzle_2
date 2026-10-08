import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelBubble extends StatelessWidget {
  final int levelNumber;
  final int stars;      // 0–3
  final bool unlocked;
  final VoidCallback? onTap;

  const LevelBubble({
    super.key,
    required this.levelNumber,
    required this.stars,
    required this.unlocked,
    this.onTap,
  });

  Color get _bgColor {
    if (!unlocked) return const Color(0xFF2A2A3A);
    switch (stars) {
      case 3: return const Color(0xFFFACC15);
      case 2: return const Color(0xFF818CF8);
      case 1: return const Color(0xFFF97316);
      default: return const Color(0xFF1E1E3A);
    }
  }

  Color get _borderColor {
    if (!unlocked) return const Color(0xFF3A3A5A);
    switch (stars) {
      case 3: return const Color(0xFFFFE566);
      case 2: return const Color(0xFFA5B4FC);
      case 1: return const Color(0xFFFB923C);
      default: return const Color(0xFF818CF8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: _bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: _borderColor, width: 2.5),
          boxShadow: unlocked
              ? [BoxShadow(color: _borderColor.withAlpha(80), blurRadius: 8)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!unlocked)
              const Icon(Icons.lock, color: Colors.white38, size: 22)
            else ...[
              Text(
                '$levelNumber',
                style: GoogleFonts.nunito(
                  fontSize: stars == 3 ? 18 : 20,
                  fontWeight: FontWeight.w900,
                  color: stars == 3 ? const Color(0xFF1A1A2E) : Colors.white,
                  height: 1,
                ),
              ),
              if (stars > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    stars,
                    (_) => const Icon(Icons.star, color: Colors.white, size: 10),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
