import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.tagName,
    required this.releaseUrl,
    required this.apkDownloadUrl,
  });

  final String currentVersion;
  final String latestVersion;
  final String tagName;
  final String releaseUrl;
  final String? apkDownloadUrl;

  bool get updateAvailable =>
      compareVersionNames(latestVersion, currentVersion) > 0;
}

class UpdateService {
  const UpdateService();

  static const fallbackVersion = '1.2.0';
  static const repository = 'WalterCQ/SWE311-retro-tech-marketplace';
  static const releasePageUrl =
      'https://github.com/$repository/releases/latest';

  static const _channel = MethodChannel('retro_tech_marketplace/app_update');
  static final Uri _latestReleaseApi = Uri.https(
    'api.github.com',
    '/repos/$repository/releases/latest',
  );

  Future<AppUpdateInfo> checkLatestRelease() async {
    final currentVersion = await _currentVersionName();
    final release = await _fetchLatestRelease();
    return AppUpdateInfo(
      currentVersion: currentVersion,
      latestVersion: _normalizeVersion(release.tagName),
      tagName: release.tagName,
      releaseUrl: release.releaseUrl,
      apkDownloadUrl: release.apkDownloadUrl,
    );
  }

  Future<void> downloadAndInstallUpdate(
    AppUpdateInfo update, {
    UpdateDownloadProgress? onProgress,
  }) async {
    if (!Platform.isAndroid) {
      throw const UpdateInstallException(
        'In-app installation is only available on Android.',
      );
    }

    final apkDownloadUrl = update.apkDownloadUrl;
    final apkUri = apkDownloadUrl == null ? null : Uri.tryParse(apkDownloadUrl);
    if (apkUri == null || !apkUri.hasScheme) {
      throw const UpdateInstallException(
        'No APK download was found for this release.',
      );
    }

    final apkFile = await _downloadApk(apkUri, update, onProgress: onProgress);
    try {
      final opened = await _channel.invokeMethod<bool>('installApk', {
        'filePath': apkFile.path,
      });
      if (opened != true) {
        throw const UpdateInstallException(
          'Could not open the Android installer.',
        );
      }
    } on MissingPluginException {
      throw const UpdateInstallException(
        'In-app installation is only available on Android.',
      );
    } on PlatformException catch (error) {
      if (error.code == 'unknown_sources_disabled') {
        throw const UpdateInstallException(
          'Allow installs from this app in Android settings, then retry.',
        );
      }
      throw const UpdateInstallException(
        'Could not open the Android installer.',
      );
    }
  }

  Future<String> _currentVersionName() async {
    try {
      final info = await _channel.invokeMapMethod<String, Object?>(
        'getAppInfo',
      );
      final versionName = info?['versionName']?.toString().trim();
      if (versionName != null && versionName.isNotEmpty) {
        return _normalizeVersion(versionName);
      }
    } on MissingPluginException {
      // Widget tests and unsupported platforms use the checked-in fallback.
    } on PlatformException {
      // Keep update checks usable even if native metadata is unavailable.
    }
    return fallbackVersion;
  }

  Future<_ReleaseMetadata> _fetchLatestRelease() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client
          .getUrl(_latestReleaseApi)
          .timeout(const Duration(seconds: 8));
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
        ..set(HttpHeaders.userAgentHeader, 'RetroTechMarketplace');

      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      final body = await utf8.decodeStream(response);
      if (response.statusCode != HttpStatus.ok) {
        throw const UpdateCheckException();
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, Object?>) {
        throw const UpdateCheckException();
      }

      final tagName = decoded['tag_name']?.toString() ?? '';
      final releaseUrl = decoded['html_url']?.toString() ?? releasePageUrl;
      if (tagName.trim().isEmpty) {
        throw const UpdateCheckException();
      }

      return _ReleaseMetadata(
        tagName: tagName,
        releaseUrl: releaseUrl,
        apkDownloadUrl: selectApkDownloadUrlFromRelease(decoded),
      );
    } on TimeoutException {
      throw const UpdateCheckException();
    } on FormatException {
      throw const UpdateCheckException();
    } on IOException {
      throw const UpdateCheckException();
    } finally {
      client.close(force: true);
    }
  }

  Future<File> _downloadApk(
    Uri apkUri,
    AppUpdateInfo update, {
    UpdateDownloadProgress? onProgress,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    IOSink? sink;
    try {
      final request = await client
          .getUrl(apkUri)
          .timeout(const Duration(seconds: 15));
      request.headers.set(HttpHeaders.userAgentHeader, 'RetroTechMarketplace');

      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );
      if (response.statusCode < HttpStatus.ok ||
          response.statusCode >= HttpStatus.multipleChoices) {
        throw const UpdateInstallException(
          'Update download failed. Try again later.',
        );
      }

      final cacheDirectory = Directory(await _updateCacheDirectoryPath());
      if (!await cacheDirectory.exists()) {
        await cacheDirectory.create(recursive: true);
      }

      final apkFile = File(
        '${cacheDirectory.path}/retro_tech_update_${_safeFileNamePart(update.tagName)}.apk',
      );
      sink = apkFile.openWrite();

      final totalBytes = response.contentLength > 0
          ? response.contentLength
          : null;
      var downloadedBytes = 0;
      onProgress?.call(totalBytes == null ? null : 0);

      await for (final chunk in response.timeout(const Duration(seconds: 30))) {
        downloadedBytes += chunk.length;
        sink.add(chunk);
        if (totalBytes != null) {
          onProgress?.call(downloadedBytes / totalBytes);
        }
      }

      await sink.close();
      sink = null;

      if (!await apkFile.exists() || await apkFile.length() == 0) {
        throw const UpdateInstallException(
          'Update download failed. Try again later.',
        );
      }

      onProgress?.call(1);
      return apkFile;
    } on UpdateInstallException {
      rethrow;
    } on TimeoutException {
      throw const UpdateInstallException(
        'Update download timed out. Try again later.',
      );
    } on IOException {
      throw const UpdateInstallException(
        'Update download failed. Try again later.',
      );
    } finally {
      await sink?.close();
      client.close(force: true);
    }
  }

  Future<String> _updateCacheDirectoryPath() async {
    try {
      final path = await _channel.invokeMethod<String>('getUpdateCacheDir');
      if (path != null && path.trim().isNotEmpty) {
        return path;
      }
    } on MissingPluginException {
      // Tests and non-Android shells can use Dart's temporary directory.
    } on PlatformException {
      // Fall back to Dart's temporary directory if native cache lookup fails.
    }
    return Directory.systemTemp.path;
  }
}

class UpdateCheckException implements Exception {
  const UpdateCheckException();
}

class UpdateInstallException implements Exception {
  const UpdateInstallException(this.message);

  final String message;
}

typedef UpdateDownloadProgress = void Function(double? progress);

class _ReleaseMetadata {
  const _ReleaseMetadata({
    required this.tagName,
    required this.releaseUrl,
    required this.apkDownloadUrl,
  });

  final String tagName;
  final String releaseUrl;
  final String? apkDownloadUrl;
}

String? selectApkDownloadUrlFromRelease(Map<String, Object?> release) {
  final assets = release['assets'];
  if (assets is! List) return null;

  for (final asset in assets) {
    if (asset is! Map) continue;

    final name = asset['name']?.toString().trim().toLowerCase() ?? '';
    final downloadUrl = asset['browser_download_url']?.toString().trim() ?? '';
    if (downloadUrl.isEmpty) continue;

    final parsedUrl = Uri.tryParse(downloadUrl);
    final urlPath = parsedUrl?.path.toLowerCase() ?? downloadUrl.toLowerCase();
    if (name.endsWith('.apk') || urlPath.endsWith('.apk')) {
      return downloadUrl;
    }
  }

  return null;
}

int compareVersionNames(String left, String right) {
  final leftParts = _versionParts(left);
  final rightParts = _versionParts(right);
  final maxLength = leftParts.length > rightParts.length
      ? leftParts.length
      : rightParts.length;

  for (var i = 0; i < maxLength; i += 1) {
    final leftValue = i < leftParts.length ? leftParts[i] : 0;
    final rightValue = i < rightParts.length ? rightParts[i] : 0;
    if (leftValue != rightValue) {
      return leftValue.compareTo(rightValue);
    }
  }
  return 0;
}

String _normalizeVersion(String value) {
  final trimmed = value.trim();
  final withoutBuild = trimmed.split('+').first;
  return withoutBuild.startsWith('v')
      ? withoutBuild.substring(1)
      : withoutBuild;
}

List<int> _versionParts(String value) {
  return _normalizeVersion(
    value,
  ).split('.').map((part) => int.tryParse(part) ?? 0).toList(growable: false);
}

String _safeFileNamePart(String value) {
  final safe = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
  return safe.isEmpty ? 'latest' : safe;
}
