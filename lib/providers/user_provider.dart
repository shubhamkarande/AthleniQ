import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null);

  Future<void> updateProfile({
    required int age,
    required double height,
    required double weight,
    required String goal,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    state = UserModel(
      uid: state?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: state?.email ?? 'user@athleniq.com',
      displayName: state?.displayName ?? 'Athlete',
      age: age,
      height: height,
      weight: weight,
      goal: goal,
      createdAt: DateTime.now(),
      workoutStreak: 0,
      totalWorkouts: 0,
    );
  }

  void setUser(UserModel user) {
    state = user;
  }

  void incrementStreak() {
    if (state != null) {
      state = state!.copyWith(workoutStreak: state!.workoutStreak + 1);
    }
  }

  void incrementWorkouts() {
    if (state != null) {
      state = state!.copyWith(totalWorkouts: state!.totalWorkouts + 1);
    }
  }

  void signOut() {
    state = null;
  }
}
