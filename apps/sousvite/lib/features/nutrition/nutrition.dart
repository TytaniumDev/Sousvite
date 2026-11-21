/// The nutrition feature's public surface. Other features import only this
/// file; everything else in this folder is private to the feature.
library;

export 'application/auto_match.dart' show autoMatchProvider;
export 'application/nutrition_actions.dart'
    show NutritionActions, nutritionActionsProvider;
export 'application/scanned_food.dart' show scannedLineText;
export 'nutrition_routes.dart';
export 'presentation/match_library_tile.dart' show MatchLibraryTile;
export 'presentation/nutrition_summary.dart' show NutritionSummary;
export 'presentation/scan_food_dialog.dart' show showScanFoodDialog;
export 'presentation/scanned_food_details.dart' show ScannedFoodDetails;
