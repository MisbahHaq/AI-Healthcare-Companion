import 'package:flutter/material.dart';

class MiningButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isMining;

  const MiningButton({
    super.key,
    required this.onPressed,
    required this.isMining,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(isMining ? Icons.sync : Icons.construction),
      label: Text(isMining ? "Mining..." : "Start Mining"),
      onPressed: isMining ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
