/// [path] resolved against the working directory.
///
/// Only the web build loads files this way; elsewhere SQLite is native and
/// Drift ignores its web options, so this just keeps one call site.
Uri webFileUri(String path) => Uri.base.resolve(path);
