/// Which cloud the library syncs through (PRD 7.8, ENGINEERING.md §10).
enum SyncSource() {
  /// Sousvite cloud: Firestore, with a realtime listener. The default for
  /// everyone during the beta.
  cloud,

  /// The user's own Google Drive app folder, polled. Needs Google sign-in.
  drive;

  /// The value stored in settings and in the user's profile
  /// (`users/{uid}.transport`, ENGINEERING.md §9.1).
  String get storedName => switch (this) {
    cloud => 'firestore',
    drive => 'drive',
  };

  /// The source stored as [name], or [cloud] for anything else.
  static SyncSource fromStoredName(String? name) =>
      name == drive.storedName ? drive : cloud;
}
