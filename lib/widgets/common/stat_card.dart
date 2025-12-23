import 'package:flutter/material.dart';
import '../../config/theme.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.headingSmall.copyWith(
            color: Theme.of(context).textTheme.displaySmall?.color)),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.bodySmall.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}
