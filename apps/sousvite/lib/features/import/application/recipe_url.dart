/// The web address in [text], as people paste or type it: with or without
/// `https://`, with spaces around it. Text shared from another app often
/// wraps the link in words ("Chili https://…"), so a longer text gives its
/// first `http` or `https` link. Null when there's no address.
Uri? parseRecipeUrl(String text) {
  final words = text.trim().split(RegExp(r'\s+'));
  if (words.length > 1) {
    final link = words.firstWhere(
      (word) => word.startsWith(RegExp('https?://')),
      orElse: () => '',
    );
    return link.isEmpty ? null : _parseAddress(link);
  }
  return _parseAddress(words.single);
}

Uri? _parseAddress(String trimmed) {
  if (trimmed.isEmpty) return null;
  final withScheme = trimmed.contains('://') ? trimmed : 'https://$trimmed';
  final url = Uri.tryParse(withScheme);
  if (url == null || !const {'http', 'https'}.contains(url.scheme)) {
    return null;
  }
  // A host needs a dot ("example.com"), which rules out stray words.
  if (!url.host.contains('.') || url.host.endsWith('.')) return null;
  return url;
}
