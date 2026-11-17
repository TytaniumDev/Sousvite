import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shared_spaces.g.dart';

/// The joint shares the signed-in user is a member of, by space id. Each
/// one syncs through Sousvite cloud next to the private library
/// (ENGINEERING.md §9.1). Empty until sharing fills it in.
@Riverpod(keepAlive: true)
List<String> sharedSpaceIds(Ref ref) => const [];
