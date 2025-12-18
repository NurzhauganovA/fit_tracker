import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/workout_provider.dart';
import '../models/workout_model.dart';
import '../widgets/add_workout_sheet.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _filter = 'all';
  WorkoutType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workouts',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              'Track your fitness journey',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddWorkoutSheet(),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Workout'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildTypeFilter(),
          Expanded(
            child: StreamBuilder<List<Workout>>(
              stream: workoutProvider.workoutsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6B35),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                List<Workout> workouts = snapshot.data ?? [];
                workouts = _filterWorkouts(workouts);

                if (workouts.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return _buildWorkoutCard(context, workout, workoutProvider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all', Icons.apps_rounded),
            const SizedBox(width: 8),
            _buildFilterChip('Today', 'today', Icons.today_rounded),
            const SizedBox(width: 8),
            _buildFilterChip('Upcoming', 'upcoming', Icons.upcoming_rounded),
            const SizedBox(width: 8),
            _buildFilterChip('Completed', 'completed', Icons.check_circle_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _filter == value;
    return FilterChip(
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[600],
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filter = value;
        });
      },
      backgroundColor: Colors.grey[50],
      selectedColor: const Color(0xFFFF6B35).withOpacity(0.15),
      checkmarkColor: const Color(0xFFFF6B35),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTypeChip(null, 'All', '🏋️'),
            const SizedBox(width: 8),
            _buildTypeChip(WorkoutType.strength, 'Strength', '💪'),
            const SizedBox(width: 8),
            _buildTypeChip(WorkoutType.cardio, 'Cardio', '🏃'),
            const SizedBox(width: 8),
            _buildTypeChip(WorkoutType.flexibility, 'Flexibility', '🧘'),
            const SizedBox(width: 8),
            _buildTypeChip(WorkoutType.sports, 'Sports', '⚽'),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(WorkoutType? type, String label, String emoji) {
    final isSelected = _typeFilter == type;
    return ChoiceChip(
      avatar: Text(emoji, style: const TextStyle(fontSize: 16)),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _typeFilter = selected ? type : null;
        });
      },
      backgroundColor: Colors.grey[50],
      selectedColor: const Color(0xFFFF6B35).withOpacity(0.15),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }

  List<Workout> _filterWorkouts(List<Workout> workouts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_typeFilter != null) {
      workouts = workouts.where((w) => w.type == _typeFilter).toList();
    }

    switch (_filter) {
      case 'today':
        return workouts.where((w) {
          final workoutDate = DateTime(w.date.year, w.date.month, w.date.day);
          return workoutDate == today && !w.isCompleted;
        }).toList();
      case 'upcoming':
        return workouts.where((w) => !w.isCompleted && w.date.isAfter(now)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
      case 'completed':
        return workouts.where((w) => w.isCompleted).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      default:
        return workouts..sort((a, b) {
          if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
          return a.date.compareTo(b.date);
        });
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFF4ECDC4)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No workouts found!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first workout to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(WorkoutType type) {
    switch (type) {
      case WorkoutType.strength:
        return const Color(0xFFFF6B35);
      case WorkoutType.cardio:
        return const Color(0xFF4ECDC4);
      case WorkoutType.flexibility:
        return const Color(0xFF9B59B6);
      case WorkoutType.sports:
        return const Color(0xFFF39C12);
      case WorkoutType.other:
        return Colors.grey;
    }
  }

  Color _getIntensityColor(WorkoutIntensity intensity) {
    switch (intensity) {
      case WorkoutIntensity.light:
        return Colors.green;
      case WorkoutIntensity.moderate:
        return Colors.orange;
      case WorkoutIntensity.intense:
        return Colors.deepOrange;
      case WorkoutIntensity.extreme:
        return Colors.red;
    }
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout, WorkoutProvider provider) {
    final typeColor = _getTypeColor(workout.type);
    final intensityColor = _getIntensityColor(workout.intensity);
    final isPast = workout.date.isBefore(DateTime.now()) && !workout.isCompleted;

    return Dismissible(
      key: Key(workout.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[300]!, Colors.red[500]!],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      onDismissed: (direction) {
        provider.deleteWorkout(workout.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Workout deleted'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red[400],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: workout.isCompleted
                ? Colors.grey[300]!
                : typeColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // TODO: Open edit sheet
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      provider.toggleWorkout(workout.id, workout.isCompleted);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: workout.isCompleted
                              ? typeColor
                              : Colors.grey[400]!,
                          width: 2.5,
                        ),
                        color: workout.isCompleted
                            ? typeColor
                            : Colors.transparent,
                      ),
                      child: workout.isCompleted
                          ? const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              workout.typeEmoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                workout.name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: workout.isCompleted
                                      ? Colors.grey[400]
                                      : const Color(0xFF2C3E50),
                                  decoration: workout.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (workout.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            workout.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: workout.isCompleted
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              decoration: workout.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isPast
                                    ? Colors.red[50]
                                    : typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 13,
                                    color: isPast
                                        ? Colors.red[700]
                                        : typeColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM d, HH:mm').format(workout.date),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isPast
                                          ? Colors.red[700]
                                          : typeColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: intensityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.whatshot_rounded,
                                    size: 13,
                                    color: intensityColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    workout.intensityLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: intensityColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_rounded,
                                    size: 13,
                                    color: typeColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${workout.durationMinutes}min',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: typeColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (workout.caloriesBurned > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 13,
                                      color: Color(0xFF4ECDC4),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${workout.caloriesBurned}kcal',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF4ECDC4),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
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
}