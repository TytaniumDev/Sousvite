import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/database.dart';
import 'package:sousvite/app/services/firebase.dart';
import 'package:sousvite/features/account/application/auth_user.dart';
import 'package:sousvite/features/account/sync/data/local_setting.dart';

part 'sign_in_callout.g.dart';

/// When the user last hid the library's sign-in card, or null.
@Riverpod(keepAlive: true)
class SignInCalloutDismissal() extends _$SignInCalloutDismissal {
  /// How long the card stays hidden after "Not now" (ENGINEERING.md §10).
  static const hiddenFor = Duration(days: 30);

  LocalSetting get _setting => LocalSetting(
    ref.read(appDatabaseProvider).settingsDao,
    'sign_in_callout_dismissed_at',
  );

  @override
  Future<DateTime?> build() async {
    final stored = await _setting.read();
    return stored == null ? null : DateTime.tryParse(stored);
  }

  /// Hides the card for [hiddenFor].
  Future<void> dismiss() async {
    final now = clock.now();
    await _setting.write(now.toUtc().toIso8601String());
    state = AsyncData(now);
  }
}

/// Whether to invite the user to sign in for free backup and sync: only
/// while signed out, in builds that can sign in (ENGINEERING.md §10).
@riverpod
bool signInInviteAvailable(Ref ref) {
  final user = ref.watch(authUserProvider);
  return ref.watch(firebaseAppProvider) != null &&
      user.hasValue &&
      user.value == null;
}

/// Whether the library shows its sign-in card: invited, and not hidden in
/// the last 30 days.
@riverpod
bool signInCalloutVisible(Ref ref) {
  if (!ref.watch(signInInviteAvailableProvider)) return false;
  final dismissal = ref.watch(signInCalloutDismissalProvider);
  if (!dismissal.hasValue) return false;
  final at = dismissal.value;
  return at == null ||
      clock.now().difference(at) >= SignInCalloutDismissal.hiddenFor;
}
