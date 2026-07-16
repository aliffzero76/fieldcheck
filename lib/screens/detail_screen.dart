import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/check_in.dart';
import '../services/storage_service.dart';

/// Screen 3 — Check-In Detail: read-only record view.
class DetailScreen extends StatelessWidget {
  final CheckIn checkIn;

  const DetailScreen({super.key, required this.checkIn});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete check-in?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.delete(checkIn.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd MMM yyyy, HH:mm:ss').format(checkIn.createdAt);
    final file = File(checkIn.photoPath);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: file.existsSync()
                  ? Image.file(file, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: Text('IMG / ✕')),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'NOTE',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            checkIn.note.isEmpty ? '(no note)' : checkIn.note,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(height: 32),
          _DetailRow(label: 'Latitude', value: checkIn.latitude.toStringAsFixed(6)),
          _DetailRow(label: 'Longitude', value: checkIn.longitude.toStringAsFixed(6)),
          _DetailRow(label: 'Accuracy', value: '${checkIn.accuracy.toStringAsFixed(1)} m'),
          _DetailRow(label: 'Created At', value: formattedDate),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
