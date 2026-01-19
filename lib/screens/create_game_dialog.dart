import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:typeracer/constants/game_texts.dart';
import 'package:typeracer/nav.dart';
import 'package:typeracer/services/game_service.dart';
import 'package:typeracer/widgets/button.dart';
import 'package:typeracer/widgets/car_selection_widget.dart';

class CreateGameDialog extends StatefulWidget {
  const CreateGameDialog({super.key});

  @override
  State<CreateGameDialog> createState() => _CreateGameDialogState();
}

class _CreateGameDialogState extends State<CreateGameDialog> {
  final Map<String, bool> _selectedCategories = {};
  bool _isLoading = false;
  int _selectedCarIndex = 0;
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    for (var category in GameTexts.categories) {
      _selectedCategories[category] = false;
    }
  }

  int get _estimatedMinutes => _selectedCategories.values.where((e) => e).length;

  Future<void> _createGame() async {
    final selected = _selectedCategories.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
      );
      return;
    }
    
    if (_displayName.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a display name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final gameId = await GameService().createGame(
        selected, 
        _displayName, 
        _selectedCarIndex
      );
      if (mounted) {
        context.pop(); // Close dialog
        context.push(AppRoutes.lobby, extra: gameId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating game: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: 1000, // Wider for two-column layout
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create Game',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Identity
                    Expanded(
                      child: CarSelectionWidget(
                        crossAxisCount: 6,
                        onCarSelected: (index) => setState(() => _selectedCarIndex = index),
                        onNameChanged: (name) => setState(() => _displayName = name),
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Right Column: Categories
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Select Categories',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: const BoxConstraints(maxHeight: 270), // Match approx height of left column
                            child: ListView(
                              shrinkWrap: true,
                              children: GameTexts.categories.map((category) {
                                return CheckboxListTile(
                                  title: Text(category),
                                  value: _selectedCategories[category],
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedCategories[category] = val ?? false;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Estimated Game Duration: $_estimatedMinutes minute${_estimatedMinutes == 1 ? '' : 's'}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: 200,
                        child: Button(
                          label: 'Create Game',
                          onPressed: _createGame,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
