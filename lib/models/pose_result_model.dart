class PoseResultModel {
  final bool success;
  final List<Landmark> landmarks;
  final List<JointAngle> jointAngles;
  final double formScore;
  final bool repCounted;
  final List<String> feedback;
  final String? error;

  const PoseResultModel({
    required this.success,
    this.landmarks = const [],
    this.jointAngles = const [],
    this.formScore = 0.0,
    this.repCounted = false,
    this.feedback = const [],
    this.error,
  });

  factory PoseResultModel.fromJson(Map<String, dynamic> json) {
    return PoseResultModel(
      success: json['success'] ?? false,
      landmarks: (json['landmarks'] as List<dynamic>?)
          ?.map((l) => Landmark.fromJson(l))
          .toList() ?? [],
      jointAngles: (json['joint_angles'] as List<dynamic>?)
          ?.map((j) => JointAngle.fromJson(j))
          .toList() ?? [],
      formScore: (json['form_score'] ?? 0).toDouble(),
      repCounted: json['rep_counted'] ?? false,
      feedback: List<String>.from(json['feedback'] ?? []),
      error: json['error'],
    );
  }
}

class Landmark {
  final double x;
  final double y;
  final double z;
  final double visibility;

  const Landmark({
    required this.x,
    required this.y,
    this.z = 0,
    this.visibility = 1.0,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      z: (json['z'] ?? 0).toDouble(),
      visibility: (json['visibility'] ?? 1).toDouble(),
    );
  }
}

class JointAngle {
  final String name;
  final double angle;
  final bool isCorrect;
  final String? feedback;

  const JointAngle({
    required this.name,
    required this.angle,
    this.isCorrect = false,
    this.feedback,
  });

  factory JointAngle.fromJson(Map<String, dynamic> json) {
    return JointAngle(
      name: json['name'] ?? '',
      angle: (json['angle'] ?? 0).toDouble(),
      isCorrect: json['is_correct'] ?? false,
      feedback: json['feedback'],
    );
  }
}
