import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:sousvite/features/account/sync/data/drive_access.dart';
import 'package:sync/sync.dart';

/// A Drive call that failed for a reason other than a rate limit or an
/// expired sign-in.
final class const DriveRequestFailed(
  /// The HTTP status Drive answered with.
  final int statusCode,
) implements Exception {
  @override
  String toString() => 'DriveRequestFailed($statusCode)';
}

/// The hidden Drive app folder over the Drive v3 REST API.
final class DriveRestFolder({
  /// Makes the requests. Tests pass a mock client.
  required final http.Client client,

  /// Supplies access tokens.
  required final DriveAccess access,
}) implements DriveAppFolder {
  static final Uri _files = Uri.parse(
    'https://www.googleapis.com/drive/v3/files',
  );
  static final Uri _upload = Uri.parse(
    'https://www.googleapis.com/upload/drive/v3/files',
  );
  static const _fileFields = 'id,name,createdTime';

  @override
  Future<List<DriveFile>> list({DateTime? createdAfter}) async {
    final files = <DriveFile>[];
    final since = createdAfter?.toUtc().toIso8601String();
    String? pageToken;
    do {
      final page = _json(
        await _send(
          'GET',
          _files.replace(
            queryParameters: {
              'spaces': 'appDataFolder',
              'pageSize': '1000',
              'fields': 'nextPageToken,files($_fileFields)',
              'orderBy': 'createdTime',
              if (since != null) 'q': "createdTime > '$since'",
              'pageToken': ?pageToken,
            },
          ),
        ),
      );
      files.addAll((page['files']! as List<Object?>).map(_file));
      pageToken = page['nextPageToken'] as String?;
    } while (pageToken != null);
    return files;
  }

  @override
  Future<DriveFile?> find(String name) async {
    final escaped = name.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    final page = _json(
      await _send(
        'GET',
        _files.replace(
          queryParameters: {
            'spaces': 'appDataFolder',
            'fields': 'files($_fileFields)',
            'q': "name = '$escaped'",
          },
        ),
      ),
    );
    final files = page['files']! as List<Object?>;
    return files.isEmpty ? null : _file(files.first);
  }

  @override
  Future<Uint8List> read(String fileId) async => (await _send(
    'GET',
    _files.replace(
      path: '${_files.path}/$fileId',
      queryParameters: {'alt': 'media'},
    ),
  )).bodyBytes;

  @override
  Future<DriveFile> create(String name, Uint8List bytes) async {
    const boundary = 'sousvite-upload';
    final body = BytesBuilder()
      ..add(
        utf8.encode(
          '--$boundary\r\n'
          'Content-Type: application/json; charset=UTF-8\r\n\r\n'
          '${jsonEncode({
            'name': name,
            'parents': ['appDataFolder'],
          })}\r\n'
          '--$boundary\r\n'
          'Content-Type: application/octet-stream\r\n\r\n',
        ),
      )
      ..add(bytes)
      ..add(utf8.encode('\r\n--$boundary--'));
    return _file(
      _json(
        await _send(
          'POST',
          _upload.replace(
            queryParameters: {'uploadType': 'multipart', 'fields': _fileFields},
          ),
          body: body.toBytes(),
          contentType: 'multipart/related; boundary=$boundary',
        ),
      ),
    );
  }

  @override
  Future<void> update(String fileId, Uint8List bytes) => _send(
    'PATCH',
    _upload.replace(
      path: '${_upload.path}/$fileId',
      queryParameters: {'uploadType': 'media'},
    ),
    body: bytes,
    contentType: 'application/octet-stream',
  );

  /// Sends one request with a current token, renewing it once if Drive
  /// rejects it, and turns Drive's errors into the port's exceptions.
  Future<http.Response> _send(
    String method,
    Uri url, {
    Uint8List? body,
    String? contentType,
  }) async {
    for (var attempt = 0; ; attempt++) {
      final token = await access.token();
      final request = http.Request(method, url)
        ..headers['Authorization'] = 'Bearer $token';
      if (body != null) request.bodyBytes = body;
      if (contentType != null) request.headers['Content-Type'] = contentType;
      final response = await http.Response.fromStream(
        await client.send(request),
      );
      final status = response.statusCode;
      if (status >= 200 && status < 300) return response;
      if (status == 401) {
        await access.discard(token);
        if (attempt == 0) continue;
        throw const DriveSignInRequired();
      }
      if (status == 429 || (status == 403 && _isRateLimit(response))) {
        throw const DriveRateLimited();
      }
      throw DriveRequestFailed(status);
    }
  }

  static bool _isRateLimit(http.Response response) =>
      response.body.contains('ateLimitExceeded');

  static Map<String, Object?> _json(http.Response response) =>
      jsonDecode(response.body) as Map<String, Object?>;

  static DriveFile _file(Object? json) {
    final file = json! as Map<String, Object?>;
    return (
      id: file['id']! as String,
      name: file['name']! as String,
      createdTime: DateTime.parse(file['createdTime']! as String),
    );
  }
}
