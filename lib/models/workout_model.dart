class WorkoutModel {
  final String? id;
  final String userId;
  final String exercise;
  final String exerciseName;
  final int reps;
  final int sets;
  final double formScore;
  final double calories;
  final int durationSeconds;
  final DateTime timestamp;
  final List<String> feedback;

  const WorkoutModel({
    this.id,
    required this.userId,
    required this.exercise,
    required this.exerciseName,
    this.reps = 0,
    this.sets = 0,
    this.formScore = 0.0,
    this.calories = 0.0,
    this.durationSeconds = 0,
    required this.timestamp,
    this.feedback = const [],
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      userId: json['userId'] ?? json['user_id'] ?? '',
      exercise: json['exercise'] ?? '',
      exerciseName: json['exerciseName'] ?? json['exercise_name'] ?? '',
      reps: json['reps'] ?? 0,
      sets: json['sets'] ?? 0,
      formScore: (json['formScore'] ?? json['form_score'] ?? 0).toDouble(),
      calories: (json['calories'] ?? 0).toDouble(),
      durationSeconds: json['durationSeconds'] ?? json['duration_seconds'] ?? 0,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      feedback: List<String>.from(json['feedback'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exercise': exercise,
      'exerciseName': exerciseName,
      'reps': reps,
      'sets': sets,
      'formScore': formScore,
      'calories': calories,
      'durationSeconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
      'feedback': feedback,
    };
  }

  WorkoutModel copyWith({
    String? id,
    String? userId,
    String? exercise,
    String? exerciseName,
    int? reps,
    int? sets,
    double? formScore,
    double? calories,
    int? durationSeconds,
    DateTime? timestamp,
    List<String>? feedback,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exercise: exercise ?? this.exercise,
      exerciseName: exerciseName ?? this.exerciseName,
      reps: reps ?? this.reps,
      sets: sets ?? this.sets,
      formScore: formScore ?? this.formScore,
      calories: calories ?? this.calories,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      timestamp: timestamp ?? this.timestamp,
      feedback: feedback ?? this.feedback,
    );
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get performanceRating {
    if (formScore >= 0.9) return 'Excellent';
    if (formScore >= 0.75) return 'Great';
    if (formScore >= 0.6) return 'Good';
    if (formScore >= 0.4) return 'Fair';
    return 'Needs Work';
  }
}
