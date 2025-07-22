import 'package:flutter/material.dart';

enum ExerciseType { pushup, squat, plank, jumpingJacks, burpees, lunges }

class Exercise {
  final String id;
  final String name;
  final ExerciseType type;
  final int targetReps;
  final int targetSets;
  final Duration? duration; // For time-based exercises like plank
  final String description;
  final String instructions;
  final int xpReward;

  Exercise({
    required this.id,
    required this.name,
    required this.type,
    required this.targetReps,
    required this.targetSets,
    this.duration,
    required this.description,
    required this.instructions,
    this.xpReward = 10,
  });
}

class WorkoutSession {
  final String id;
  final String name;
  final List<Exercise> exercises;
  final DateTime createdAt;
  final int estimatedDuration; // in minutes
  final int totalXP;

  WorkoutSession({
    required this.id,
    required this.name,
    required this.exercises,
    DateTime? createdAt,
    required this.estimatedDuration,
  }) : createdAt = createdAt ?? DateTime.now(),
       totalXP = exercises.fold(0, (sum, exercise) => sum + exercise.xpReward);
}

class WorkoutResult {
  final String sessionId;
  final Map<String, int> completedReps; // exerciseId -> reps completed
  final Map<String, double> formAccuracy; // exerciseId -> accuracy percentage
  final DateTime completedAt;
  final int xpEarned;

  WorkoutResult({
    required this.sessionId,
    required this.completedReps,
    required this.formAccuracy,
    DateTime? completedAt,
    required this.xpEarned,
  }) : completedAt = completedAt ?? DateTime.now();
}

class WorkoutProvider extends ChangeNotifier {
  WorkoutSession? _currentWorkout;
  final List<WorkoutSession> _workoutHistory = [];
  bool _isGeneratingWorkout = false;
  bool _isWorkoutActive = false;
  Exercise? _currentExercise;
  int _currentExerciseIndex = 0;
  final Map<String, int> _currentSessionReps = {};
  final Map<String, double> _currentSessionAccuracy = {};

  // Getters
  WorkoutSession? get currentWorkout => _currentWorkout;
  List<WorkoutSession> get workoutHistory => _workoutHistory;
  bool get isGeneratingWorkout => _isGeneratingWorkout;
  bool get isWorkoutActive => _isWorkoutActive;
  Exercise? get currentExercise => _currentExercise;
  int get currentExerciseIndex => _currentExerciseIndex;
  Map<String, int> get currentSessionReps => _currentSessionReps;
  Map<String, double> get currentSessionAccuracy => _currentSessionAccuracy;

  // Generate a workout based on user preferences
  Future<void> generateWorkout({
    required String goal,
    required String level,
    required List<String> equipment,
  }) async {
    _isGeneratingWorkout = true;
    notifyListeners();

    try {
      // Simulate API call to generate workout
      await Future.delayed(const Duration(seconds: 2));

      // Mock workout generation based on level
      List<Exercise> exercises = _generateMockExercises(level);

      _currentWorkout = WorkoutSession(
        id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Daily ${_capitalizeFirst(goal)} Workout',
        exercises: exercises,
        estimatedDuration: exercises.length * 3, // 3 minutes per exercise
      );

      _isGeneratingWorkout = false;
      notifyListeners();
    } catch (e) {
      _isGeneratingWorkout = false;
      notifyListeners();
      rethrow;
    }
  }

  // Start a workout session
  void startWorkout() {
    if (_currentWorkout != null && _currentWorkout!.exercises.isNotEmpty) {
      _isWorkoutActive = true;
      _currentExerciseIndex = 0;
      _currentExercise = _currentWorkout!.exercises[0];
      _currentSessionReps.clear();
      _currentSessionAccuracy.clear();
      notifyListeners();
    }
  }

  // Move to next exercise
  void nextExercise() {
    if (_currentWorkout != null &&
        _currentExerciseIndex < _currentWorkout!.exercises.length - 1) {
      _currentExerciseIndex++;
      _currentExercise = _currentWorkout!.exercises[_currentExerciseIndex];
      notifyListeners();
    }
  }

  // Update exercise progress
  void updateExerciseProgress(String exerciseId, int reps, double accuracy) {
    _currentSessionReps[exerciseId] = reps;
    _currentSessionAccuracy[exerciseId] = accuracy;
    notifyListeners();
  }

  // Complete workout session
  WorkoutResult completeWorkout() {
    if (_currentWorkout == null) {
      throw Exception('No active workout session');
    }

    final totalXP = _calculateXPEarned();
    final result = WorkoutResult(
      sessionId: _currentWorkout!.id,
      completedReps: Map.from(_currentSessionReps),
      formAccuracy: Map.from(_currentSessionAccuracy),
      xpEarned: totalXP,
    );

    _workoutHistory.add(_currentWorkout!);
    _isWorkoutActive = false;
    _currentWorkout = null;
    _currentExercise = null;
    _currentExerciseIndex = 0;
    _currentSessionReps.clear();
    _currentSessionAccuracy.clear();

    notifyListeners();
    return result;
  }

  // Cancel current workout
  void cancelWorkout() {
    _isWorkoutActive = false;
    _currentWorkout = null;
    _currentExercise = null;
    _currentExerciseIndex = 0;
    _currentSessionReps.clear();
    _currentSessionAccuracy.clear();
    notifyListeners();
  }

  // Helper methods
  List<Exercise> _generateMockExercises(String level) {
    final baseExercises = [
      Exercise(
        id: 'pushup_1',
        name: 'Push-ups',
        type: ExerciseType.pushup,
        targetReps: level == 'beginner'
            ? 10
            : level == 'intermediate'
            ? 15
            : 20,
        targetSets: level == 'beginner' ? 2 : 3,
        description: 'Classic upper body exercise',
        instructions:
            'Keep your body straight, lower chest to ground, push back up',
        xpReward: 15,
      ),
      Exercise(
        id: 'squat_1',
        name: 'Squats',
        type: ExerciseType.squat,
        targetReps: level == 'beginner'
            ? 15
            : level == 'intermediate'
            ? 20
            : 25,
        targetSets: level == 'beginner' ? 2 : 3,
        description: 'Lower body strength exercise',
        instructions:
            'Feet shoulder-width apart, lower hips back and down, return to standing',
        xpReward: 15,
      ),
      Exercise(
        id: 'plank_1',
        name: 'Plank',
        type: ExerciseType.plank,
        targetReps: 1,
        targetSets: level == 'beginner' ? 2 : 3,
        duration: Duration(
          seconds: level == 'beginner'
              ? 30
              : level == 'intermediate'
              ? 45
              : 60,
        ),
        description: 'Core stability exercise',
        instructions:
            'Hold body straight in plank position, engage core muscles',
        xpReward: 20,
      ),
    ];

    return baseExercises.take(level == 'beginner' ? 2 : 3).toList();
  }

  int _calculateXPEarned() {
    int totalXP = 0;
    for (final exercise in _currentWorkout!.exercises) {
      final completedReps = _currentSessionReps[exercise.id] ?? 0;
      final accuracy = _currentSessionAccuracy[exercise.id] ?? 0.0;

      // Base XP for completion
      if (completedReps > 0) {
        totalXP += exercise.xpReward;

        // Bonus XP for good form (accuracy > 80%)
        if (accuracy > 0.8) {
          totalXP += (exercise.xpReward * 0.5).round();
        }
      }
    }
    return totalXP;
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Get today's recommended workout
  WorkoutSession? getTodaysWorkout() {
    // This would typically fetch from an API or local storage
    // For now, return null to trigger workout generation
    return null;
  }

  // Get workout statistics
  Map<String, dynamic> getWorkoutStats() {
    final totalWorkouts = _workoutHistory.length;
    final totalXP = _workoutHistory.fold(
      0,
      (sum, workout) => sum + workout.totalXP,
    );
    final averageAccuracy = _workoutHistory.isEmpty
        ? 0.0
        : _workoutHistory.map((w) => 0.85).reduce((a, b) => a + b) /
              _workoutHistory.length; // Mock data

    return {
      'totalWorkouts': totalWorkouts,
      'totalXP': totalXP,
      'averageAccuracy': averageAccuracy,
      'currentStreak': 5, // Mock data
    };
  }
}
