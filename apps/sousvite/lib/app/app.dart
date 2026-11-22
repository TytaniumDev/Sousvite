import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/router.dart';
import 'package:sousvite/features/feedback/feedback.dart';
import 'package:sousvite/features/settings/settings.dart';
import 'package:sousvite/l10n/l10n.dart';

final ThemeData _lightTheme = AppTheme.light();
final ThemeData _darkTheme = AppTheme.dark();

/// The root widget. Rebuilds only when the theme mode or router changes.
class const SousviteApp({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.app_title,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ref.watch(themeModeControllerProvider),
      routerConfig: router,
      // Over every screen, so feedback can capture any of them, and its
      // button is in every page's app bar.
      builder: (context, child) => FeedbackCaptureLayer(
        router: router,
        child: PageActions(actions: const [FeedbackButton()], child: child!),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
