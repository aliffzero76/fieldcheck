import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// "Take Photo" button + preview area, per wireframe screen 2.
/// Handles the image_picker call and gracefully reports permission /
/// camera errors instead of crashing.
class PhotoPickerField extends StatelessWidget {
  final File? photo;
  final ValueChanged<File?> onChanged;
  final bool showRequiredError;

  const PhotoPickerField({
    super.key,
    required this.photo,
    required this.onChanged,
    this.showRequiredError = false,
  });

  Future<void> _takePhoto(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? shot = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (shot != null) {
        onChanged(File(shot.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open camera: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _takePhoto(context),
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(photo == null ? 'Take Photo' : 'Retake Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const _RequiredTag(),
          ],
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: showRequiredError && photo == null
                    ? Colors.red
                    : Colors.grey.shade300,
              ),
            ),
            child: photo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(photo!, fit: BoxFit.cover),
                  )
                : Center(
                    child: Text(
                      'IMG / ✕',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
          ),
        ),
        if (showRequiredError && photo == null)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Photo is required',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _RequiredTag extends StatelessWidget {
  const _RequiredTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'required',
        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
      ),
    );
  }
}
