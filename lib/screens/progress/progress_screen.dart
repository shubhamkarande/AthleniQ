import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/common/stat_card.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutHistoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly summary
            Text('This Week', style: AppTheme.headingSmall.copyWith(
              color: Theme.of(context).textTheme.displaySmall?.color))
              .animate().fadeIn(),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: StatCard(
                  icon: Icons.fitness_center,
                  value: '${workouts.length}',
                  label: 'Workouts',
                  color: AppTheme.primaryColor,
                )),
                const SizedBox(width: 12),
                Expanded(child: StatCard(
                  icon: Icons.local_fire_department,
                  value: '${_totalCalories(workouts)}',
                  label: 'Calories',
                  color: AppTheme.accentColor,
                )),
              ],
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
            
            const SizedBox(height: 32),
            
            // Chart
            Text('Form Score Trend', style: AppTheme.headingSmall.copyWith(
              color: Theme.of(context).textTheme.displaySmall?.color))
              .animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 16),
            
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: workouts.isEmpty
                ? Center(child: Text('Complete workouts to see trends',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color)))
                : LineChart(_buildChart(workouts)),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
            
            const SizedBox(height: 32),
            
            // Recent workouts
            Text('Recent Workouts', style: AppTheme.headingSmall.copyWith(
              color: Theme.of(context).textTheme.displaySmall?.color))
              .animate(delay: 400.ms).fadeIn(),
            const SizedBox(height: 16),
            
            if (workouts.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.fitness_center, size: 48, color: AppTheme.primaryColor),
                    const SizedBox(height: 16),
                    Text('No workouts yet', style: AppTheme.labelLarge.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
                    const SizedBox(height: 8),
                    Text('Start your first workout!', style: AppTheme.bodyMedium.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
              ).animate(delay: 500.ms).fadeIn()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: workouts.length.clamp(0, 10),
                itemBuilder: (context, index) => _WorkoutHistoryItem(
                  workout: workouts[index],
                  delay: Duration(milliseconds: 500 + (index * 100)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _totalCalories(List workouts) {
    if (workouts.isEmpty) return 0;
    return workouts.fold(0, (sum, w) => sum + (w.calories as num).round());
  }

  LineChartData _buildChart(List workouts) {
    final spots = workouts.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value.formScore as num).toDouble() * 100);
    }).toList();
    
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
          isCurved: true,
          color: AppTheme.primaryColor,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.primaryColor.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}

class _WorkoutHistoryItem extends StatelessWidget {
  final dynamic workout;
  final Duration delay;

  const _WorkoutHistoryItem({required this.workout, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fitness_center, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.exerciseName ?? 'Workout',
                  style: AppTheme.labelLarge.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: 4),
                Text('${workout.reps ?? 0} reps • ${((workout.formScore ?? 0) * 100).round()}% form',
                  style: AppTheme.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          ),
          Text('${(workout.calories ?? 0).round()} cal',
            style: AppTheme.labelLarge.copyWith(color: AppTheme.accentColor)),
        ],
      ),
    ).animate(delay: delay).fadeIn().slideX(begin: 0.1);
  }
}
