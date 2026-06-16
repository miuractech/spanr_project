import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class WorkflowActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final IconData? icon;

  const WorkflowActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    if (primary) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: onPressed, child: child),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryOrange,
          side: const BorderSide(color: AppTheme.primaryOrange),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: child,
      ),
    );
  }
}
