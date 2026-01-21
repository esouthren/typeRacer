import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:typeracer/models/game_model.dart';
import 'package:typeracer/models/text_category.dart';
import 'package:typeracer/nav.dart';
import 'package:typeracer/services/game_service.dart';
import 'package:typeracer/widgets/button.dart';
import 'package:typeracer/widgets/car_selection_widget.dart';
import 'package:typeracer/theme.dart';

class CreateGameDialog extends StatefulWidget {
  const CreateGameDialog({super.key});

  @override
  State<CreateGameDialog> createState() => _CreateGameDialogState();
}

class _CreateGameDialogState extends State<CreateGameDialog> {
  final Map<TextCategory, bool> _selectedCategories = {};
  bool _isLoading = false;
  int _selectedCarIndex = 0;
  String _displayName = '';
  final TextEditingController _wordCountController = TextEditingController(text: '75');

  @override
  void initState() {
    super.initState();
    for (var category in TextCategory.values) {
      _selectedCategories[category] = false;
    }
  }

  @override
  void dispose() {
    _wordCountController.dispose();
    super.dispose();
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

    final wordCount = int.tryParse(_wordCountController.text) ?? 100;

    setState(() => _isLoading = true);

    try {
      // 1. Fetch text samples for each round
      List<GameRound> rounds = [];
      for (int i = 0; i < selected.length; i++) {
        final category = selected[i];
        
        // Call cloud function
        final result = await FirebaseFunctions.instance
            .httpsCallable('generateSampleText')
            .call({
              'category': category.displayName,
              'length': wordCount.toString(),
            });
            
        final text = (result.data['text'] as String)
            .replaceAll(RegExp(r'[\r\n]+'), ' ')
            .trim();
        
        rounds.add(GameRound(
          text: text,
          category: category.displayName,
          roundNumber: i + 1,
        ));
      }

      // 2. Create game with fetched texts
      final gameId = await GameService().createGame(
        rounds,
        selected.map((e) => e.displayName).toList(), 
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: IconButton(
              icon: Image.asset(
                'assets/images/delete.png',
                width: 32,
                height: 32,
              ),
              onPressed: () => context.pop(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: 1000, 
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

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
                        // Right Column: Categories & Settings
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                  
                              
                              // Word Count Input
                              TextField(
                                controller: _wordCountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(
                                  labelText: 'Word Count per Round',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Round Categories',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    'Rounds: ${selectedCount()}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                constraints: const BoxConstraints(maxHeight: 400),
                                child: ListView(
                                  shrinkWrap: true,
                                  children: TextCategory.values.map((category) {
                                    return CheckboxListTile(
                                      title: Text(category.displayName),
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
                        
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Generating game texts...',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          )
                        : SizedBox(
                            width: 300,
                            child: Button(
                              buttonColor: ButtonColor.secondary,
                              label: 'Create Game',
                              onPressed: _createGame,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  int selectedCount() => _selectedCategories.values.where((e) => e).length;
}
