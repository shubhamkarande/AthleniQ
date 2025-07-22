import 'package:flutter/material.dart';

enum FitnessGoal { weightLoss, muscleGain, endurance, flexibility, general }

enum FitnessLevel { beginner, intermediate, advanced }

class UserProfile {
  final String id;
  final String name;
  final String email;
  final FitnessGoal goal;
  final FitnessLevel level;
  final List<String> availableEquipment;
  final int xp;
  final int currentLevel;
  final DateTime joinDate;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.goal,
    required this.level,
    required this.availableEquipment,
    this.xp = 0,
    this.currentLevel = 1,
    DateTime? joinDate,
  }) : joinDate = joinDate ?? DateTime.now();

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    FitnessGoal? goal,
    FitnessLevel? level,
    List<String>? availableEquipment,
    int? xp,
    int? currentLevel,
    DateTime? joinDate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      xp: xp ?? this.xp,
      currentLevel: currentLevel ?? this.currentLevel,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}

class UserProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;

  // Getters
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get hasCompletedOnboarding => _userProfile != null;

  // Create user profile during onboarding
  Future<void> createUserProfile({
    required String id,
    required String name,
    required String email,
    required FitnessGoal goal,
    required FitnessLevel level,
    required List<String> availableEquipment,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _userProfile = UserProfile(
        id: id,
        name: name,
        email: email,
        goal: goal,
        level: level,
        availableEquipment: availableEquipment,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add XP to user
  void addXP(int points) {
    if (_userProfile != null) {
      final newXP = _userProfile!.xp + points;
      final newLevel = (newXP / 100).floor() + 1; // Level up every 100 XP

      _userProfile = _userProfile!.copyWith(xp: newXP, currentLevel: newLevel);
      notifyListeners();
    }
  }

  // Update user profile
  void updateProfile(UserProfile updatedProfile) {
    _userProfile = updatedProfile;
    notifyListeners();
  }

  // Clear user data on logout
  void clearUserData() {
    _userProfile = null;
    notifyListeners();
  }

  // Helper methods for UI
  String get goalDisplayName {
    switch (_userProfile?.goal) {
      case FitnessGoal.weightLoss:
        return 'Weight Loss';
      case FitnessGoal.muscleGain:
        return 'Muscle Gain';
      case FitnessGoal.endurance:
        return 'Endurance';
      case FitnessGoal.flexibility:
        return 'Flexibility';
      case FitnessGoal.general:
        return 'General Fitness';
      default:
        return 'Not Set';
    }
  }

  String get levelDisplayName {
    switch (_userProfile?.level) {
      case FitnessLevel.beginner:
        return 'Beginner';
      case FitnessLevel.intermediate:
        return 'Intermediate';
      case FitnessLevel.advanced:
        return 'Advanced';
      default:
        return 'Not Set';
    }
  }

  int get xpToNextLevel {
    if (_userProfile == null) return 0;
    return 100 - (_userProfile!.xp % 100);
  }

  double get levelProgress {
    if (_userProfile == null) return 0.0;
    return (_userProfile!.xp % 100) / 100.0;
  }
}
