import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:typeracer/models/text_category.dart';
import 'package:typeracer/widgets/button.dart';
import 'package:typeracer/theme.dart';
import 'package:flutter/services.dart';

class TestingScreen extends StatefulWidget {
  const TestingScreen({super.key});

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  bool _isLoading = false;
  final TextEditingController _lengthController = TextEditingController(text: '200');

  @override
  void dispose() {
    _lengthController.dispose();
    super.dispose();
  }

  Future<void> _generateText(BuildContext context, TextCategory category) async {
    setState(() {
      _isLoading = true;
    });

    final length = int.tryParse(_lengthController.text) ?? 200;

    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('generateSampleText')
          .call({
            'category': category.displayName,
            'length': length.toString(),
          });

      if (!mounted) return;

      final text = result.data['text'] as String;
      _showResultDialog(context, category.displayName, text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showResultDialog(BuildContext context, String category, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generated Text: $category'),
        content: SingleChildScrollView(
          child: Text(text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
               Clipboard.setData(ClipboardData(text: text));
               Navigator.of(context).pop();
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Copied to clipboard')),
               );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Generate Sample Text',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Length Input
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: TextField(
                  controller: _lengthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Target Length (words)',
                    border: OutlineInputBorder(),
                    helperText: 'Default: 200 words',
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              Text(
                'Select Category',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  alignment: WrapAlignment.center,
                  children: TextCategory.values.map((category) {
                    return Button(
                      label: category.displayName,
                      width: 250,
                      onPressed: () => _generateText(context, category),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
