import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../screens/web_camera_screen.dart';

Future<void> launchWebCamera(
  BuildContext context,
  void Function(Uint8List bytes) onCapture,
) async {
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => WebCameraScreen(onCapture: onCapture),
    ),
  );
}
