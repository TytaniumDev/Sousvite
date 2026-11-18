import 'package:sousvite_widgetbook/src/components/amount_text.dart';
import 'package:sousvite_widgetbook/src/components/basis_toggle.dart';
import 'package:sousvite_widgetbook/src/components/compact_density.dart';
import 'package:sousvite_widgetbook/src/components/empty_state.dart';
import 'package:sousvite_widgetbook/src/components/error_state.dart';
import 'package:sousvite_widgetbook/src/components/experiment_badge.dart';
import 'package:sousvite_widgetbook/src/components/grocery_item_row.dart';
import 'package:sousvite_widgetbook/src/components/ingredient_row.dart';
import 'package:sousvite_widgetbook/src/components/ingredient_split_preview.dart';
import 'package:sousvite_widgetbook/src/components/macro_bar.dart';
import 'package:sousvite_widgetbook/src/components/macro_summary.dart';
import 'package:sousvite_widgetbook/src/components/match_status_chip.dart';
import 'package:sousvite_widgetbook/src/components/measuring_guide.dart';
import 'package:sousvite_widgetbook/src/components/nutrient_row.dart';
import 'package:sousvite_widgetbook/src/components/pro_badge.dart';
import 'package:sousvite_widgetbook/src/components/reading_column.dart';
import 'package:sousvite_widgetbook/src/components/recipe_card.dart';
import 'package:sousvite_widgetbook/src/components/section_header.dart';
import 'package:sousvite_widgetbook/src/components/serving_stepper.dart';
import 'package:sousvite_widgetbook/src/components/share_badge.dart';
import 'package:sousvite_widgetbook/src/components/step_text.dart';
import 'package:sousvite_widgetbook/src/components/sync_status_icon.dart';
import 'package:sousvite_widgetbook/src/components/timer_chip.dart';
import 'package:widgetbook/widgetbook.dart';

/// Every design_system component (DESIGN_SYSTEM.md §9.2), grouped the way
/// the app uses them. A new component gets a file in `components/` and an
/// entry here.
final List<WidgetbookNode> directories = [
  WidgetbookFolder(
    name: 'Amounts and cooking',
    children: [
      amountTextComponent,
      measuringGuideComponent,
      stepTextComponent,
      timerChipComponent,
    ],
  ),
  WidgetbookFolder(
    name: 'Recipes',
    children: [
      recipeCardComponent,
      ingredientRowComponent,
      ingredientSplitPreviewComponent,
      sectionHeaderComponent,
      servingStepperComponent,
    ],
  ),
  WidgetbookFolder(
    name: 'Nutrition',
    children: [
      macroSummaryComponent,
      macroBarComponent,
      nutrientRowComponent,
      basisToggleComponent,
      matchStatusChipComponent,
      compactDensityComponent,
    ],
  ),
  WidgetbookFolder(name: 'Grocery', children: [groceryItemRowComponent]),
  WidgetbookFolder(
    name: 'Badges and status',
    children: [
      shareBadgeComponent,
      experimentBadgeComponent,
      proBadgeComponent,
      syncStatusIconComponent,
    ],
  ),
  WidgetbookFolder(name: 'Layout', children: [readingColumnComponent]),
  WidgetbookFolder(
    name: 'States',
    children: [emptyStateComponent, errorStateComponent],
  ),
];
