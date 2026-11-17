import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entitlements.g.dart';

/// Whether the user has Pro (RevenueCat, ENGINEERING.md §9).
///
/// During the beta, [BetaEntitlements]: Sousvite cloud sync and sharing are
/// open to everyone (ENGINEERING.md §9.2). PRO-1 replaces it with RevenueCat
/// when the Pro gate turns on.
abstract interface class Entitlements() {
  Stream<bool> watchIsPro();
}

/// Never Pro.
class const FreeEntitlements() implements Entitlements {
  @override
  Stream<bool> watchIsPro() => Stream.value(false);
}

/// Pro for everyone, for the beta (ENGINEERING.md §9.2).
class const BetaEntitlements() implements Entitlements {
  @override
  Stream<bool> watchIsPro() => Stream.value(true);
}

@Riverpod(keepAlive: true)
Entitlements entitlements(Ref ref) => const BetaEntitlements();
