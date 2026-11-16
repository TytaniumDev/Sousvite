import 'package:html/parser.dart' as html;

/// [text] as plain text: tags removed, entities decoded, and runs of
/// whitespace collapsed. Recipe markup often embeds HTML in strings.
String cleanText(String text) {
  final plain = text.contains('<') || text.contains('&')
      ? html.parseFragment(text).text ?? ''
      : text;
  return plain.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// An ingredient line from a recipe page, without the notes some sites add
/// around it: cost notes such as `($0.20)` and doubled parentheses such as
/// `((minced))`.
String cleanIngredient(String text) => text
    .replaceAll(RegExp(r'\s*\(\$\d+(?:\.\d+)?\*?\)'), '')
    .replaceAllMapped(RegExp(r'\(\(([^()]*)\)\)'), (m) => '(${m[1]})')
    .trim();

/// An ISO 8601 duration such as `PT1H30M` or `P0Y0M0DT0H20M0S`, or null
/// when [text] isn't one or is zero.
Duration? parseIsoDuration(String? text) {
  final match = RegExp(
    r'^P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)W)?(?:(\d+)D)?'
    r'(?:T(?:(\d+(?:\.\d+)?)H)?(?:(\d+(?:\.\d+)?)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
    caseSensitive: false,
  ).firstMatch(text?.trim() ?? '');
  if (match == null) return null;
  // Years and months have no fixed length, and no recipe takes that long.
  if ((int.tryParse(match[1] ?? '') ?? 0) > 0 ||
      (int.tryParse(match[2] ?? '') ?? 0) > 0) {
    return null;
  }
  double part(int group) => double.tryParse(match[group] ?? '') ?? 0;
  final seconds =
      part(3) * 7 * 86400 +
      part(4) * 86400 +
      part(5) * 3600 +
      part(6) * 60 +
      part(7);
  return seconds <= 0 ? null : Duration(seconds: seconds.round());
}
