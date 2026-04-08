import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Resolves artwork URIs for background media controls.
///
/// Background UI (Android notification / lock screen) cannot render Flutter
/// asset paths directly. We copy asset artwork to a real local file and:
/// - Android: convert to a `content://` URI via FileProvider (MethodChannel)
/// - iOS/macOS: use a `file://` URI
class LocalArtworkResolver {
  static const MethodChannel _fileProviderChannel = MethodChannel('app.fileprovider');

  static Future<Uri?> resolve(String? imageUrl, {String? cacheKey}) async {
    if (imageUrl == null || imageUrl.trim().isEmpty) return null;
    final url = imageUrl.trim();

    // Remote images can be used as-is (when allowed/available).
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Uri.parse(url);
    }

    // If a file path is already provided.
    if (url.startsWith('file://')) {
      final file = File(Uri.parse(url).toFilePath());
      if (!await file.exists()) return null;
      return _platformUriForFile(file);
    }
    if (url.startsWith('/')) {
      final file = File(url);
      if (!await file.exists()) return null;
      return _platformUriForFile(file);
    }

    // Flutter asset path: copy into cache so native side can load it.
    if (url.startsWith('assets/')) {
      final file = await _ensureAssetCopiedToCache(url, cacheKey: cacheKey);
      return _platformUriForFile(file);
    }

    // Fallback: try parsing as URI.
    return Uri.tryParse(url);
  }

  static Future<File> _ensureAssetCopiedToCache(
    String assetPath, {
    String? cacheKey,
  }) async {
    final cacheDir = await getTemporaryDirectory();
    final ext = _extensionFromAsset(assetPath);
    final safeKey = (cacheKey == null || cacheKey.isEmpty)
        ? assetPath.split('/').last.split('.').first
        : cacheKey;
    final fileName = 'artwork_${safeKey.replaceAll(RegExp(r"[^a-zA-Z0-9_\\-]"), "_")}$ext';
    final outFile = File('${cacheDir.path}/$fileName');
    if (await outFile.exists()) return outFile;

    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    await outFile.writeAsBytes(bytes, flush: true);
    return outFile;
  }

  static String _extensionFromAsset(String assetPath) {
    final lower = assetPath.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return '.jpg';
    if (lower.endsWith('.webp')) return '.webp';
    return '.png';
  }

  static Future<Uri> _platformUriForFile(File file) async {
    if (Platform.isAndroid) {
      final uriString = await _fileProviderChannel.invokeMethod<String>(
        'getContentUri',
        {'path': file.path},
      );
      return Uri.parse(uriString!);
    }
    return Uri.file(file.path);
  }
}

