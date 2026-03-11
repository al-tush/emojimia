import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/camera_launcher.dart';
import 'processing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openCamera(BuildContext context) async {
    if (kIsWeb) {
      await launchWebCamera(context, (bytes) {
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProcessingScreen(imageBytes: bytes),
            ),
          );
        }
      });
    } else {
      await _pickWithImagePicker(context, ImageSource.camera);
    }
  }

  Future<void> _pickWithImagePicker(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: source,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.front,
    );
    if (context.mounted && photo != null) {
      final bytes = await photo.readAsBytes();
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProcessingScreen(imageBytes: bytes),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.face_retouching_natural,
                    size: 64,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Emojimia',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Сделайте снимок лица — Hume AI распознает\nдо 48 нюансов эмоций',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 56),
                FilledButton.icon(
                  onPressed: () => _openCamera(context),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Открыть камеру'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _pickWithImagePicker(context, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Выбрать из галереи'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    textStyle: const TextStyle(fontSize: 16),
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
