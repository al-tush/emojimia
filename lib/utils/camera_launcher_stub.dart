import 'dart:typed_data';
import 'package:flutter/material.dart';

// На не-web платформах вся камерная логика живёт в image_picker.
// Этот файл никогда не вызывается на Android/iOS, но нужен для компиляции.
Future<void> launchWebCamera(
  BuildContext context,
  void Function(Uint8List bytes) onCapture,
) async {}
