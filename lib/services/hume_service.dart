import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/hume_result.dart';

class HumeApiException implements Exception {
  const HumeApiException(this.message);
  final String message;

  @override
  String toString() => 'HumeApiException: $message';
}

class HumeService {
  HumeService({required this.apiKey});

  final String apiKey;

  static const _baseUrl = 'https://api.hume.ai/v0/batch';
  static const _maxPollAttempts = 15;
  static const _pollInterval = Duration(seconds: 2);

  Map<String, String> get _authHeader => {'X-Hume-Api-Key': apiKey};

  Future<HumeResult> analyze(
    Uint8List imageBytes, {
    void Function(String status)? onStatusUpdate,
  }) async {
    onStatusUpdate?.call('Отправка изображения в Hume AI...');
    final jobId = await _startJob(imageBytes);

    onStatusUpdate?.call('Анализ эмоций...');
    final predictions = await _pollForResult(jobId, onStatusUpdate);

    onStatusUpdate?.call('Обработка результатов...');
    return _parsePredictions(predictions);
  }

  Future<String> _startJob(Uint8List imageBytes) async {
    // Hume Batch API принимает файл через multipart/form-data:
    //   поле "json" — конфигурация моделей
    //   поле "file" — бинарный файл изображения
    final configJson = jsonEncode({
      'models': {
        'face': {
          'facs': <String, dynamic>{},
          'descriptions': <String, dynamic>{},
        },
      },
    });

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/jobs'),
    )
      ..headers.addAll(_authHeader)
      ..fields['json'] = configJson
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'photo.jpg',
        ),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    // ignore: avoid_print
    print('[HumeService] startJob status=${response.statusCode} body=${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw HumeApiException(
        'Не удалось запустить задачу (${response.statusCode}): ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final jobId = json['job_id'] as String?;
    if (jobId == null || jobId.isEmpty) {
      throw const HumeApiException('Hume AI не вернул job_id');
    }
    // ignore: avoid_print
    print('[HumeService] job_id=$jobId');
    return jobId;
  }

  Future<List<dynamic>> _pollForResult(
    String jobId,
    void Function(String)? onStatusUpdate,
  ) async {
    for (var attempt = 0; attempt < _maxPollAttempts; attempt++) {
      await Future<void>.delayed(_pollInterval);

      final response = await http.get(
        Uri.parse('$_baseUrl/jobs/$jobId'),
        headers: _authHeader,
      );

      if (response.statusCode != 200) {
        throw HumeApiException(
          'Ошибка при опросе статуса (${response.statusCode})',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = (json['state'] as Map?)?['status'] as String? ?? '';

      if (status == 'COMPLETED') {
        return await _fetchPredictions(jobId);
      } else if (status == 'FAILED') {
        throw const HumeApiException('Задача Hume AI завершилась с ошибкой');
      }

      final elapsed = (attempt + 1) * _pollInterval.inSeconds;
      onStatusUpdate?.call('Анализ... ($elapsed с)');
    }

    throw const HumeApiException('Превышено время ожидания ответа от Hume AI');
  }

  Future<List<dynamic>> _fetchPredictions(String jobId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/jobs/$jobId/predictions'),
      headers: _authHeader,
    );

    if (response.statusCode != 200) {
      throw HumeApiException(
        'Не удалось получить предсказания (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);
    // Выводим сырой ответ для диагностики структуры
    // ignore: avoid_print
    print('[HumeService] predictions raw: ${response.body.substring(0, response.body.length.clamp(0, 800))}');
    if (decoded is List) return decoded;
    if (decoded is Map) return [decoded];
    throw const HumeApiException('Неожиданный формат ответа от Hume AI');
  }

  HumeResult _parsePredictions(List<dynamic> responseList) {
    try {
      if (responseList.isEmpty) {
        throw const HumeApiException('Результаты отсутствуют в ответе (пустой массив)');
      }

      // ignore: avoid_print
      print('[HumeService] responseList[0] keys: ${(responseList[0] as Map?)?.keys.toList()}');

      final fileResult = responseList[0] as Map<String, dynamic>;

      // Hume может отдавать либо { source, results } либо { source, predictions }
      List predictions0;
      final resultsWrapper = fileResult['results'] as Map?;
      if (resultsWrapper != null) {
        predictions0 = (resultsWrapper['predictions'] as List?) ?? [];
      } else {
        predictions0 = (fileResult['predictions'] as List?) ?? [];
      }

      // ignore: avoid_print
      print('[HumeService] predictions0 length: ${predictions0.length}');

      if (predictions0.isEmpty) {
        throw const HumeApiException('Нет предсказаний для файла');
      }

      final models = (predictions0[0] as Map)['models'] as Map?;
      if (models == null) {
        throw const HumeApiException('Нет данных моделей в ответе');
      }

      final faceModel = models['face'] as Map?;
      if (faceModel == null) {
        throw const HumeApiException('Лицо не обнаружено на изображении');
      }

      final groupedPredictions = faceModel['grouped_predictions'] as List?;
      if (groupedPredictions == null || groupedPredictions.isEmpty) {
        throw const HumeApiException('Лицо не обнаружено на изображении');
      }

      final facePredictions =
          (groupedPredictions[0] as Map)['predictions'] as List?;
      if (facePredictions == null || facePredictions.isEmpty) {
        throw const HumeApiException('Нет данных предсказания лица');
      }

      final facePred = facePredictions[0] as Map<String, dynamic>;

      final emotions = ((facePred['emotions'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map(EmotionScore.fromJson)
          .toList();

      final facs = ((facePred['facs'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map(FacsScore.fromJson)
          .toList();

      final descriptions = ((facePred['descriptions'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map(DescriptionScore.fromJson)
          .toList();

      return HumeResult(
        emotions: emotions,
        facs: facs,
        descriptions: descriptions,
      );
    } on HumeApiException {
      rethrow;
    } catch (e) {
      throw HumeApiException('Ошибка парсинга ответа: $e');
    }
  }
}
