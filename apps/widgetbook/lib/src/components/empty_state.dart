import 'package:design_system/design_system.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final emptyStateComponent = WidgetbookComponent(
  name: 'EmptyState',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        child: EmptyState(
          icon: Symbols.menu_book_rounded,
          title: context.knobs.string(
            label: 'Title',
            initialValue: 'No recipes yet',
          ),
          message: context.knobs.string(
            label: 'Message',
            initialValue: 'Add one by hand or import it from a website.',
          ),
          action: context.knobs.boolean(label: 'Action', initialValue: true)
              ? FilledButton(
                  onPressed: () {},
                  child: const Text('Add a recipe'),
                )
              : null,
        ),
      ),
    ),
  ],
);
