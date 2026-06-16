import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'spanr_brand_mark.dart';

class AuthHeader extends StatelessWidget {
  final String description;

  const AuthHeader({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SpanrBrandMark(size: 100, showSubtitle: true),
        const SizedBox(height: 20),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppTheme.textBody, height: 1.4),
        ),
      ],
    );
  }
}
