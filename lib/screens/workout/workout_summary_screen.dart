import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/common/primary_button.dart';

class WorkoutSummaryScreen extends ConsumerWidget {
  final Map<String, dynamic> workoutData;

  const WorkoutSummaryScreen({super.key, required this.workoutData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reps = workoutData['reps'] ?? 0;
    final formScore = (workoutData['formScore'] ?? 0.0) as double;
    final calories = (workoutData['calories'] ?? 0.0) as double;
    final duration = workoutData['durationSeconds'] ?? 0;
    final exerciseName = workoutData['exerciseName'] ?? 'Workout';
    final rating = _getPerformanceRating(formScore);
    final ratingColor = _getRatingColor(formScore);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildTrophy(ratingColor, formScore),
                const SizedBox(height: 24),
                Text('Workout Complete! 🎉',
                    style: AppTheme.headingMedium.copyWith(color: Colors.white))
                    .animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 8),
                Text(exerciseName,
                    style: AppTheme.bodyLarge.copyWith(color: Colors.white70)),
                const SizedBox(height: 32),
                _buildRatingCard(rating, formScore, ratingColor),
                const SizedBox(height: 24),
                _buildStatsRow(reps, calories, duration),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Continue',
                  onPressed: () {
                    ref.read(workoutHistoryProvider.notifier).addWorkout(workoutData);
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context, AppRoutes.workoutSession, arguments: workoutData),
                  child: Text('Do Another Set',
                      style: AppTheme.labelLarge.copyWith(color: AppTheme.secondaryColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrophy(Color color, double score) {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 30)],
      ),
      child: Icon(score >= 0.75 ? Icons.emoji_events : Icons.fitness_center,
          size: 50, color: Colors.white),
    ).animate().fadeIn().scale(begin: const Offset(0.5, 0.5));
  }

  Widget _buildRatingCard(String rating, double score, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('Performance', style: AppTheme.bodyMedium.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(rating, style: AppTheme.headingLarge.copyWith(color: color, fontSize: 36)),
          const SizedBox(height: 8),
          Text('${(score * 100).round()}% Form Score',
              style: AppTheme.bodyLarge.copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int reps, double calories, int duration) {
    return Row(
      children: [
        Expanded(child: _StatBox(Icons.repeat, '$reps', 'Reps', AppTheme.primaryColor)),
        const SizedBox(width: 16),
        Expanded(child: _StatBox(Icons.local_fire_department, '${calories.round()}', 'Cal', AppTheme.accentColor)),
        const SizedBox(width: 16),
        Expanded(child: _StatBox(Icons.timer, '${duration ~/ 60}m', 'Time', AppTheme.successColor)),
      ],
    );
  }

  String _getPerformanceRating(double s) => s >= 0.9 ? 'Excellent' : s >= 0.75 ? 'Great' : s >= 0.6 ? 'Good' : 'Fair';
  Color _getRatingColor(double s) => s >= 0.75 ? AppTheme.successColor : s >= 0.5 ? AppTheme.warningColor : AppTheme.accentColor;
}

class _StatBox extends StatelessWidget {
  final IconData icon; final String value; final String label; final Color color;
  const _StatBox(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: AppTheme.headingSmall.copyWith(color: Colors.white)),
        Text(label, style: AppTheme.bodySmall.copyWith(color: Colors.white70)),
      ]),
    );
  }
}
