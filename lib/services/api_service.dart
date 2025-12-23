import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.apiBaseUrl;
  
  static Future<Map<String, dynamic>?> analyzePose({
    required String imageBase64,
    required String exerciseType,
    int frameNumber = 0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pose/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image_base64': imageBase64,
          'exercise_type': exerciseType,
          'frame_number': frameNumber,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      // Return mock data for offline/development mode
      return {
        'success': true,
        'landmarks': [],
        'form_score': 0.85,
        'rep_counted': false,
        'feedback': ['Keep going!'],
      };
    }
  }

  static Future<Map<String, dynamic>?> getWorkoutSummary({
    required Map<String, dynamic> session,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/workout-summary'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session': session}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
