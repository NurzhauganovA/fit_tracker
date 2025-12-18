import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/workout_provider.dart';
import '../models/workout_model.dart';

class AddWorkoutSheet extends StatefulWidget {
  const AddWorkoutSheet({super.key});

  @override
  State<AddWorkoutSheet> createState() => _AddWorkoutSheetState();
}

class _AddWorkoutSheetState extends State<AddWorkoutSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _caloriesController = TextEditingController(text: '200');
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  WorkoutType _type = WorkoutType.other;
  WorkoutIntensity _intensity = WorkoutIntensity.moderate;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B35),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2C3E50),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFFF6B35),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF2C3E50),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
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

  void _submitData() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter workout name'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    context.read<WorkoutProvider>().addWorkout(
      _nameController.text.trim(),
      _descController.text.trim(),
      combinedDateTime,
      durationMinutes: int.tryParse(_durationController.text) ?? 30,
      caloriesBurned: int.tryParse(_caloriesController.text) ?? 0,
      type: _type,
      intensity: _intensity,
    );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workout scheduled successfully'),
        backgroundColor: Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFF4ECDC4)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'New Workout',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Workout Name *',
                prefixIcon: const Icon(Icons.title_rounded, color: Color(0xFFFF6B35)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              style: const TextStyle(fontSize: 15),
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: const Icon(Icons.notes_rounded, color: Color(0xFFFF6B35)),
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF6B35).withOpacity(0.1),
                    const Color(0xFF4ECDC4).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFF4ECDC4)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date & Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${DateFormat('EEEE, MMM d, y').format(_selectedDate)} at ${_selectedTime.format(context)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDateTime,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B35),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Change',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Duration (min)',
                      prefixIcon: const Icon(Icons.timer_rounded, color: Color(0xFFFF6B35)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Calories',
                      prefixIcon: const Icon(Icons.local_fire_department_rounded, color: Color(0xFF4ECDC4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Workout Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WorkoutType.values.map((type) {
                final isSelected = _type == type;
                final color = _getTypeColor(type);
                String label;
                String emoji;

                switch (type) {
                  case WorkoutType.strength:
                    label = 'Strength';
                    emoji = '💪';
                    break;
                  case WorkoutType.cardio:
                    label = 'Cardio';
                    emoji = '🏃';
                    break;
                  case WorkoutType.flexibility:
                    label = 'Flexibility';
                    emoji = '🧘';
                    break;
                  case WorkoutType.sports:
                    label = 'Sports';
                    emoji = '⚽';
                    break;
                  case WorkoutType.other:
                    label = 'Other';
                    emoji = '🏋️';
                    break;
                }

                return ChoiceChip(
                  avatar: Text(emoji, style: const TextStyle(fontSize: 16)),
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _type = type;
                    });
                  },
                  backgroundColor: color.withOpacity(0.1),
                  selectedColor: color.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected ? color : color.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Intensity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WorkoutIntensity.values.map((intensity) {
                final isSelected = _intensity == intensity;
                final color = _getIntensityColor(intensity);
                String label;
                IconData icon;

                switch (intensity) {
                  case WorkoutIntensity.light:
                    label = 'Light';
                    icon = Icons.battery_2_bar_rounded;
                    break;
                  case WorkoutIntensity.moderate:
                    label = 'Moderate';
                    icon = Icons.battery_5_bar_rounded;
                    break;
                  case WorkoutIntensity.intense:
                    label = 'Intense';
                    icon = Icons.battery_full_rounded;
                    break;
                  case WorkoutIntensity.extreme:
                    label = 'Extreme';
                    icon = Icons.whatshot_rounded;
                    break;
                }

                return ChoiceChip(
                  avatar: Icon(
                    icon,
                    size: 18,
                    color: isSelected ? Colors.white : color,
                  ),
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _intensity = intensity;
                    });
                  },
                  backgroundColor: color.withOpacity(0.1),
                  selectedColor: color,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFF4ECDC4)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Schedule Workout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}