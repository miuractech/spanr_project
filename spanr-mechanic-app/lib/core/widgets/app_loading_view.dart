import 'package:flutter/material.dart';
import '../constants/lottie_assets.dart';
import '../theme/app_theme.dart';
import 'app_lottie.dart';

class AppLoadingView extends StatelessWidget {
  final String? message;

  const AppLoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLottie(asset: LottieAssets.loading, width: 120, height: 120),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(message!, style: const TextStyle(color: AppTheme.textBody)),
          ],
        ],
      ),
    );
  }
}
