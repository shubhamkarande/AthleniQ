import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:vibration/vibration.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../providers/workout_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/pose/pose_overlay.dart';
import '../../widgets/pose/rep_counter.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final String exerciseType;
  final String exerciseName;

  const WorkoutSessionScreen({
    super.key,
    required this.exerciseType,
    required this.exerciseName,
  });

  @override
  ConsumerState<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isWorkoutActive = false;
  
  // Workout metrics
  int _repCount = 0;
  double _formScore = 0.0;
  List<String> _feedback = [];
  int _elapsedSeconds = 0;
  Timer? _timer;
  
  // Pose data for overlay
  List<dynamic> _landmarks = [];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cameras available')),
          );
        }
        return;
      }

      // Use front camera for exercise tracking
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutActive = true;
      _repCount = 0;
      _formScore = 0.0;
      _elapsedSeconds = 0;
    });

    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsedSeconds++);
    });

    // Start frame processing
    _startFrameProcessing();
  }

  void _startFrameProcessing() {
    if (_cameraController == null) return;

    // Process frames periodically
    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (!_isWorkoutActive || _isProcessing) {
        if (!_isWorkoutActive) timer.cancel();
        return;
      }

      _isProcessing = true;
      
      try {
        final image = await _cameraController!.takePicture();
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        final result = await ApiService.analyzePose(
          imageBase64: base64Image,
          exerciseType: widget.exerciseType,
        );

        if (mounted && result != null) {
          setState(() {
            if (result['landmarks'] != null) {
              _landmarks = result['landmarks'];
            }
            if (result['form_score'] != null) {
              _formScore = result['form_score'].toDouble();
            }
            if (result['feedback'] != null) {
              _feedback = List<String>.from(result['feedback']);
            }
            if (result['rep_counted'] == true) {
              _repCount++;
              // Haptic feedback on rep count
              Vibration.hasVibrator().then((hasVibrator) {
                if (hasVibrator == true) {
                  Vibration.vibrate(duration: 50);
                }
              });
            }
          });
        }
      } catch (e) {
        debugPrint('Frame processing error: $e');
      } finally {
        _isProcessing = false;
      }
    });
  }

  void _endWorkout() {
    _timer?.cancel();
    setState(() => _isWorkoutActive = false);

    // Calculate calories (simplified)
    final calories = _repCount * 0.5;

    // Navigate to summary
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.workoutSummary,
      arguments: {
        'exercise': widget.exerciseType,
        'exerciseName': widget.exerciseName,
        'reps': _repCount,
        'formScore': _formScore,
        'calories': calories,
        'durationSeconds': _elapsedSeconds,
        'feedback': _feedback,
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            if (_isCameraInitialized && _cameraController != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CameraPreview(_cameraController!),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              ),

            // Pose overlay
            if (_landmarks.isNotEmpty)
              Positioned.fill(
                child: PoseOverlay(
                  landmarks: _landmarks,
                  formScore: _formScore,
                ),
              ),

            // Top bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () {
                      if (_isWorkoutActive) {
                        _showExitConfirmation();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  // Exercise name
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.exerciseName,
                      style: AppTheme.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Timer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatTime(_elapsedSeconds),
                      style: AppTheme.labelLarge.copyWith(
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Rep counter
            if (_isWorkoutActive)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: RepCounter(
                    count: _repCount,
                    formScore: _formScore,
                  ),
                ),
              ),

            // Feedback display
            if (_feedback.isNotEmpty && _isWorkoutActive)
              Positioned(
                bottom: 160,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _formScore >= 0.8
                        ? AppTheme.successColor.withOpacity(0.8)
                        : _formScore >= 0.5
                            ? AppTheme.warningColor.withOpacity(0.8)
                            : AppTheme.accentColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _feedback.first,
                    textAlign: TextAlign.center,
                    style: AppTheme.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Bottom controls
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: _isWorkoutActive
                  ? _buildActiveControls()
                  : _buildStartControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartControls() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                'Position yourself in frame',
                style: AppTheme.headingSmall.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Make sure your full body is visible',
                style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _isCameraInitialized ? _startWorkout : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Start Workout',
                  style: AppTheme.labelLarge.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // End workout button
        GestureDetector(
          onTap: _endWorkout,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stop, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text(
                  'End Workout',
                  style: AppTheme.labelLarge.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Workout?'),
        content: const Text('Your progress will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endWorkout();
            },
            child: const Text('End'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
