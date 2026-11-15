/// The web address in [text], as people paste or type it: with or without
/// `https://`, with spaces around it. Null when it isn't one.
Uri? parseRecipeUrl(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty || trimmed.contains(' ')) return null;
  final withScheme = trimmed.contains('://') ? trimmed : 'https://$trimmed';
  final url = Uri.tryParse(withScheme);
  if (url == null || !const {'http', 'https'}.contains(url.scheme)) {
    return null;
  }
  // A host needs a dot ("example.com"), which rules out stray words.
  if (!url.host.contains('.') || url.host.endsWith('.')) return null;
  return url;
}
