import 'package:flutter/material.dart';

/// Shown on Home when there are no saved check-ins yet.
/// Matches wireframe 1b: icon placeholder + message + hint.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade400,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Icon(Icons.close, size: 36, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
            const Text(
              'No check-ins yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first check-in.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
