import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Инициирует скачивание PNG-файла в браузере.
void downloadImageBytes(Uint8List bytes) {
  final blob = web.Blob(
    [bytes.buffer.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = 'emojimia-mood.png';
  anchor.click();
  web.URL.revokeObjectURL(url);
}
