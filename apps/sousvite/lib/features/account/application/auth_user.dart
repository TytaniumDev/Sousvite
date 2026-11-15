import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/services/auth_service.dart';

part 'auth_user.g.dart';

/// The signed-in user, or null when signed out. App-wide, so kept alive.
@Riverpod(keepAlive: true)
Stream<AuthUser?> authUser(Ref ref) =>
    ref.watch(authServiceProvider).watchUser();
