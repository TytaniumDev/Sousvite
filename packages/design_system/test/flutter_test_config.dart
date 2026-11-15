import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs every test in this package with one golden setup.
///
/// Two kinds of golden are made:
///
/// - CI goldens (`goldens/ci/`) render text as blocks, so they match on
///   every machine.
/// - Linux goldens (`goldens/linux/`) render our real fonts and icons, so a
///   reviewer can see the actual design. They run only on Linux, which is
///   what CI uses, because font rendering differs between platforms.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadPackageFonts();
  await AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        platforms: {HostPlatform.linux},
      ),
    ),
    run: () => Future.sync(testMain),
  );
}

/// Inside this package's own tests the fonts are registered without the
/// `packages/design_system/` prefix that our text styles ask for, so load
/// them again under the prefixed names.
Future<void> _loadPackageFonts() async {
  const fonts = {
    AppFonts.serif: 'assets/fonts/Newsreader-Variable.ttf',
    AppFonts.sans: 'assets/fonts/PlusJakartaSans-Variable.ttf',
  };
  for (final MapEntry(key: family, value: asset) in fonts.entries) {
    await (FontLoader(
      'packages/${AppFonts.package}/$family',
    )..addFont(rootBundle.load(asset))).load();
  }
}
