import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/primary_button.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  int _currentStep = 0;
  
  // Form data
  int? _age;
  double? _height;
  double? _weight;
  String? _selectedGoal;
  
  bool _isLoading = false;

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _age != null && _age! >= 13 && _age! <= 100;
      case 1:
        return _height != null && _height! >= 100 && _height! <= 250;
      case 2:
        return _weight != null && _weight! >= 30 && _weight! <= 300;
      case 3:
        return _selectedGoal != null;
      default:
        return false;
    }
  }

  Future<void> _completeSetup() async {
    setState(() => _isLoading = true);
    
    try {
      await ref.read(userProvider.notifier).updateProfile(
        age: _age!,
        height: _height!,
        weight: _weight!,
        goal: _selectedGoal!,
      );
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(),
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                text: _currentStep == 3 ? 'Complete Setup' : 'Continue',
                isLoading: _isLoading,
                onPressed: _canProceed
                    ? () {
                        if (_currentStep == 3) {
                          _completeSetup();
                        } else {
                          _nextStep();
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildAgeStep();
      case 1:
        return _buildHeightStep();
      case 2:
        return _buildWeightStep();
      case 3:
        return _buildGoalStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAgeStep() {
    return _StepContainer(
      key: const ValueKey('age'),
      icon: Icons.cake,
      title: 'How old are you?',
      subtitle: 'This helps us personalize your workouts',
      child: Column(
        children: [
          Text(
            '${_age ?? 25}',
            style: AppTheme.headingLarge.copyWith(
              fontSize: 72,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            'years old',
            style: AppTheme.bodyLarge.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 32),
          Slider(
            value: (_age ?? 25).toDouble(),
            min: 13,
            max: 100,
            divisions: 87,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() => _age = value.round());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeightStep() {
    return _StepContainer(
      key: const ValueKey('height'),
      icon: Icons.height,
      title: 'What\'s your height?',
      subtitle: 'We use this for accurate calorie calculations',
      child: Column(
        children: [
          Text(
            '${(_height ?? 170).round()}',
            style: AppTheme.headingLarge.copyWith(
              fontSize: 72,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            'cm',
            style: AppTheme.bodyLarge.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 32),
          Slider(
            value: _height ?? 170,
            min: 100,
            max: 250,
            divisions: 150,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() => _height = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStep() {
    return _StepContainer(
      key: const ValueKey('weight'),
      icon: Icons.monitor_weight_outlined,
      title: 'What\'s your weight?',
      subtitle: 'This helps track your progress',
      child: Column(
        children: [
          Text(
            '${(_weight ?? 70).round()}',
            style: AppTheme.headingLarge.copyWith(
              fontSize: 72,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            'kg',
            style: AppTheme.bodyLarge.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 32),
          Slider(
            value: _weight ?? 70,
            min: 30,
            max: 200,
            divisions: 170,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() => _weight = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    return _StepContainer(
      key: const ValueKey('goal'),
      icon: Icons.flag,
      title: 'What\'s your goal?',
      subtitle: 'We\'ll create a personalized plan for you',
      child: Column(
        children: AppConstants.fitnessGoals.map((goal) {
          final isSelected = _selectedGoal == goal['id'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() => _selectedGoal = goal['id']);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      goal['icon'] as String,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal['name'] as String,
                            style: AppTheme.labelLarge.copyWith(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal['description'] as String,
                            style: AppTheme.bodySmall.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StepContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _StepContainer({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          )
              .animate()
              .fadeIn()
              .scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.headingMedium.copyWith(
              color: Theme.of(context).textTheme.displayMedium?.color,
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms)
              .slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms),
          const SizedBox(height: 40),
          child,
        ],
      ),
    );
  }
}
