import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/workout_provider.dart';
import '../providers/meal_provider.dart';
import '../models/workout_model.dart';
import '../models/meal_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMotivationCard(),
                  const SizedBox(height: 20),
                  _buildTodayStats(context),
                  const SizedBox(height: 20),
                  _buildWeeklySummary(context),
                  const SizedBox(height: 20),
                  _buildUpcomingWorkouts(context),
                  const SizedBox(height: 20),
                  _buildRecentMeals(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFF4ECDC4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationCard() {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    String motivation = 'Let\'s crush today\'s goals! 💪';
    IconData icon = Icons.wb_sunny_rounded;

    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
      motivation = 'Keep pushing forward! 🔥';
      icon = Icons.wb_sunny_outlined;
    } else if (hour >= 17) {
      greeting = 'Good Evening';
      motivation = 'Finish strong today! ⭐';
      icon = Icons.nights_stay_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  motivation,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats(BuildContext context) {
    return Consumer2<WorkoutProvider, MealProvider>(
      builder: (context, workoutProvider, mealProvider, _) {
        return StreamBuilder<List<Workout>>(
          stream: workoutProvider.workoutsStream,
          builder: (context, workoutSnapshot) {
            return StreamBuilder<List<Meal>>(
              stream: mealProvider.mealsStream,
              builder: (context, mealSnapshot) {
                final workouts = workoutSnapshot.data ?? [];
                final meals = mealSnapshot.data ?? [];

                final today = DateTime.now();
                final todayWorkouts = workouts.where((w) {
                  return w.date.year == today.year &&
                      w.date.month == today.month &&
                      w.date.day == today.day;
                }).toList();

                final todayMeals = meals.where((m) {
                  return m.date.year == today.year &&
                      m.date.month == today.month &&
                      m.date.day == today.day;
                }).toList();

                final completedWorkouts = todayWorkouts.where((w) => w.isCompleted).length;
                final totalWorkoutMinutes = todayWorkouts
                    .where((w) => w.isCompleted)
                    .fold(0, (sum, w) => sum + w.durationMinutes);
                final totalCaloriesBurned = todayWorkouts
                    .where((w) => w.isCompleted)
                    .fold(0, (sum, w) => sum + w.caloriesBurned);
                final totalCaloriesConsumed = todayMeals
                    .fold(0, (sum, m) => sum + m.calories);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.fitness_center_rounded,
                            label: 'Workouts',
                            value: '$completedWorkouts',
                            subtitle: 'completed',
                            color: const Color(0xFFFF6B35),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.timer_rounded,
                            label: 'Active Time',
                            value: '$totalWorkoutMinutes',
                            subtitle: 'minutes',
                            color: const Color(0xFF4ECDC4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.local_fire_department_rounded,
                            label: 'Burned',
                            value: '$totalCaloriesBurned',
                            subtitle: 'kcal',
                            color: const Color(0xFFFF6B35),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.restaurant_rounded,
                            label: 'Consumed',
                            value: '$totalCaloriesConsumed',
                            subtitle: 'kcal',
                            color: const Color(0xFF4ECDC4),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, _) {
        return StreamBuilder<List<Workout>>(
          stream: workoutProvider.workoutsStream,
          builder: (context, snapshot) {
            final workouts = snapshot.data ?? [];

            final now = DateTime.now();
            final weekStart = now.subtract(Duration(days: now.weekday - 1));

            final weekWorkouts = workouts.where((w) {
              return w.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                  w.date.isBefore(now.add(const Duration(days: 1)));
            }).toList();

            final completed = weekWorkouts.where((w) => w.isCompleted).length;
            final total = weekWorkouts.length;
            final completionRate = total > 0 ? (completed / total * 100) : 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This Week',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Workout Progress',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            '${completionRate.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: completionRate / 100,
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF6B35),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeeklyStat(
                            'Completed',
                            completed.toString(),
                            Icons.check_circle_rounded,
                            const Color(0xFF4ECDC4),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _buildWeeklyStat(
                            'Scheduled',
                            total.toString(),
                            Icons.calendar_today_rounded,
                            const Color(0xFFFF6B35),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingWorkouts(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, _) {
        return StreamBuilder<List<Workout>>(
          stream: workoutProvider.workoutsStream,
          builder: (context, snapshot) {
            final workouts = snapshot.data ?? [];
            final upcoming = workouts
                .where((w) => !w.isCompleted && w.date.isAfter(DateTime.now()))
                .toList()
              ..sort((a, b) => a.date.compareTo(b.date));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming Workouts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: upcoming.isEmpty
                      ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No upcoming workouts',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcoming.take(3).length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Colors.grey[200],
                    ),
                    itemBuilder: (context, index) {
                      final workout = upcoming[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFF4ECDC4)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            workout.typeEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        title: Text(
                          workout.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('MMM d, y • HH:mm').format(workout.date),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${workout.durationMinutes}min',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRecentMeals(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, mealProvider, _) {
        return StreamBuilder<List<Meal>>(
          stream: mealProvider.mealsStream,
          builder: (context, snapshot) {
            final meals = snapshot.data ?? [];
            final recentMeals = meals.take(3).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Meals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: recentMeals.isEmpty
                      ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No meals logged yet',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentMeals.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Colors.grey[200],
                    ),
                    itemBuilder: (context, index) {
                      final meal = recentMeals[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            meal.typeEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        title: Text(
                          meal.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '${meal.typeLabel} • ${DateFormat('MMM d').format(meal.date)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${meal.calories} kcal',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4ECDC4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}