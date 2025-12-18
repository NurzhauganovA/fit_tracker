import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/meal_provider.dart';
import '../models/meal_model.dart';
import '../widgets/add_meal_sheet.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nutrition',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              'Track your meals',
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
            builder: (_) => const AddMealSheet(),
          );
        },
        backgroundColor: const Color(0xFF4ECDC4),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Meal'),
      ),
      body: Consumer<MealProvider>(
        builder: (context, mealProvider, child) {
          return StreamBuilder<List<Meal>>(
            stream: mealProvider.mealsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF4ECDC4)));
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final meals = snapshot.data ?? [];

              if (meals.isEmpty) {
                return _buildEmptyState();
              }

              // Calculate today's stats
              final today = DateTime.now();
              final todayMeals = meals.where((m) =>
              m.date.year == today.year &&
                  m.date.month == today.month &&
                  m.date.day == today.day
              ).toList();

              final totalCalories = todayMeals.fold(0, (sum, m) => sum + m.calories);
              final totalProtein = todayMeals.fold(0.0, (sum, m) => sum + m.protein);
              final totalCarbs = todayMeals.fold(0.0, (sum, m) => sum + m.carbs);
              final totalFats = todayMeals.fold(0.0, (sum, m) => sum + m.fats);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(totalCalories, totalProtein, totalCarbs, totalFats),
                    const SizedBox(height: 24),
                    const Text(
                      'Recent Meals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final meal = meals[index];
                        return _buildMealCard(context, meal, mealProvider);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
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
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No meals logged',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your nutrition today',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int calories, double protein, double carbs, double fats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Today\'s Calories',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            '$calories',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroItem('Protein', '${protein.toStringAsFixed(1)}g'),
              _buildMacroItem('Carbs', '${carbs.toStringAsFixed(1)}g'),
              _buildMacroItem('Fats', '${fats.toStringAsFixed(1)}g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, Meal meal, MealProvider provider) {
    return Dismissible(
      key: Key(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        provider.deleteMeal(meal.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal deleted')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.1),
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
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${DateFormat('MMM d, HH:mm').format(meal.date)} • ${meal.calories} kcal',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              if (meal.notes.isNotEmpty)
                Text(
                  meal.notes,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}