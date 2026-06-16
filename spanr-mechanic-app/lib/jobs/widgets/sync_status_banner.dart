import 'package:flutter/material.dart';

class SyncStatusBanner extends StatelessWidget {
  final bool isOnline;
  final int pendingCount;

  const SyncStatusBanner({
    super.key,
    required this.isOnline,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline && pendingCount == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isOnline ? Colors.orange.shade100 : Colors.red.shade100,
      child: Text(
        isOnline
            ? 'Syncing $pendingCount pending change(s)...'
            : 'Offline — changes will sync when connected',
        style: TextStyle(
          fontSize: 13,
          color: isOnline ? Colors.orange.shade900 : Colors.red.shade900,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
