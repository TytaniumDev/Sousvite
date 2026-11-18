import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';

final readingColumnComponent = WidgetbookComponent(
  name: 'ReadingColumn',
  useCases: [
    WidgetbookUseCase(
      name: 'Page',
      // No Preview: the column fills the window, so pick a tablet or desktop
      // in the Viewport addon to see it center.
      builder: (context) => ReadingColumn(
        maxWidth: context.knobs.object.dropdown(
          label: 'Max width',
          options: const [
            ReadingColumn.readingWidth,
            ReadingColumn.formWidth,
            ReadingColumn.twoPaneWidth,
          ],
          labelBuilder: (width) => switch (width) {
            ReadingColumn.formWidth => 'Form (400)',
            ReadingColumn.twoPaneWidth => 'Two panes (1200)',
            _ => 'Reading (720)',
          },
        ),
        builder: (context, insets) => ListView(
          padding: insets + const EdgeInsets.all(AppSpacing.space4),
          children: [
            Text(
              'Sign in to sync your recipes across your devices and share '
              'them. Everything else works without an account.',
              style: context.textStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.space6),
            FilledButton.tonal(
              onPressed: () {},
              child: const Text('Sign in with Google'),
            ),
            const SizedBox(height: AppSpacing.space3),
            FilledButton.tonal(
              onPressed: () {},
              child: const Text('Sign in with Apple'),
            ),
          ],
        ),
      ),
    ),
  ],
);
