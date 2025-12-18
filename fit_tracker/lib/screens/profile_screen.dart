import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../providers/workout_provider.dart';
import '../providers/meal_provider.dart';
import '../models/workout_model.dart';
import '../models/meal_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _targetWeightController = TextEditingController();
    _goalController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await DatabaseService(uid: user.uid).updateUserProfile(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text),
      height: double.tryParse(_heightController.text),
      targetWeight: double.tryParse(_targetWeightController.text),
      fitnessGoal: _goalController.text.trim(),
    );

    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF4ECDC4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: StreamBuilder<UserProfile?>(
              stream: DatabaseService(uid: user.uid).userProfile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                    ),
                  );
                }

                final profile = snapshot.data;

                if (profile != null && !_isEditing) {
                  _nameController.text = profile.name;
                  _ageController.text = profile.age > 0 ? profile.age.toString() : '';
                  _heightController.text = profile.height > 0 ? profile.height.toString() : '';
                  _targetWeightController.text = profile.targetWeight > 0 ? profile.targetWeight.toString() : '';
                  _goalController.text = profile.fitnessGoal;
                }

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildProfileHeader(profile ?? UserProfile(
                        uid: user.uid,
                        name: 'Fitness Enthusiast',
                        email: user.email ?? '',
                      )),
                      const SizedBox(height: 24),
                      if (_isEditing) _buildEditForm() else _buildProfileInfo(profile),
                      const SizedBox(height: 24),
                      _buildStatsSection(),
                      const SizedBox(height: 24),
                      _buildLogoutButton(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton.extended(
        onPressed: _saveProfile,
        backgroundColor: const Color(0xFF4ECDC4),
        icon: const Icon(Icons.save_rounded),
        label: const Text('Save'),
      )
          : null,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                    )
                  else
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                        });
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
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

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 50,
              color: Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          if (profile.fitnessGoal.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🎯 ${profile.fitnessGoal}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    prefixIcon: const Icon(Icons.cake_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Height (cm)',
                    prefixIcon: const Icon(Icons.height_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _targetWeightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Target Weight (kg)',
              prefixIcon: const Icon(Icons.scale_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _goalController,
            decoration: InputDecoration(
              labelText: 'Fitness Goal',
              prefixIcon: const Icon(Icons.flag_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(UserProfile? profile) {
    if (profile == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (profile.age > 0)
            _buildInfoRow(Icons.cake_rounded, 'Age', '${profile.age} years'),
          if (profile.age > 0) const Divider(height: 24),
          if (profile.height > 0)
            _buildInfoRow(Icons.height_rounded, 'Height', '${profile.height.toStringAsFixed(0)} cm'),
          if (profile.height > 0) const Divider(height: 24),
          if (profile.targetWeight > 0)
            _buildInfoRow(Icons.scale_rounded, 'Target Weight', '${profile.targetWeight.toStringAsFixed(1)} kg'),
          if (profile.targetWeight > 0 && profile.age == 0 && profile.height == 0) const Divider(height: 24),
          _buildInfoRow(Icons.badge_rounded, 'User ID', profile.uid, isSmall: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isSmall = false}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFF4ECDC4)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmall ? 12 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
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

                final completedWorkouts = workouts.where((w) => w.isCompleted).length;
                final totalCaloriesBurned = workouts
                    .where((w) => w.isCompleted)
                    .fold(0, (sum, w) => sum + w.caloriesBurned);
                final totalMeals = meals.length;

                return Row(
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
                        icon: Icons.local_fire_department_rounded,
                        label: 'Calories',
                        value: '$totalCaloriesBurned',
                        subtitle: 'burned',
                        color: const Color(0xFF4ECDC4),
                      ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await AuthService().signOut();
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}