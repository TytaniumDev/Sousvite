import 'dart:convert';
import 'dart:io';

/// A recorded response in `test/fixtures/online/`, as its JSON text.
String fixtureText(String name) =>
    File('test/fixtures/online/$name').readAsStringSync();

/// A recorded response, decoded.
Object? fixture(String name) => jsonDecode(fixtureText(name));
