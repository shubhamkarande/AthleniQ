import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/user_provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/common/gradient_card.dart';
import '../../widgets/common/stat_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          _WorkoutsTab(),
          _ProgressTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_outlined),
                activeIcon: Icon(Icons.fitness_center),
                label: 'Workouts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Progress',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final workouts = ref.watch(workoutHistoryProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: AppTheme.bodyMedium.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.displayName ?? 'Athlete',
                      style: AppTheme.headingMedium.copyWith(
                        color: Theme.of(context).textTheme.displayMedium?.color,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn()
                .slideX(begin: -0.1),

            const SizedBox(height: 24),

            // Streak Card
            GradientCard(
              gradient: AppTheme.primaryGradient,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '🔥',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user?.workoutStreak ?? 0} Day Streak!',
                          style: AppTheme.headingSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Keep it up! You\'re doing great.',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate(delay: 100.ms)
                .fadeIn()
                .slideY(begin: 0.2),

            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.fitness_center,
                    value: '${user?.totalWorkouts ?? 0}',
                    label: 'Workouts',
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department,
                    value: '${_calculateTotalCalories(workouts)}',
                    label: 'Calories',
                    color: AppTheme.accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.timer,
                    value: '${_calculateTotalMinutes(workouts)}',
                    label: 'Minutes',
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            )
                .animate(delay: 200.ms)
                .fadeIn()
                .slideY(begin: 0.2),

            const SizedBox(height: 32),

            // Start Workout Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Start',
                  style: AppTheme.headingSmall.copyWith(
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.workoutList);
                  },
                  child: const Text('See All'),
                ),
              ],
            )
                .animate(delay: 300.ms)
                .fadeIn(),

            const SizedBox(height: 16),

            // Exercise Cards
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.exercises.length.clamp(0, 4),
                itemBuilder: (context, index) {
                  final exercise = AppConstants.exercises[index];
                  return _ExerciseCard(
                    exercise: exercise,
                    delay: Duration(milliseconds: 400 + (index * 100)),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Today's Recommendation
            Text(
              'Recommended for You',
              style: AppTheme.headingSmall.copyWith(
                color: Theme.of(context).textTheme.displaySmall?.color,
              ),
            )
                .animate(delay: 600.ms)
                .fadeIn(),

            const SizedBox(height: 16),

            // Recommended workout card
            InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.workoutSession,
                  arguments: {
                    'exerciseType': 'squat',
                    'exerciseName': 'Full Body Squats',
                  },
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'AI Recommended',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Full Body Workout',
                            style: AppTheme.headingSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '20 min',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '150 cal',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(delay: 700.ms)
                .fadeIn()
                .slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  int _calculateTotalCalories(List workouts) {
    if (workouts.isEmpty) return 0;
    return workouts.fold(0, (sum, w) => sum + (w.calories as num).round());
  }

  int _calculateTotalMinutes(List workouts) {
    if (workouts.isEmpty) return 0;
    return workouts.fold(0, (sum, w) => sum + ((w.durationSeconds as int) ~/ 60));
  }
}

class _ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final Duration delay;

  const _ExerciseCard({
    required this.exercise,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.workoutSession,
          arguments: {
            'exerciseType': exercise['id'],
            'exerciseName': exercise['name'],
          },
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise['icon'] as String,
              style: const TextStyle(fontSize: 36),
            ),
            const Spacer(),
            Text(
              exercise['name'] as String,
              style: AppTheme.labelLarge.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              exercise['difficulty'] as String,
              style: AppTheme.bodySmall.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: delay).fadeIn().slideX(begin: 0.2);
  }
}

// Placeholder tabs - will be implemented as separate screens
class _WorkoutsTab extends StatelessWidget {
  const _WorkoutsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Workouts Tab'));
  }
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Progress Tab'));
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                ref.read(userProvider.notifier).signOut();
                Navigator.pushReplacementNamed(context, AppRoutes.welcome);
              },
            ),
          ],
        ),
      ),
    );
  }
}
