import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_model.dart';

final workoutHistoryProvider = StateNotifierProvider<WorkoutHistoryNotifier, List<WorkoutModel>>((ref) {
  return WorkoutHistoryNotifier();
});

final currentWorkoutProvider = StateProvider<WorkoutModel?>((ref) => null);

class WorkoutHistoryNotifier extends StateNotifier<List<WorkoutModel>> {
  WorkoutHistoryNotifier() : super([]);

  void addWorkout(Map<String, dynamic> data) {
    final workout = WorkoutModel(
      id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
      userId: data['userId'] ?? 'guest',
      exercise: data['exercise'] ?? '',
      exerciseName: data['exerciseName'] ?? '',
      reps: data['reps'] ?? 0,
      formScore: (data['formScore'] ?? 0).toDouble(),
      calories: (data['calories'] ?? 0).toDouble(),
      durationSeconds: data['durationSeconds'] ?? 0,
      timestamp: DateTime.now(),
      feedback: List<String>.from(data['feedback'] ?? []),
    );
    state = [workout, ...state];
  }

  void clearHistory() {
    state = [];
  }
}
