import 'package:flutter/material.dart';
import 'package:tracking_practice/core/constants/app_sizes.dart';

class BaseErrorState extends StatelessWidget {
  const BaseErrorState({
    super.key,
    required this.error,
    this.icon = Icons.error_outline,
    this.iconColor = Colors.red,
    this.iconSize = Sizes.p48,
  });

  final String error;
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
          Text('Error: $error'),
        ],
      ),
    );
  }
}