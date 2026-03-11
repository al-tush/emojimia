import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/hume_service.dart';
import '../models/hume_result.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String _statusText = 'Подготовка...';

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  Future<void> _analyze() async {
    const apiKey = String.fromEnvironment('HUME_API_KEY');

    if (apiKey.isEmpty) {
      _navigateToResult(
        error: 'HUME_API_KEY не задан. Запустите приложение с --dart-define=HUME_API_KEY=ваш_ключ',
      );
      return;
    }

    final service = HumeService(apiKey: apiKey);

    try {
      final result = await service.analyze(
        widget.imageBytes,
        onStatusUpdate: (status) {
          if (mounted) setState(() => _statusText = status);
        },
      );
      _navigateToResult(result: result);
    } on HumeApiException catch (e) {
      _navigateToResult(error: e.message);
    } catch (e) {
      _navigateToResult(error: 'Непредвиденная ошибка: $e');
    }
  }

  void _navigateToResult({HumeResult? result, String? error}) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          imageBytes: widget.imageBytes,
          result: result,
          error: error,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Анализируем эмоции',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _statusText,
                  key: ValueKey(_statusText),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
