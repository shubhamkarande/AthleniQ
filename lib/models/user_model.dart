class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final double? height; // in cm
  final double? weight; // in kg
  final int? age;
  final String? goal;
  final DateTime? createdAt;
  final int workoutStreak;
  final int totalWorkouts;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.height,
    this.weight,
    this.age,
    this.goal,
    this.createdAt,
    this.workoutStreak = 0,
    this.totalWorkouts = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      age: json['age'],
      goal: json['goal'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      workoutStreak: json['workoutStreak'] ?? 0,
      totalWorkouts: json['totalWorkouts'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'height': height,
      'weight': weight,
      'age': age,
      'goal': goal,
      'createdAt': createdAt?.toIso8601String(),
      'workoutStreak': workoutStreak,
      'totalWorkouts': totalWorkouts,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    double? height,
    double? weight,
    int? age,
    String? goal,
    DateTime? createdAt,
    int? workoutStreak,
    int? totalWorkouts,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
      workoutStreak: workoutStreak ?? this.workoutStreak,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
    );
  }

  bool get isProfileComplete => 
      height != null && 
      weight != null && 
      age != null && 
      goal != null;
}
