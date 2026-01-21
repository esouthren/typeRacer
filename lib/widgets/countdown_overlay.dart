import 'dart:async';
import 'package:flutter/material.dart';

class CountdownOverlay extends StatefulWidget {
  final DateTime startTime;
  final VoidCallback? onFinished;

  const CountdownOverlay({
    super.key, 
    required this.startTime,
    this.onFinished,
  });

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  late Timer _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) => _updateTime());
  }
  
  void _updateTime() {
    final now = DateTime.now();
    final diff = widget.startTime.difference(now);
    
    // Update seconds (ceil to show 3, 2, 1)
    // If diff is 2900ms, seconds is 2. 
    // We want to show 3 when 2001-3000ms.
    // diff.inSeconds is truncated.
    
    int newSeconds;
    if (diff.isNegative) {
      newSeconds = 0;
    } else {
      newSeconds = diff.inSeconds + 1;
    }

    if (newSeconds != _secondsLeft) {
      setState(() {
        _secondsLeft = newSeconds;
      });
      
      if (newSeconds <= 0) {
        widget.onFinished?.call();
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_secondsLeft <= 0) return const SizedBox.shrink();
    
    return Container(
      color: Colors.black, // Solid opaque black
      child: Center(
        child: Text(
          '$_secondsLeft',
          style: const TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
