import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrition/nutrition.dart';
import 'package:sousvite/app/services/nutrition_api.dart';

class _MockFunctions() extends Mock implements FirebaseFunctions;

class _MockCallable() extends Mock implements HttpsCallable;

class _MockResult() extends Mock implements HttpsCallableResult<Object?>;

const _product = '''
{"products": [{"code": "1", "product_name": "Crème fraîche",
  "nutriments": {"energy-kcal_100g": 292}}]}''';

void main() {
  group('OnlineNutritionApi', () {
    test('searches and looks up through OnlineFoods', () async {
      final api = OnlineNutritionApi(
        OnlineFoods(
          openFoodFacts: OpenFoodFactsClient(
            (url, _) async =>
                url.path.startsWith('/api') ? '{"status": 0}' : _product,
          ),
        ),
      );

      expect((await api.search('creme')).single.food.name, 'Crème fraîche');
      expect(await api.lookupBarcode('1'), isNull);
    });
  });

  group('httpGet', () {
    test('reads the body as UTF-8 and sends the headers', () async {
      late http.Request sent;
      final get = httpGet(
        MockClient((request) async {
          sent = request;
          // No charset, which would otherwise default to Latin-1.
          return http.Response.bytes(utf8.encode('Crème'), 200);
        }),
      );

      final body = await get(Uri.https('a.com'), {'User-Agent': 'Sousvite'});

      expect(body, 'Crème');
      expect(sent.headers['User-Agent'], 'Sousvite');
    });

    test('throws on any status but 200', () async {
      final get = httpGet(MockClient((_) async => http.Response('', 503)));

      await expectLater(
        get(Uri.https('a.com'), const {}),
        throwsA(isA<http.ClientException>()),
      );
    });
  });

  group('usdaProxyCall', () {
    test('calls usdaProxy and returns plain JSON maps', () async {
      final functions = _MockFunctions();
      final callable = _MockCallable();
      final result = _MockResult();
      when(() => functions.httpsCallable('usdaProxy')).thenReturn(callable);
      when(() => callable.call<Object?>(any<Object?>()))
          .thenAnswer((_) async => result);
      when(() => result.data).thenReturn(<Object?, Object?>{
        'foods': [
          <Object?, Object?>{'fdcId': 1, 'description': 'OATS'},
        ],
      });

      final response = await usdaProxyCall(functions)({'action': 'search'});

      verify(() => callable.call<Object?>({'action': 'search'})).called(1);
      expect(parseUsdaSearch(response).single.food.name, 'OATS');
    });
  });
}
