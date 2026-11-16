import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/data/page_fetchers.dart';

class _MockFunctions() extends Mock implements FirebaseFunctions;

class _MockCallable() extends Mock implements HttpsCallable;

class _MockResult()
    extends Mock
    implements HttpsCallableResult<Map<Object?, Object?>>;

final Uri _url = Uri.parse('https://a.com/soup');

Matcher _failsWith(ImportFailureReason reason) => throwsA(
  isA<ImportFailure>()
      .having((f) => f.reason, 'reason', reason)
      .having((f) => f.site, 'site', 'a.com'),
);

void main() {
  group('directPageFetcher', () {
    test('reads the page as UTF-8 and names the app', () async {
      late http.BaseRequest sent;
      final fetch = directPageFetcher(
        MockClient((request) async {
          sent = request;
          // No charset, which would otherwise default to Latin-1.
          return http.Response.bytes(utf8.encode('<p>Crème</p>'), 200);
        }),
      );

      final page = await fetch(_url);

      expect(page.html, '<p>Crème</p>');
      expect(page.url, _url);
      expect(sent.headers['User-Agent'], importUserAgent);
    });

    test('fails as unreachable on an error status', () async {
      final fetch = directPageFetcher(
        MockClient((_) async => http.Response('', 404)),
      );

      await expectLater(fetch(_url), _failsWith(.unreachable));
    });

    test('fails as unreachable when the request fails', () async {
      final fetch = directPageFetcher(
        MockClient((request) => Future.error(http.ClientException('offline'))),
      );

      await expectLater(fetch(_url), _failsWith(.unreachable));
    });
  });

  group('proxyPageFetcher', () {
    late _MockFunctions functions;
    late _MockCallable callable;

    setUp(() {
      functions = _MockFunctions();
      callable = _MockCallable();
      when(() => functions.httpsCallable('fetchProxy')).thenReturn(callable);
    });

    test('returns the page and its final address', () async {
      final result = _MockResult();
      when(() => result.data).thenReturn({
        'url': 'https://a.com/soup/',
        'contentType': 'text/html',
        'body': '<p>Soup</p>',
      });
      when(() => callable.call<Map<Object?, Object?>>({'url': _url.toString()}))
          .thenAnswer((_) async => result);

      final page = await proxyPageFetcher(functions)(_url);

      expect(page.url, Uri.parse('https://a.com/soup/'));
      expect(page.html, '<p>Soup</p>');
    });

    for (final (reason, expected) in [
      ('invalidUrl', ImportFailureReason.invalidUrl),
      ('blockedAddress', ImportFailureReason.invalidUrl),
      ('unsupportedContentType', ImportFailureReason.noRecipe),
      ('timeout', ImportFailureReason.unreachable),
      (null, ImportFailureReason.unreachable),
    ]) {
      test('maps the proxy reason $reason to ${expected.name}', () async {
        when(() => callable.call<Map<Object?, Object?>>(any<Object?>()))
            .thenThrow(
              FirebaseFunctionsException(
                message: 'failed',
                code: 'unavailable',
                details: reason == null ? null : {'reason': reason},
              ),
            );

        await expectLater(
          proxyPageFetcher(functions)(_url),
          _failsWith(expected),
        );
      });
    }
  });
}
