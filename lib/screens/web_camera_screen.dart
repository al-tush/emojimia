import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class WebCameraScreen extends StatefulWidget {
  const WebCameraScreen({super.key, required this.onCapture});

  final void Function(Uint8List bytes) onCapture;

  @override
  State<WebCameraScreen> createState() => _WebCameraScreenState();
}

class _WebCameraScreenState extends State<WebCameraScreen> {
  static int _viewCounter = 0;
  late final String _viewId;

  web.HTMLVideoElement? _video;
  web.MediaStream? _stream;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _viewId = 'web-camera-${_viewCounter++}';
    _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      final video = web.HTMLVideoElement()
        ..autoplay = true
        ..setAttribute('playsinline', '')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      _video = video;

      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int id) => video,
      );

      final constraints = web.MediaStreamConstraints(
        video: web.MediaTrackConstraints(facingMode: 'user'.toJS),
        audio: false.toJS,
      );

      final stream = await web.window.navigator.mediaDevices
          .getUserMedia(constraints)
          .toDart;

      video.srcObject = stream;
      _stream = stream;

      final completer = Completer<void>();
      video.onloadedmetadata = ((web.Event _) {
        if (!completer.isCompleted) completer.complete();
      }).toJS;
      await completer.future;

      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) setState(() => _error = 'Ошибка доступа к камере.\nРазрешите доступ к камере в браузере.');
    }
  }

  Future<void> _capture() async {
    final video = _video;
    if (video == null || video.videoWidth == 0) return;

    final canvas = web.HTMLCanvasElement()
      ..width = video.videoWidth
      ..height = video.videoHeight;

    final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;
    ctx.drawImage(video, 0, 0);

    final bytes = await _canvasToBytes(canvas);
    _stopStream();

    if (mounted) {
      Navigator.of(context).pop();
      widget.onCapture(bytes);
    }
  }

  Future<Uint8List> _canvasToBytes(web.HTMLCanvasElement canvas) {
    final completer = Completer<Uint8List>();
    // Колбэк toBlob обязан быть синхронным (void) — async-работу делаем в отдельном методе
    canvas.toBlob(
      ((web.Blob blob) {
        _readBlobAsync(blob, completer);
      }).toJS,
      'image/jpeg',
      0.92.toJS,
    );
    return completer.future;
  }

  // Вызывается из синхронного JS-колбэка, возвращаемый Future намеренно игнорируется
  Future<void> _readBlobAsync(
    web.Blob blob,
    Completer<Uint8List> completer,
  ) async {
    try {
      final reader = web.FileReader();
      final done = Completer<void>();
      reader.onloadend = ((web.Event _) {
        if (!done.isCompleted) done.complete();
      }).toJS;
      reader.readAsArrayBuffer(blob);
      await done.future;
      final result = reader.result as JSArrayBuffer;
      completer.complete(result.toDart.asUint8List());
    } catch (e) {
      completer.completeError(e);
    }
  }

  void _stopStream() {
    final tracks = _stream?.getTracks().toDart;
    if (tracks != null) {
      for (final track in tracks) {
        track.stop();
      }
    }
    _video?.srcObject = null;
    _stream = null;
  }

  @override
  void dispose() {
    _stopStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Камера'),
      ),
      body: _error != null
          ? _ErrorView(message: _error!)
          : Stack(
              fit: StackFit.expand,
              children: [
                HtmlElementView(viewType: _viewId),
                if (!_ready)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _CaptureButton(
                      enabled: _ready,
                      onTap: _capture,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: enabled
              ? Colors.white.withValues(alpha: 0.85)
              : Colors.grey,
        ),
        child: const Icon(Icons.camera_alt, size: 32, color: Colors.black87),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
