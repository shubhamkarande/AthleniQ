import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/workout_provider.dart';
import '../core/providers/user_provider.dart';
import '../core/theme/app_theme.dart';

class CameraWorkoutPage extends StatefulWidget {
  const CameraWorkoutPage({super.key});

  @override
  State<CameraWorkoutPage> createState() => _CameraWorkoutPageState();
}

class _CameraWorkoutPageState extends State<CameraWorkoutPage> {
  int _currentReps = 0;
  double _currentAccuracy = 0.85; // Mock accuracy
  bool _isPaused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          final currentExercise = workoutProvider.currentExercise;
          if (currentExercise == null) {
            return const Center(
              child: Text(
                'No active exercise',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SafeArea(
            child: Stack(
              children: [
                // Camera placeholder (full screen)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[900],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 80, color: Colors.white54),
                        SizedBox(height: 16),
                        Text(
                          'Camera Feed',
                          style: TextStyle(color: Colors.white54, fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Real-time pose detection will be implemented here',
                          style: TextStyle(color: Colors.white38, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Top overlay - Exercise info
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildTopOverlay(currentExercise, workoutProvider),
                ),

                // Bottom overlay - Controls and feedback
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomOverlay(currentExercise, workoutProvider),
                ),

                // Feedback overlay (center)
                if (!_isPaused)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.3,
                    left: 16,
                    right: 16,
                    child: _buildFeedbackOverlay(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopOverlay(Exercise exercise, WorkoutProvider workoutProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _showExitDialog(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isPaused = !_isPaused;
                  });
                },
                icon: Icon(
                  _isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatChip(
                'Exercise ${workoutProvider.currentExerciseIndex + 1}/${workoutProvider.currentWorkout!.exercises.length}',
              ),
              if (exercise.duration != null)
                _buildStatChip('${exercise.duration!.inSeconds}s')
              else
                _buildStatChip(
                  '${exercise.targetReps} reps × ${exercise.targetSets} sets',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFeedbackOverlay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Rep counter
          Text(
            '$_currentReps',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'REPS',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),

          // Form accuracy
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _currentAccuracy > 0.8 ? Icons.check_circle : Icons.warning,
                color: _currentAccuracy > 0.8
                    ? AppTheme.successGreen
                    : AppTheme.warningYellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Form: ${(_currentAccuracy * 100).toInt()}%',
                style: TextStyle(
                  color: _currentAccuracy > 0.8
                      ? AppTheme.successGreen
                      : AppTheme.warningYellow,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Feedback message
          Text(
            _getFeedbackMessage(),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOverlay(
    Exercise exercise,
    WorkoutProvider workoutProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: _currentReps / exercise.targetReps,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.energeticOrange,
            ),
          ),
          const SizedBox(height: 16),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Skip exercise
              TextButton(
                onPressed: () => _skipExercise(workoutProvider),
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.white70),
                ),
              ),

              // Manual rep counter (for demo)
              ElevatedButton(
                onPressed: _isPaused
                    ? null
                    : () => _addRep(exercise, workoutProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.energeticOrange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Add Rep'),
              ),

              // Next exercise
              TextButton(
                onPressed: _currentReps >= exercise.targetReps
                    ? () => _nextExercise(workoutProvider)
                    : null,
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: _currentReps >= exercise.targetReps
                        ? Colors.white
                        : Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFeedbackMessage() {
    if (_isPaused) return 'Workout paused';

    if (_currentAccuracy > 0.9) {
      return 'Perfect form! Keep it up!';
    } else if (_currentAccuracy > 0.8) {
      return 'Good form, maintain position';
    } else if (_currentAccuracy > 0.6) {
      return 'Adjust your posture slightly';
    } else {
      return 'Check your form and slow down';
    }
  }

  void _addRep(Exercise exercise, WorkoutProvider workoutProvider) {
    setState(() {
      _currentReps++;
      // Simulate varying accuracy
      _currentAccuracy = 0.7 + (0.3 * (1 - (_currentReps % 3) / 3));
    });

    workoutProvider.updateExerciseProgress(
      exercise.id,
      _currentReps,
      _currentAccuracy,
    );

    if (_currentReps >= exercise.targetReps) {
      _showExerciseComplete(exercise, workoutProvider);
    }
  }

  void _skipExercise(WorkoutProvider workoutProvider) {
    _nextExercise(workoutProvider);
  }

  void _nextExercise(WorkoutProvider workoutProvider) {
    if (workoutProvider.currentExerciseIndex <
        workoutProvider.currentWorkout!.exercises.length - 1) {
      workoutProvider.nextExercise();
      setState(() {
        _currentReps = 0;
        _currentAccuracy = 0.85;
      });
    } else {
      _completeWorkout(workoutProvider);
    }
  }

  void _showExerciseComplete(
    Exercise exercise,
    WorkoutProvider workoutProvider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppTheme.successGreen, size: 48),
            const SizedBox(height: 16),
            Text('Great job on ${exercise.name}!'),
            const SizedBox(height: 8),
            Text('Reps: $_currentReps/${exercise.targetReps}'),
            Text('Accuracy: ${(_currentAccuracy * 100).toInt()}%'),
            Text('XP Earned: +${exercise.xpReward}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextExercise(workoutProvider);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _completeWorkout(WorkoutProvider workoutProvider) {
    final result = workoutProvider.completeWorkout();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.addXP(result.xpEarned);

    Navigator.of(context).pop(); // Return to workout page
    _showWorkoutComplete(result);
  }

  void _showWorkoutComplete(WorkoutResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Workout Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, color: AppTheme.energeticOrange, size: 48),
            const SizedBox(height: 16),
            const Text('Congratulations on completing your workout!'),
            const SizedBox(height: 16),
            Text('Total XP Earned: +${result.xpEarned}'),
            Text(
              'Average Accuracy: ${(result.formAccuracy.values.fold(0.0, (a, b) => a + b) / result.formAccuracy.length * 100).toInt()}%',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Workout?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final workoutProvider = Provider.of<WorkoutProvider>(
                context,
                listen: false,
              );
              workoutProvider.cancelWorkout();
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit workout
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
