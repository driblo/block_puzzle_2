import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_screen.dart';
import 'level_map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BLOCK\nPUZZLE',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fill the lines. Clear the board.',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HomeButton(
                  label: 'LEVELS',
                  icon: Icons.map_outlined,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFACC15), Color(0xFFF97316)],
                  ),
                  glowColor: const Color(0xFFFACC15),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LevelMapScreen()),
                  ),
                ),
                const SizedBox(width: 20),
                _HomeButton(
                  label: 'ENDLESS',
                  icon: Icons.all_inclusive,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF818CF8), Color(0xFFC084FC)],
                  ),
                  glowColor: const Color(0xFF818CF8),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GameScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final Color glowColor;
  final VoidCallback onTap;

  const _HomeButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<_HomeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 130,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withAlpha(100),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 28),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
