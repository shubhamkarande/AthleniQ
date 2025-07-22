import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/user_provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import 'home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding data
  FitnessGoal? _selectedGoal;
  FitnessLevel? _selectedLevel;
  final List<String> _selectedEquipment = [];
  final TextEditingController _nameController = TextEditingController();

  final List<String> _availableEquipment = [
    'Dumbbells',
    'Resistance Bands',
    'Yoga Mat',
    'Pull-up Bar',
    'Kettlebell',
    'Jump Rope',
    'No Equipment',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  for (int i = 0; i < 4; i++)
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: i <= _currentPage
                              ? AppTheme.primaryBlue
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildGoalPage(),
                  _buildLevelPage(),
                  _buildEquipmentPage(),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _canProceed() ? _handleNext : null,
                      child: Text(_currentPage == 3 ? 'Get Started' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.energeticOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.waving_hand,
              size: 60,
              color: AppTheme.energeticOrange,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to AthleniQ!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Let\'s personalize your fitness journey with AI-powered workouts and real-time form correction.',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'What should we call you?',
              prefixIcon: Icon(Icons.person),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'What\'s your fitness goal?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us create the perfect workout plan for you.',
            style: TextStyle(fontSize: 16, color: AppTheme.textLight),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildGoalOption(
                  FitnessGoal.weightLoss,
                  'Weight Loss',
                  'Burn calories and lose weight',
                  Icons.trending_down,
                ),
                _buildGoalOption(
                  FitnessGoal.muscleGain,
                  'Muscle Gain',
                  'Build strength and muscle mass',
                  Icons.fitness_center,
                ),
                _buildGoalOption(
                  FitnessGoal.endurance,
                  'Endurance',
                  'Improve cardiovascular fitness',
                  Icons.directions_run,
                ),
                _buildGoalOption(
                  FitnessGoal.flexibility,
                  'Flexibility',
                  'Increase mobility and flexibility',
                  Icons.self_improvement,
                ),
                _buildGoalOption(
                  FitnessGoal.general,
                  'General Fitness',
                  'Overall health and wellness',
                  Icons.favorite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'What\'s your fitness level?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be honest - we\'ll adjust the intensity accordingly.',
            style: TextStyle(fontSize: 16, color: AppTheme.textLight),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildLevelOption(
                  FitnessLevel.beginner,
                  'Beginner',
                  'New to fitness or getting back into it',
                  Icons.looks_one,
                ),
                _buildLevelOption(
                  FitnessLevel.intermediate,
                  'Intermediate',
                  'Regular exercise, comfortable with basics',
                  Icons.looks_two,
                ),
                _buildLevelOption(
                  FitnessLevel.advanced,
                  'Advanced',
                  'Experienced, ready for challenges',
                  Icons.looks_3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'What equipment do you have?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply. Don\'t worry if you don\'t have any!',
            style: TextStyle(fontSize: 16, color: AppTheme.textLight),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _availableEquipment.length,
              itemBuilder: (context, index) {
                final equipment = _availableEquipment[index];
                final isSelected = _selectedEquipment.contains(equipment);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: CheckboxListTile(
                    title: Text(equipment),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedEquipment.add(equipment);
                        } else {
                          _selectedEquipment.remove(equipment);
                        }
                      });
                    },
                    activeColor: AppTheme.primaryBlue,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption(
    FitnessGoal goal,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedGoal == goal;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.1) : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryBlue : AppTheme.textLight,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue)
            : null,
        onTap: () {
          setState(() {
            _selectedGoal = goal;
          });
        },
      ),
    );
  }

  Widget _buildLevelOption(
    FitnessLevel level,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedLevel == level;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.1) : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryBlue : AppTheme.textLight,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue)
            : null,
        onTap: () {
          setState(() {
            _selectedLevel = level;
          });
        },
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _selectedGoal != null;
      case 2:
        return _selectedLevel != null;
      case 3:
        return true; // Equipment is optional
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await userProvider.createUserProfile(
        id: authProvider.userId!,
        name: _nameController.text.trim(),
        email: authProvider.userEmail!,
        goal: _selectedGoal!,
        level: _selectedLevel!,
        availableEquipment: _selectedEquipment,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing onboarding: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}
