import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final errorStateComponent = WidgetbookComponent(
  name: 'ErrorState',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        child: ErrorState(
          title: context.knobs.string(
            label: 'Title',
            initialValue: 'Couldn’t load recipes',
          ),
          message: context.knobs.string(
            label: 'Message',
            initialValue: 'Check your connection and try again.',
          ),
          retryLabel: 'Try again',
          onRetry: () {},
        ),
      ),
    ),
  ],
);
