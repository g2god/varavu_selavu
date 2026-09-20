import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileStorageHelper {
  static const String _folderRelativePath = 'varavu_selavu/exports';

  /// Requests storage permissions when needed (particularly on Android).
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // For Android, check storage permission.
    // On Android 13+ (SDK 33+), granular permissions or scoped public directories don't require WRITE_EXTERNAL_STORAGE,
    // but on older versions (SDK <= 29/32) it is required.
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      final result = await Permission.storage.request();
      if (!result.isGranted && !result.isLimited) {
        // If permanently denied or denied, check manageExternalStorage if needed, or return false.
        return false;
      }
    }
    return true;
  }

  /// Resolves or creates the public `varavu_selavu/exports` directory.
  /// Files saved here survive app uninstallation.
  static Future<Directory> getExportsDirectory() async {
    Directory? baseDir;

    if (Platform.isAndroid) {
      // Direct access to primary shared public Download directory
      final primaryDownloadDir = Directory('/storage/emulated/0/Download');
      if (await primaryDownloadDir.exists()) {
        baseDir = primaryDownloadDir;
      } else {
        // Fallback to downloads path from path_provider
        baseDir = await getDownloadsDirectory() ?? await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      baseDir = await getApplicationDocumentsDirectory();
    } else {
      // Windows / macOS / Linux
      baseDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    }

    final targetDir = Directory('${baseDir!.path}/$_folderRelativePath');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    return targetDir;
  }

  /// Saves binary data (e.g. PDF) directly into `varavu_selavu/exports`.
  static Future<File> saveBinaryFile({
    required String fileName,
    required List<int> bytes,
  }) async {
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      throw Exception('Storage permission was denied. Unable to save export.');
    }

    final exportDir = await getExportsDirectory();
    final file = File('${exportDir.path}/$fileName');
    return await file.writeAsBytes(bytes, flush: true);
  }

  /// Saves text data (e.g. CSV) directly into `varavu_selavu/exports`.
  static Future<File> saveTextFile({
    required String fileName,
    required String content,
  }) async {
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      throw Exception('Storage permission was denied. Unable to save export.');
    }

    final exportDir = await getExportsDirectory();
    final file = File('${exportDir.path}/$fileName');
    return await file.writeAsString(content, flush: true);
  }
}
