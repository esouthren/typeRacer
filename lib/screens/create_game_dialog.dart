import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:typeracer/constants/game_texts.dart';
import 'package:typeracer/nav.dart';
import 'package:typeracer/services/game_service.dart';
import 'package:typeracer/widgets/button.dart';

class CreateGameDialog extends StatefulWidget {
  const CreateGameDialog({super.key});

  @override
  State<CreateGameDialog> createState() => _CreateGameDialogState();
}

class _CreateGameDialogState extends State<CreateGameDialog> {
  final Map<String, bool> _selectedCategories = {};
  bool _isLoading = false;

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

    setState(() => _isLoading = true);

    try {
      final gameId = await GameService().createGame(selected);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create Game',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
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
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Button(
                    label: 'Create',
                    onPressed: _createGame,
                  ),
          ],
        ),
      ),
    );
  }
}
