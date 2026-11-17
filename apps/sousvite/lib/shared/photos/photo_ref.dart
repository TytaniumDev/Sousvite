/// Where a recipe's photo is, read from `Recipe.photoRef`.
///
/// A photo saved on this device has a plain id. A photo that is still on
/// the web, because it couldn't be downloaded at import, has its address.
sealed class PhotoRef() {
  /// Reads a stored `photoRef`.
  factory parse(String ref) {
    final uri = Uri.tryParse(ref);
    if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
      return RemotePhoto(uri);
    }
    return StoredPhoto(ref);
  }
}

/// A photo saved in the `PhotoStore` under [id].
final class const StoredPhoto(
  /// The id it is saved under.
  final String id,
) implements PhotoRef;

/// A photo still on the web at [url].
final class const RemotePhoto(
  /// The photo's address.
  final Uri url,
) implements PhotoRef;
