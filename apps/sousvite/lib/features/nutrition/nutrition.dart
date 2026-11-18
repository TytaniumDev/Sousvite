/// The nutrition feature's public surface. Other features import only this
/// file; everything else in this folder is private to the feature.
library;

export 'application/auto_match.dart' show autoMatchProvider;
export 'nutrition_routes.dart';
export 'presentation/match_library_tile.dart' show MatchLibraryTile;
export 'presentation/nutrition_summary.dart' show NutritionSummary;
