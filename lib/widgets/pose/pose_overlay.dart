import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PoseOverlay extends StatelessWidget {
  final List<dynamic> landmarks;
  final double formScore;

  const PoseOverlay({
    super.key,
    required this.landmarks,
    required this.formScore,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PosePainter(
        landmarks: landmarks,
        formScore: formScore,
      ),
      size: Size.infinite,
    );
  }
}

class PosePainter extends CustomPainter {
  final List<dynamic> landmarks;
  final double formScore;

  PosePainter({required this.landmarks, required this.formScore});

  // Pose landmark connections for skeleton
  static const List<List<int>> connections = [
    [11, 13], [13, 15], // Left arm
    [12, 14], [14, 16], // Right arm
    [11, 12], // Shoulders
    [11, 23], [12, 24], // Torso
    [23, 24], // Hips
    [23, 25], [25, 27], // Left leg
    [24, 26], [26, 28], // Right leg
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Color based on form score
    final color = formScore >= 0.8
        ? AppTheme.successColor
        : formScore >= 0.5
            ? AppTheme.warningColor
            : AppTheme.accentColor;

    paint.color = color;

    // Draw connections
    for (final connection in connections) {
      if (connection[0] < landmarks.length && connection[1] < landmarks.length) {
        final p1 = landmarks[connection[0]];
        final p2 = landmarks[connection[1]];
        
        final x1 = (p1['x'] as num).toDouble() * size.width;
        final y1 = (p1['y'] as num).toDouble() * size.height;
        final x2 = (p2['x'] as num).toDouble() * size.width;
        final y2 = (p2['y'] as num).toDouble() * size.height;

        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }

    // Draw landmark points
    paint.style = PaintingStyle.fill;
    for (final landmark in landmarks) {
      final x = (landmark['x'] as num).toDouble() * size.width;
      final y = (landmark['y'] as num).toDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 6, paint);
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) => true;
}
