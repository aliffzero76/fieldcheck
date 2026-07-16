import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/check_in.dart';
import '../services/storage_service.dart';
import '../widgets/photo_picker_field.dart';
import '../widgets/location_field.dart';

/// Screen 2 — New Check-In: note + photo + GPS, all required before Save.
class NewCheckInScreen extends StatefulWidget {
  const NewCheckInScreen({super.key});

  @override
  State<NewCheckInScreen> createState() => _NewCheckInScreenState();
}

class _NewCheckInScreenState extends State<NewCheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  File? _photo;
  Position? _position;
  bool _attemptedSubmit = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _formKey.currentState?.validate() == true &&
      _photo != null &&
      _position != null;

  Future<void> _save() async {
    setState(() => _attemptedSubmit = true);

    // Re-validate the form fields explicitly (note field).
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk || _photo == null || _position == null) {
      return; // required-field errors are shown inline, no need for a dialog
    }

    setState(() => _isSaving = true);

    try {
      // Copy the photo into permanent app storage so it survives
      // temp-file cleanup between app restarts.
      final appDir = await getApplicationDocumentsDirectory();
      final id = const Uuid().v4();
      final savedPhotoPath =
          '${appDir.path}/checkin_$id${_extensionOf(_photo!.path)}';
      await _photo!.copy(savedPhotoPath);

      final checkIn = CheckIn(
        id: id,
        note: _noteController.text.trim(),
        photoPath: savedPhotoPath,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        accuracy: _position!.accuracy,
        createdAt: DateTime.now(),
      );

      await StorageService.add(checkIn);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save check-in: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    return dot == -1 ? '.jpg' : path.substring(dot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Check-In')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
                hintText: 'e.g. Site inspection, north gate',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Note is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            PhotoPickerField(
              photo: _photo,
              onChanged: (file) => setState(() => _photo = file),
              showRequiredError: _attemptedSubmit,
            ),
            const SizedBox(height: 20),
            LocationField(
              onLocationFetched: (pos) => setState(() => _position = pos),
              showRequiredError: _attemptedSubmit,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
