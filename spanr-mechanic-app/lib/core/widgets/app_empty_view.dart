import 'package:flutter/material.dart';
import '../constants/lottie_assets.dart';
import '../theme/app_theme.dart';
import 'app_lottie.dart';

class AppEmptyView extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String lottieAsset;

  const AppEmptyView({
    super.key,
    required this.title,
    this.subtitle,
    this.lottieAsset = LottieAssets.emptyJobs,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLottie(asset: lottieAsset, width: 180, height: 150),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textHeading,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.textBody),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
