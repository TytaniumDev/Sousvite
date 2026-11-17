import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sousvite/features/account/sync/data/drive_access.dart';
import 'package:sousvite/features/account/sync/data/drive_rest_folder.dart';
import 'package:sync/sync.dart';

import '../fakes.dart';

Map<String, Object?> _file(String id, String name) => {
  'id': id,
  'name': name,
  'createdTime': '2026-11-16T12:00:00.000Z',
};

void main() {
  late FakeDriveAccess access;
  late List<http.Request> requests;

  DriveRestFolder folder(
    http.Response Function(http.Request request) respond,
  ) => DriveRestFolder(
    client: MockClient((request) async {
      requests.add(request);
      return respond(request);
    }),
    access: access,
  );

  setUp(() {
    access = FakeDriveAccess();
    requests = [];
  });

  group(DriveRestFolder, () {
    test('lists every page of the app folder', () async {
      final drive = folder((request) {
        final token = request.url.queryParameters['pageToken'];
        return http.Response(
          jsonEncode({
            'files': [_file(token ?? 'a', 'changes/p/1.json')],
            if (token == null) 'nextPageToken': 'b',
          }),
          200,
        );
      });

      final files = await drive.list(createdAfter: DateTime.utc(2026));

      expect(files.map((file) => file.id), ['a', 'b']);
      final query = requests.first.url.queryParameters;
      expect(query['spaces'], 'appDataFolder');
      expect(query['q'], "createdTime > '2026-01-01T00:00:00.000Z'");
      expect(requests.first.headers['Authorization'], 'Bearer t1');
    });

    test('finds a file by its exact name', () async {
      final drive = folder(
        (request) => http.Response(
          jsonEncode({
            'files': request.url.queryParameters['q'] == "name = 'latest.json'"
                ? [_file('l', 'latest.json')]
                : <Object>[],
          }),
          200,
        ),
      );

      expect((await drive.find('latest.json'))?.id, 'l');
      expect(await drive.find("it's.json"), isNull);
      expect(requests.last.url.queryParameters['q'], r"name = 'it\'s.json'");
    });

    test('reads, creates, and updates files', () async {
      final drive = folder(
        (request) => switch (request.method) {
          'GET' => http.Response.bytes([7], 200),
          'POST' => http.Response(jsonEncode(_file('n', 'new.json')), 200),
          _ => http.Response('', 200),
        },
      );

      expect(await drive.read('x'), [7]);
      expect(requests.last.url.path, '/drive/v3/files/x');
      final created = await drive.create('new.json', Uint8List.fromList([1]));
      expect(created.id, 'n');
      expect(requests.last.body, contains('"parents":["appDataFolder"]'));
      await drive.update('n', Uint8List.fromList([2]));
      expect(requests.last.method, 'PATCH');
      expect(requests.last.url.path, '/upload/drive/v3/files/n');
    });

    test('renews a rejected token once, then asks the user', () async {
      final drive = folder((_) => http.Response('', 401));

      await expectLater(drive.read('x'), throwsA(isA<DriveSignInRequired>()));
      expect(requests, hasLength(2));
      expect(access.discarded, ['t1', 't1']);
    });

    test('turns rate limits into DriveRateLimited', () async {
      await expectLater(
        folder((_) => http.Response('', 429)).read('x'),
        throwsA(isA<DriveRateLimited>()),
      );
      await expectLater(
        folder((_) => http.Response('{"reason":"userRateLimitExceeded"}', 403))
            .read('x'),
        throwsA(isA<DriveRateLimited>()),
      );
    });

    test('reports other failures with their status', () async {
      await expectLater(
        folder((_) => http.Response('', 500)).read('x'),
        throwsA(
          isA<DriveRequestFailed>().having(
            (error) => error.toString(),
            'text',
            'DriveRequestFailed(500)',
          ),
        ),
      );
    });

    test('needs the user when no token can be had silently', () async {
      access.tokenError = const DriveSignInRequired();

      await expectLater(
        folder((_) => http.Response('', 200)).read('x'),
        throwsA(isA<DriveSignInRequired>()),
      );
      expect(const DriveSignInRequired().toString(), 'DriveSignInRequired');
    });
  });
}
