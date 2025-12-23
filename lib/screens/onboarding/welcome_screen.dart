import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../widgets/common/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0D1A),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                
                // Hero illustration
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryColor.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_run,
                    size: 100,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
                
                const SizedBox(height: 48),
                
                // Title
                Text(
                  'Train Smarter',
                  style: AppTheme.headingLarge.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                  ),
                )
                    .animate(delay: 200.ms)
                    .fadeIn()
                    .slideY(begin: 0.3),
                
                const SizedBox(height: 8),
                
                Text(
                  'Move Better',
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                )
                    .animate(delay: 400.ms)
                    .fadeIn()
                    .slideY(begin: 0.3),
                
                const SizedBox(height: 24),
                
                Text(
                  'Get real-time AI coaching to perfect your form, '
                  'track your progress, and achieve your fitness goals.',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white70,
                    height: 1.6,
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(),
                
                const Spacer(),
                
                // Features list
                _FeatureItem(
                  icon: Icons.camera_alt,
                  title: 'AI Pose Detection',
                  delay: 700.ms,
                ),
                const SizedBox(height: 16),
                _FeatureItem(
                  icon: Icons.analytics,
                  title: 'Real-time Feedback',
                  delay: 800.ms,
                ),
                const SizedBox(height: 16),
                _FeatureItem(
                  icon: Icons.trending_up,
                  title: 'Track Progress',
                  delay: 900.ms,
                ),
                
                const Spacer(),
                
                // Buttons
                PrimaryButton(
                  text: 'Get Started',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signup);
                  },
                )
                    .animate(delay: 1000.ms)
                    .fadeIn()
                    .slideY(begin: 0.3),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white54),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: AppTheme.labelLarge.copyWith(
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: 1100.ms)
                    .fadeIn(),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Duration delay;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTheme.bodyLarge.copyWith(color: Colors.white),
        ),
      ],
    ).animate(delay: delay).fadeIn().slideX(begin: -0.2);
  }
}
