import 'package:flutter/material.dart';
import 'package:tracking_practice/core/constants/app_sizes.dart';

class BaseEmptyState extends StatelessWidget {
  const BaseEmptyState({
    required this.message,
    super.key,
    this.icon = Icons.info_outline,
    this.iconColor = Colors.grey,
    this.iconSize = Sizes.p48,
  });

  final String message;
  final IconData icon;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          gapH16,
          Text(message),
        ],
      ),
    );
  }
}
