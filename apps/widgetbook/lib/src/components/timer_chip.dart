import 'package:clock/clock.dart';
import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/interactive.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final timerChipComponent = WidgetbookComponent(
  name: 'TimerChip',
  useCases: [
    WidgetbookUseCase(
      name: 'Tap to start',
      builder: (context) => Preview(
        maxWidth: null,
        child: Interactive<DateTime?>(
          initialValue: null,
          builder: (context, startedAt, onChanged) => TimerChip(
            label: context.knobs.string(label: 'Label', initialValue: '10 s'),
            duration: context.knobs.duration(
              label: 'Duration',
              initialValue: const Duration(seconds: 10),
            ),
            doneLabel: context.knobs.string(
              label: 'Done label',
              initialValue: 'Done',
            ),
            startedAt: startedAt,
            onStart: () => onChanged(clock.now()),
            onStop: () => onChanged(null),
          ),
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Done',
      builder: (context) => Preview(
        maxWidth: null,
        child: TimerChip(
          label: '20 min',
          duration: const Duration(minutes: 20),
          doneLabel: 'Done',
          startedAt: DateTime(2000),
          onStart: () {},
          onStop: () {},
        ),
      ),
    ),
  ],
);
