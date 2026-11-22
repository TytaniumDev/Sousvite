import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/app.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/app/router.dart';
import 'package:sousvite/features/feedback/presentation/feedback_screen.dart';
import 'package:sousvite/features/settings/presentation/about_section.dart';
import 'package:sousvite/features/settings/presentation/measuring_tools_screen.dart';
import 'package:sousvite/features/settings/presentation/settings_screen.dart';
import 'package:sousvite/features/settings/presentation/theme_setting.dart';
import 'package:sousvite/features/settings/presentation/unit_system_setting.dart';
import 'package:sousvite/features/settings/settings.dart';

import '../../../helpers/helpers.dart';
import '../fakes.dart';

void main() {
  late FakeAppSettingsRepository settings;

  setUp(() => settings = FakeAppSettingsRepository());

  group(SettingsScreen, () {
    testWidgets('keeps settings to the reading column on a wide window', (
      tester,
    ) async {
      tester.setWindowWidth(1600);
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [appSettingsRepositoryProvider.overrideWithValue(settings)],
      );
      await tester.pump();

      tester.expectInCenteredColumn(
        find.byType(ListTile),
        ReadingColumn.readingWidth,
      );
    });

    testWidgets('changing the theme rebuilds only the theme setting', (
      tester,
    ) async {
      final builds = BuildCounter.start();
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [appSettingsRepositoryProvider.overrideWithValue(settings)],
      );
      await tester.pump();
      builds.reset();

      await tester.tap(find.text('Dark'));
      await tester.pump();

      expect(settings.current.theme, ThemePreference.dark);
      expect(builds.of<ThemeSetting>(), 1);
      expect(builds.of<UnitSystemSetting>(), 0);
      expect(builds.of<SettingsScreen>(), 0);
    });

    testWidgets('changing units rebuilds only the units setting', (
      tester,
    ) async {
      final builds = BuildCounter.start();
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [appSettingsRepositoryProvider.overrideWithValue(settings)],
      );
      await tester.pump();
      builds.reset();

      await tester.tap(find.text('Metric'));
      await tester.pump();

      expect(settings.current.unitSystem, UnitSystem.metric);
      expect(builds.of<UnitSystemSetting>(), 1);
      expect(builds.of<ThemeSetting>(), 0);
    });

    testWidgets('credits the nutrition data and opens the licenses', (
      tester,
    ) async {
      await tester.pumpApp(const Scaffold(body: AboutSection()));

      expect(find.textContaining('Open Food Facts'), findsOneWidget);

      await tester.tap(find.text('Open source licenses'));
      await tester.pumpAndSettle();

      expect(find.byType(LicensePage), findsOneWidget);
    });

    group('navigation', () {
      Future<void> openSettings(WidgetTester tester) async {
        final container = ProviderContainer.test(
          overrides: [
            appSettingsRepositoryProvider.overrideWithValue(settings),
            measuringToolRepositoryProvider.overrideWithValue(
              FakeMeasuringToolRepository(),
            ),
          ],
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const SousviteApp(),
          ),
        );
        container.read(routerProvider).go(SettingsRoutes.path);
        await tester.pumpAndSettle();
      }

      testWidgets('opens my measuring tools', (tester) async {
        await openSettings(tester);

        await tester.tap(find.text('My measuring tools'));
        await tester.pumpAndSettle();

        expect(find.byType(MeasuringToolsScreen), findsOneWidget);
      });

      testWidgets('opens the account', (tester) async {
        await openSettings(tester);

        await tester.scrollUntilVisible(
          find.text('Sign in or manage your account'),
          100,
          scrollable: pageScrollable,
        );
        await tester.tap(find.text('Sign in or manage your account'));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Account'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('opens the feedback form', (tester) async {
        await openSettings(tester);

        await tester.scrollUntilVisible(
          find.text('Send feedback'),
          100,
          scrollable: pageScrollable,
        );
        await tester.tap(find.text('Send feedback'));
        await tester.pumpAndSettle();

        expect(find.byType(FeedbackScreen), findsOneWidget);
      });
    });
  });
}
