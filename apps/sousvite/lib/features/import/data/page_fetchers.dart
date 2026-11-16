import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;
import 'package:sousvite/features/import/application/import_failure.dart';

/// A fetched recipe page: its address after redirects, which relative
/// links resolve against, and its HTML.
typedef FetchedPage = ({Uri url, String html});

/// Fetches the page at a web address. Throws [ImportFailure] when it can't.
typedef PageFetcher = Future<FetchedPage> Function(Uri url);

/// How the app identifies itself to recipe sites, the same as the fetch
/// proxy does (ENGINEERING.md §14).
const importUserAgent =
    'Sousvite/1.0 (+https://github.com/TytaniumDev/Sousvite)';

/// Fetches pages straight from the site with [client], on iOS and Android.
/// Pages are read as UTF-8, which nearly every recipe site uses.
PageFetcher directPageFetcher(http.Client client) => (url) async {
  try {
    final response = await client.send(
      http.Request('GET', url)..headers['User-Agent'] = importUserAgent,
    );
    final body = await response.stream.toBytes();
    if (response.statusCode != 200) {
      throw ImportFailure(.unreachable, site: url.host);
    }
    return (
      url: switch (response) {
        http.BaseResponseWithUrl(url: final finalUrl) => finalUrl,
        _ => url,
      },
      html: utf8.decode(body, allowMalformed: true),
    );
  } on http.ClientException {
    throw ImportFailure(.unreachable, site: url.host);
  }
};

/// Fetches pages through the `fetchProxy` function, on web, where browsers
/// block cross-site requests (ENGINEERING.md §14).
PageFetcher proxyPageFetcher(FirebaseFunctions functions) => (url) async {
  try {
    final result = await functions
        .httpsCallable('fetchProxy')
        .call<Map<Object?, Object?>>({'url': url.toString()});
    final page = result.data;
    return (
      url: Uri.parse(page['url']! as String),
      html: page['body']! as String,
    );
  } on FirebaseFunctionsException catch (error) {
    final reason = switch (error.details) {
      {'reason': final Object reason} => reason,
      _ => null,
    };
    throw ImportFailure(switch (reason) {
      'invalidUrl' || 'blockedAddress' => .invalidUrl,
      'unsupportedContentType' => .noRecipe,
      _ => .unreachable,
    }, site: url.host);
  }
};
