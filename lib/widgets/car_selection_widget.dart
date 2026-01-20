import 'package:flutter/material.dart';
import 'package:typeracer/constants/car_assets.dart';

class CarSelectionWidget extends StatefulWidget {
  final Function(int) onCarSelected;
  final Function(String) onNameChanged;
  final int initialCarIndex;
  final String initialName;
  final int crossAxisCount;

  const CarSelectionWidget({
    super.key,
    required this.onCarSelected,
    required this.onNameChanged,
    this.initialCarIndex = 0,
    this.initialName = '',
    this.crossAxisCount = 3,
  });

  @override
  State<CarSelectionWidget> createState() => _CarSelectionWidgetState();
}

class _CarSelectionWidgetState extends State<CarSelectionWidget> {
  late int _selectedCarIndex;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _selectedCarIndex = widget.initialCarIndex;
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          onChanged: widget.onNameChanged,
        ),
        const SizedBox(height: 16),
        Text(
          'Select Vehicle',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemCount: CarAssets.cars.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedCarIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCarIndex = index);
                  widget.onCarSelected(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    CarAssets.cars[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
