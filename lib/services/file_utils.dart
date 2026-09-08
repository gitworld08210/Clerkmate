import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileUtils {
  /// Writes bytes to a file in the app's documents dir and returns the path.
  static Future<File> save(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final out = File(p.join(dir.path, fileName));
    await out.writeAsBytes(bytes, flush: true);
    return out;
  }

  /// Shares an already-saved file via the Android share sheet
  /// (WhatsApp, Gmail, Drive, etc.).
  static Future<void> share(File file, {String? text}) async {
    await Share.shareXFiles([XFile(file.path)], text: text);
  }
}
