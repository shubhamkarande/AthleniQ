import 'package:flutter/material.dart';
import '../../config/theme.dart';

class RepCounter extends StatelessWidget {
  final int count;
  final double formScore;

  const RepCounter({
    super.key,
    required this.count,
    required this.formScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _getScoreColor().withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Text(
                '$count',
                style: AppTheme.headingLarge.copyWith(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'REPS',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Container(
            width: 1,
            height: 50,
            color: Colors.white24,
          ),
          const SizedBox(width: 24),
          Column(
            children: [
              Text(
                '${(formScore * 100).round()}%',
                style: AppTheme.headingSmall.copyWith(
                  color: _getScoreColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'FORM',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor() {
    if (formScore >= 0.8) return AppTheme.successColor;
    if (formScore >= 0.5) return AppTheme.warningColor;
    return AppTheme.accentColor;
  }
}
