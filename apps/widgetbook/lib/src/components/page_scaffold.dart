import 'package:design_system/design_system.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';

final pageScaffoldComponent = WidgetbookComponent(
  name: 'PageScaffold',
  useCases: [
    WidgetbookUseCase(
      name: 'Scrolling page',
      // No Preview: the page fills the window. Scroll down to slide the app
      // bar away, and up a little to bring it back.
      builder: (context) => PageActions(
        actions: [
          if (context.knobs.boolean(label: 'App actions', initialValue: true))
            IconButton(
              tooltip: 'Send feedback',
              icon: const Icon(Symbols.feedback_rounded),
              onPressed: () {},
            ),
        ],
        child: PageScaffold(
          title: Text(
            context.knobs.string(label: 'Title', initialValue: 'Recipes'),
          ),
          actions: [
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Symbols.search_rounded),
              onPressed: () {},
            ),
          ],
          body: FadingEdges(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
              children: [
                for (var i = 1; i <= 40; i++)
                  ListTile(
                    title: Text('Recipe $i'),
                    subtitle: const Text('Scroll down, then up a little.'),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  ],
);
