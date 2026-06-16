import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SpanrBrandMark extends StatelessWidget {
  final double size;
  final bool showSubtitle;

  const SpanrBrandMark({
    super.key,
    this.size = 120,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF9A3D), AppTheme.primaryOrange],
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryOrange.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.directions_car_filled_rounded,
                size: size * 0.42,
                color: Colors.white.withValues(alpha: 0.95),
              ),
              Positioned(
                right: size * 0.18,
                bottom: size * 0.2,
                child: Container(
                  padding: EdgeInsets.all(size * 0.07),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size * 0.12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.build_rounded,
                    size: size * 0.2,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size * 0.22),
        Text(
          'SPANR',
          style: TextStyle(
            fontSize: size * 0.3,
            fontWeight: FontWeight.w800,
            color: AppTheme.textHeading,
            letterSpacing: 2,
          ),
        ),
        if (showSubtitle) ...[
          SizedBox(height: size * 0.06),
          Text(
            'Mechanic App',
            style: TextStyle(
              fontSize: size * 0.14,
              color: AppTheme.textBody,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
