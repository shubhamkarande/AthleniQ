import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/workout_provider.dart';
import '../core/providers/user_provider.dart';
import '../core/theme/app_theme.dart';
import 'camera_workout_page.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndGenerateWorkout();
    });
  }

  void _checkAndGenerateWorkout() {
    final workoutProvider = Provider.of<WorkoutProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (workoutProvider.currentWorkout == null &&
        userProvider.userProfile != null) {
      final user = userProvider.userProfile!;
      workoutProvider.generateWorkout(
        goal: user.goal.name,
        level: user.level.name,
        equipment: user.availableEquipment,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout'), centerTitle: true),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          if (workoutProvider.isGeneratingWorkout) {
            return _buildLoadingState();
          }

          if (workoutProvider.currentWorkout == null) {
            return _buildGenerateWorkoutState(workoutProvider);
          }

          if (workoutProvider.isWorkoutActive) {
            return _buildActiveWorkoutState(workoutProvider);
          }

          return _buildWorkoutPreview(workoutProvider);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Generating your personalized workout...',
            style: TextStyle(fontSize: 16, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateWorkoutState(WorkoutProvider workoutProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 60,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ready for your workout?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Let\'s generate a personalized workout based on your goals and fitness level.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppTheme.textLight),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _generateWorkout(workoutProvider),
                child: const Text('Generate Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutPreview(WorkoutProvider workoutProvider) {
    final workout = workoutProvider.currentWorkout!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.estimatedDuration} min',
                        style: const TextStyle(color: AppTheme.textLight),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.star, size: 16, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.totalXP} XP',
                        style: const TextStyle(color: AppTheme.textLight),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.exercises.length} exercises',
                        style: const TextStyle(color: AppTheme.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Exercise list
          const Text(
            'Exercises',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...workout.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            return _buildExerciseCard(exercise, index + 1);
          }),
          const SizedBox(height: 24),

          // Start workout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startWorkout(workoutProvider),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.energeticOrange,
              ),
              child: const Text(
                'Start Workout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Generate new workout button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _generateWorkout(workoutProvider),
              child: const Text('Generate New Workout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, int number) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        exercise.description,
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.energeticOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${exercise.xpReward} XP',
                    style: const TextStyle(
                      color: AppTheme.energeticOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (exercise.duration != null) ...[
                  Icon(Icons.timer, size: 16, color: AppTheme.textLight),
                  const SizedBox(width: 4),
                  Text(
                    '${exercise.duration!.inSeconds}s',
                    style: const TextStyle(color: AppTheme.textLight),
                  ),
                ] else ...[
                  Icon(Icons.repeat, size: 16, color: AppTheme.textLight),
                  const SizedBox(width: 4),
                  Text(
                    '${exercise.targetReps} reps × ${exercise.targetSets} sets',
                    style: const TextStyle(color: AppTheme.textLight),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              exercise.instructions,
              style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveWorkoutState(WorkoutProvider workoutProvider) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 80, color: AppTheme.primaryBlue),
          SizedBox(height: 16),
          Text(
            'Workout in Progress',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Camera workout view will be implemented next',
            style: TextStyle(color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  void _generateWorkout(WorkoutProvider workoutProvider) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.userProfile;

    if (user != null) {
      workoutProvider.generateWorkout(
        goal: user.goal.name,
        level: user.level.name,
        equipment: user.availableEquipment,
      );
    }
  }

  void _startWorkout(WorkoutProvider workoutProvider) {
    workoutProvider.startWorkout();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CameraWorkoutPage()));
  }
}
