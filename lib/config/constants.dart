class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000';
  
  // App Info
  static const String appName = 'AthleniQ';
  static const String appTagline = 'Train smarter. Move better. Get coached by AI.';
  static const String appVersion = '1.0.0';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Camera Settings
  static const int frameRate = 10; // Frames per second to analyze
  static const double poseConfidenceThreshold = 0.5;
  
  // Workout Settings
  static const int defaultRestSeconds = 45;
  static const int defaultSets = 3;
  static const int defaultReps = 12;
  
  // Fitness Goals
  static const List<Map<String, dynamic>> fitnessGoals = [
    {
      'id': 'fat_loss',
      'name': 'Fat Loss',
      'icon': '🔥',
      'description': 'Burn calories and lose weight',
    },
    {
      'id': 'muscle',
      'name': 'Build Muscle',
      'icon': '💪',
      'description': 'Gain strength and muscle mass',
    },
    {
      'id': 'flexibility',
      'name': 'Flexibility',
      'icon': '🧘',
      'description': 'Improve mobility and flexibility',
    },
    {
      'id': 'endurance',
      'name': 'Endurance',
      'icon': '🏃',
      'description': 'Build stamina and cardiovascular health',
    },
    {
      'id': 'general',
      'name': 'General Fitness',
      'icon': '⭐',
      'description': 'Overall health and wellness',
    },
  ];
  
  // Exercises
  static const List<Map<String, dynamic>> exercises = [
    {
      'id': 'squat',
      'name': 'Squats',
      'icon': '🦵',
      'muscles': ['Quads', 'Glutes', 'Core'],
      'difficulty': 'Beginner',
      'caloriesPerRep': 0.5,
    },
    {
      'id': 'pushup',
      'name': 'Push-ups',
      'icon': '💪',
      'muscles': ['Chest', 'Triceps', 'Shoulders'],
      'difficulty': 'Beginner',
      'caloriesPerRep': 0.4,
    },
    {
      'id': 'lunge',
      'name': 'Lunges',
      'icon': '🚶',
      'muscles': ['Quads', 'Glutes', 'Hamstrings'],
      'difficulty': 'Beginner',
      'caloriesPerRep': 0.4,
    },
    {
      'id': 'plank',
      'name': 'Plank',
      'icon': '🧘',
      'muscles': ['Core', 'Shoulders', 'Back'],
      'difficulty': 'Beginner',
      'caloriesPerRep': 0.2,
    },
    {
      'id': 'jumping_jack',
      'name': 'Jumping Jacks',
      'icon': '⭐',
      'muscles': ['Full Body', 'Cardio'],
      'difficulty': 'Beginner',
      'caloriesPerRep': 0.3,
    },
    {
      'id': 'deadlift',
      'name': 'Deadlift',
      'icon': '🏋️',
      'muscles': ['Back', 'Glutes', 'Hamstrings'],
      'difficulty': 'Intermediate',
      'caloriesPerRep': 0.6,
    },
    {
      'id': 'bicep_curl',
      'name': 'Bicep Curls',
      'icon': '💪',
      'muscles': ['Biceps', 'Forearms'],
      'difficulty': 'Beginner',
      'caloriesPerRep': 0.2,
    },
  ];
}
