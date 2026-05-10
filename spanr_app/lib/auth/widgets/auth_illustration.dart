import 'package:flutter/material.dart';

const Color _amber = Color(0xFFFFB800);

class AuthIllustration extends StatelessWidget {
  final bool isSignup;
  const AuthIllustration({super.key, this.isSignup = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main character circle
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F0),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8E8E0), width: 2),
            ),
            child: Icon(
              isSignup ? Icons.person_add_rounded : Icons.engineering_rounded,
              size: 64,
              color: const Color(0xFF333333),
            ),
          ),

          // Hard hat on top
          Positioned(
            top: 28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.construction_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),

          // Top-right decorative gear
          Positioned(
            top: 30,
            right: 70,
            child: _FloatingElement(
              icon: Icons.settings,
              size: 26,
              color: _amber.withOpacity(0.7),
            ),
          ),

          // Top-left decorative wrench
          Positioned(
            top: 40,
            left: 65,
            child: _FloatingElement(
              icon: Icons.build_rounded,
              size: 22,
              color: _amber.withOpacity(0.6),
            ),
          ),

          // Bottom-right decorative
          Positioned(
            bottom: 40,
            right: 80,
            child: _FloatingElement(
              icon: isSignup ? Icons.favorite_rounded : Icons.star_rounded,
              size: 20,
              color: _amber.withOpacity(0.5),
            ),
          ),

          // Bottom-left decorative
          Positioned(
            bottom: 50,
            left: 75,
            child: _FloatingElement(
              icon: Icons.auto_fix_high_rounded,
              size: 18,
              color: _amber.withOpacity(0.4),
            ),
          ),

          // Small dots
          Positioned(
            top: 65,
            right: 100,
            child: _Dot(color: _amber.withOpacity(0.3), size: 8),
          ),
          Positioned(
            bottom: 70,
            left: 100,
            child: _Dot(color: _amber.withOpacity(0.25), size: 6),
          ),
          Positioned(
            top: 80,
            left: 95,
            child: _Dot(color: _amber.withOpacity(0.2), size: 10),
          ),
        ],
      ),
    );
  }
}

class _FloatingElement extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const _FloatingElement({
    required this.icon,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color);
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double size;

  const _Dot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
