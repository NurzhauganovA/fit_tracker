import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/progress_model.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<ProgressEntry>> _getProgressStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .orderBy('isPinned', descending: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProgressEntry.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Color _getEntryColor(String colorName) {
    switch (colorName) {
      case 'orange':
        return const Color(0xFFFF6B35);
      case 'teal':
        return const Color(0xFF4ECDC4);
      case 'purple':
        return const Color(0xFF9B59B6);
      case 'green':
        return const Color(0xFF00D09C);
      case 'blue':
        return const Color(0xFF3498DB);
      case 'red':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFFFF6B35);
    }
  }

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
              'Progress Journal',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF9B59B6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Entry'),
        onPressed: () => _showEntryDialog(),
      ),
      body: StreamBuilder<List<ProgressEntry>>(
        stream: _getProgressStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF9B59B6)),
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

          var entries = snapshot.data ?? [];

          if (_searchQuery.isNotEmpty) {
            entries = entries.where((entry) {
              return entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  entry.content.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();
          }

          if (entries.isEmpty) {
            return _buildEmptyState();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildEntryCard(entry);
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
                colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No entries yet!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your progress',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(ProgressEntry entry) {
    final color = _getEntryColor(entry.color);

    return GestureDetector(
      onTap: () => _showEntryDialog(entry: entry),
      onLongPress: () => _showEntryOptions(entry),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.isPinned)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Icon(
                        Icons.push_pin_rounded,
                        size: 18,
                        color: color,
                      ),
                    ),
                  Text(
                    entry.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (entry.weight != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.scale_rounded, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.weight}kg',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (entry.bodyFat != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.fitness_center_rounded, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.bodyFat}% BF',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    entry.content,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMM d, y').format(entry.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Entries'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter search term...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEntryOptions(ProgressEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                entry.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                color: const Color(0xFF9B59B6),
              ),
              title: Text(entry.isPinned ? 'Unpin Entry' : 'Pin Entry'),
              onTap: () {
                _togglePin(entry);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Color(0xFF9B59B6)),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEntryDialog(entry: entry);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteEntry(entry.id);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEntryDialog({ProgressEntry? entry}) {
    final titleController = TextEditingController(text: entry?.title ?? '');
    final contentController = TextEditingController(text: entry?.content ?? '');
    final weightController = TextEditingController(
      text: entry?.weight?.toString() ?? '',
    );
    final bodyFatController = TextEditingController(
      text: entry?.bodyFat?.toString() ?? '',
    );
    String selectedColor = entry?.color ?? 'orange';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry == null ? 'New Entry' : 'Edit Entry'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: bodyFatController,
                        decoration: const InputDecoration(
                          labelText: 'Body Fat %',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Color',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['orange', 'teal', 'purple', 'green', 'blue', 'red']
                      .map((colorName) {
                    final color = _getEntryColor(colorName);
                    final isSelected = selectedColor == colorName;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = colorName;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;

              if (entry == null) {
                _createEntry(
                  titleController.text.trim(),
                  contentController.text.trim(),
                  selectedColor,
                  double.tryParse(weightController.text),
                  double.tryParse(bodyFatController.text),
                );
              } else {
                _updateEntry(
                  entry.id,
                  titleController.text.trim(),
                  contentController.text.trim(),
                  selectedColor,
                  double.tryParse(weightController.text),
                  double.tryParse(bodyFatController.text),
                );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B59B6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _createEntry(
      String title,
      String content,
      String color,
      double? weight,
      double? bodyFat,
      ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .add({
      'title': title,
      'content': content,
      'color': color,
      'weight': weight,
      'bodyFat': bodyFat,
      'isPinned': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry created'),
          backgroundColor: Color(0xFF9B59B6),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _updateEntry(
      String id,
      String title,
      String content,
      String color,
      double? weight,
      double? bodyFat,
      ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .doc(id)
        .update({
      'title': title,
      'content': content,
      'color': color,
      'weight': weight,
      'bodyFat': bodyFat,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry updated'),
          backgroundColor: Color(0xFF9B59B6),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _togglePin(ProgressEntry entry) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .doc(entry.id)
        .update({
      'isPinned': !entry.isPinned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteEntry(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .doc(id)
        .delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry deleted'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}