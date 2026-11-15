// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Sousvite';

  @override
  String get common_comingSoon => 'Coming soon';

  @override
  String get common_errorGeneric => 'Something went wrong.';

  @override
  String get common_retry => 'Try again';

  @override
  String common_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String common_hours(int hours) {
    return '$hours h';
  }

  @override
  String common_hoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String common_unitOne(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'teaspoon': 'tsp',
      'tablespoon': 'Tbsp',
      'fluidOunce': 'fl oz',
      'cup': 'cup',
      'pint': 'pint',
      'quart': 'quart',
      'gallon': 'gallon',
      'milliliter': 'ml',
      'liter': 'l',
      'gram': 'g',
      'kilogram': 'kg',
      'ounce': 'oz',
      'pound': 'lb',
      'pinch': 'pinch',
      'piece': 'piece',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String common_unitOther(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'teaspoon': 'tsp',
      'tablespoon': 'Tbsp',
      'fluidOunce': 'fl oz',
      'cup': 'cups',
      'pint': 'pints',
      'quart': 'quarts',
      'gallon': 'gallons',
      'milliliter': 'ml',
      'liter': 'l',
      'gram': 'g',
      'kilogram': 'kg',
      'ounce': 'oz',
      'pound': 'lb',
      'pinch': 'pinches',
      'piece': 'pieces',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get common_undo => 'Undo';

  @override
  String get nav_library => 'Library';

  @override
  String get nav_grocery => 'Grocery list';

  @override
  String get nav_settings => 'Settings';

  @override
  String get library_title => 'Library';

  @override
  String get library_searchHint => 'Search recipes, ingredients, folders';

  @override
  String get library_allRecipes => 'All recipes';

  @override
  String get library_newFolder => 'New folder';

  @override
  String get library_folderName => 'Folder name';

  @override
  String get library_createFolder => 'Create';

  @override
  String get library_renameFolder => 'Rename folder';

  @override
  String get library_deleteFolder => 'Delete folder';

  @override
  String get library_folderDeleted => 'Folder deleted';

  @override
  String get library_undo => 'Undo';

  @override
  String get library_folderOptions => 'Folder options';

  @override
  String get library_addRecipe => 'Add recipe';

  @override
  String get library_emptyTitle => 'No recipes yet';

  @override
  String get library_emptyMessage => 'Paste a link or write your own.';

  @override
  String get library_emptyFolderTitle => 'Nothing in this folder yet';

  @override
  String get library_emptyFolderMessage =>
      'Press and hold a recipe to add it to folders.';

  @override
  String get library_noMatchesTitle => 'No matching recipes';

  @override
  String get library_noMatchesMessage =>
      'Try another word, or clear the search.';

  @override
  String get library_loadErrorTitle => 'Couldn\'t load your recipes';

  @override
  String get library_loadErrorMessage => 'Try again in a moment.';

  @override
  String get library_foldersSheetTitle => 'Folders';

  @override
  String get library_noFolders =>
      'No folders yet. Create one to sort your recipes.';

  @override
  String get library_editFoldersHint => 'Edit folders';

  @override
  String get recipe_title => 'Recipe';

  @override
  String get recipe_notFoundTitle => 'Recipe not found';

  @override
  String get recipe_notFoundMessage =>
      'It may have been deleted on another device.';

  @override
  String recipe_source(String source) {
    return 'From $source';
  }

  @override
  String recipe_prepTime(String time) {
    return 'Prep $time';
  }

  @override
  String recipe_cookTime(String time) {
    return 'Cook $time';
  }

  @override
  String recipe_totalTime(String time) {
    return 'Total $time';
  }

  @override
  String get recipe_startCooking => 'Start cooking';

  @override
  String get recipe_addToGrocery => 'Add to grocery list';

  @override
  String get recipe_moreOptions => 'More options';

  @override
  String get recipe_edit => 'Edit recipe';

  @override
  String get recipe_folders => 'Folders';

  @override
  String get recipe_experiment => 'Experiments and history';

  @override
  String get recipe_share => 'Share';

  @override
  String get recipe_ingredients => 'Ingredients';

  @override
  String recipe_servings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'servings',
      one: 'serving',
    );
    return '$_temp0';
  }

  @override
  String get recipe_fewerServings => 'Fewer servings';

  @override
  String get recipe_moreServings => 'More servings';

  @override
  String get recipe_resetScale => 'Back to the original amounts';

  @override
  String get recipe_unitsOriginal => 'As written';

  @override
  String get recipe_unitsUs => 'US';

  @override
  String get recipe_unitsMetric => 'Metric';

  @override
  String get recipe_steps => 'Steps';

  @override
  String recipe_stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String recipe_stepLabel(int number) {
    return 'Step $number';
  }

  @override
  String get recipe_notes => 'Notes';

  @override
  String get recipe_nutrition => 'Nutrition';

  @override
  String get recipe_allNutrients => 'All nutrients';

  @override
  String get editor_title => 'Edit recipe';

  @override
  String get import_title => 'Import recipe';

  @override
  String get nutrition_title => 'Nutrition';

  @override
  String get nutrition_perServing => 'Per serving';

  @override
  String get nutrition_perBatch => 'Per batch';

  @override
  String nutrition_perServingOf(String servings) {
    return 'Per serving (1 of $servings)';
  }

  @override
  String get nutrition_wholeBatch => 'Whole batch';

  @override
  String get nutrition_calories => 'Calories';

  @override
  String get nutrition_protein => 'Protein';

  @override
  String get nutrition_carbs => 'Carbs';

  @override
  String get nutrition_fat => 'Fat';

  @override
  String get nutrition_saturatedFat => 'Saturated fat';

  @override
  String get nutrition_transFat => 'Trans fat';

  @override
  String get nutrition_cholesterol => 'Cholesterol';

  @override
  String get nutrition_sodium => 'Sodium';

  @override
  String get nutrition_fiber => 'Fiber';

  @override
  String get nutrition_sugars => 'Sugars';

  @override
  String get nutrition_vitaminD => 'Vitamin D';

  @override
  String get nutrition_calcium => 'Calcium';

  @override
  String get nutrition_iron => 'Iron';

  @override
  String get nutrition_potassium => 'Potassium';

  @override
  String get nutrition_vitaminA => 'Vitamin A';

  @override
  String get nutrition_vitaminC => 'Vitamin C';

  @override
  String get nutrition_unitKilocalories => 'kcal';

  @override
  String get nutrition_unitGrams => 'g';

  @override
  String get nutrition_unitMilligrams => 'mg';

  @override
  String get nutrition_unitMicrograms => 'µg';

  @override
  String nutrition_excludesUnmatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excludes $count unmatched ingredients',
      one: 'Excludes 1 unmatched ingredient',
    );
    return '$_temp0';
  }

  @override
  String get nutrition_fix => 'Fix';

  @override
  String get nutrition_servingSize => 'Servings';

  @override
  String nutrition_servingsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'servings',
      one: 'serving',
    );
    return '$_temp0';
  }

  @override
  String get nutrition_fewerServings => 'Fewer servings';

  @override
  String get nutrition_moreServings => 'More servings';

  @override
  String get nutrition_nutrients => 'Nutrients';

  @override
  String get nutrition_ingredients => 'Ingredients';

  @override
  String get nutrition_noIngredients => 'No ingredients yet';

  @override
  String get nutrition_noIngredientsMessage =>
      'Add ingredients to the recipe to see its nutrition.';

  @override
  String get nutrition_sourceUsda => 'USDA';

  @override
  String get nutrition_sourceOpenFoodFacts => 'Open Food Facts';

  @override
  String get nutrition_edited => 'Edited';

  @override
  String get nutrition_notMatched => 'Not matched';

  @override
  String get nutrition_notCounted => 'Not counted in the totals';

  @override
  String nutrition_matchedFood(String food, String grams) {
    return '$food · $grams g';
  }

  @override
  String get nutrition_changeMatch => 'Change match';

  @override
  String get nutrition_weight => 'Weight';

  @override
  String get nutrition_weightNeeded => 'Enter the weight in grams';

  @override
  String get nutrition_saveWeight => 'Save weight';

  @override
  String get nutrition_leaveUnmatched => 'Leave unmatched';

  @override
  String get nutrition_searchFoods => 'Search foods';

  @override
  String get nutrition_noFoods => 'No foods found';

  @override
  String get cooking_title => 'Cooking';

  @override
  String get grocery_title => 'Grocery list';

  @override
  String get grocery_emptyTitle => 'Your list is empty';

  @override
  String get grocery_emptyMessage =>
      'Add a recipe\'s ingredients from its page, or add an item here.';

  @override
  String get grocery_errorTitle => 'Couldn\'t load your grocery list';

  @override
  String get grocery_errorMessage => 'Try again in a moment.';

  @override
  String get grocery_addItem => 'Add item';

  @override
  String get grocery_itemName => 'Item';

  @override
  String get grocery_add => 'Add';

  @override
  String get grocery_otherSection => 'Other';

  @override
  String get grocery_checkedSection => 'Checked';

  @override
  String get grocery_removeChecked => 'Remove checked items';

  @override
  String get grocery_checkedRemoved => 'Checked items removed';

  @override
  String grocery_itemRemoved(String name) {
    return '$name removed';
  }

  @override
  String get grocery_moreOptions => 'More options';

  @override
  String get grocery_addToGroceryList => 'Add to grocery list';

  @override
  String get grocery_addToList => 'Add to list';

  @override
  String get grocery_addedToList => 'Added to grocery list';

  @override
  String get grocery_noIngredients => 'This recipe has no ingredients yet.';

  @override
  String get experiments_title => 'History';

  @override
  String get experiments_emptyTitle => 'No history yet';

  @override
  String get experiments_emptyMessage =>
      'Start an experiment to try a change without touching the recipe.';

  @override
  String get experiments_errorTitle => 'Couldn\'t load this history';

  @override
  String get experiments_errorMessage => 'Try again in a moment.';

  @override
  String get experiments_start => 'Start an experiment';

  @override
  String get experiments_badge => 'Experiment';

  @override
  String get experiments_outcomeOpen => 'In progress';

  @override
  String get experiments_outcomeAdopted => 'Made the recipe';

  @override
  String get experiments_outcomeKept => 'Kept as an experiment';

  @override
  String get experiments_untitled => 'Untitled experiment';

  @override
  String get experiments_savedVersion => 'Saved version';

  @override
  String get experiments_whatChanged => 'What changed';

  @override
  String get experiments_whatChangedHint => 'Swapped butter for olive oil';

  @override
  String get experiments_howItWent => 'How it went';

  @override
  String get experiments_edit => 'Edit the experiment';

  @override
  String get experiments_cook => 'Cook it';

  @override
  String get experiments_promote => 'Make this the recipe';

  @override
  String get experiments_promoted => 'This is now the recipe';

  @override
  String get experiments_keep => 'Keep as an experiment';

  @override
  String get experiments_notFound => 'This experiment no longer exists.';

  @override
  String get experiments_versionNotFound => 'This version no longer exists.';

  @override
  String get experiments_restore => 'Restore this version';

  @override
  String get experiments_restored => 'Version restored';

  @override
  String get experiments_ingredients => 'Ingredients';

  @override
  String get experiments_steps => 'Steps';

  @override
  String get sharing_title => 'Share';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_themeSystem => 'System';

  @override
  String get settings_themeLight => 'Light';

  @override
  String get settings_themeDark => 'Dark';

  @override
  String get settings_recipes => 'Recipes';

  @override
  String get settings_units => 'Units';

  @override
  String get settings_unitsDescription =>
      'For recipes where you haven\'t picked units';

  @override
  String get settings_unitsOriginal => 'As written';

  @override
  String get settings_unitsUs => 'US';

  @override
  String get settings_unitsMetric => 'Metric';

  @override
  String get settings_measuringTools => 'My measuring tools';

  @override
  String get settings_measuringToolsDescription =>
      'Cooking mode suggests only the cups and spoons you have.';

  @override
  String get settings_measuringCups => 'Cups';

  @override
  String get settings_measuringSpoons => 'Spoons';

  @override
  String get settings_measuringToolsKeepOne => 'Keep at least one';

  @override
  String settings_toolCup(String amount) {
    return '$amount cup';
  }

  @override
  String settings_toolTablespoon(String amount) {
    return '$amount Tbsp';
  }

  @override
  String settings_toolTeaspoon(String amount) {
    return '$amount tsp';
  }

  @override
  String get settings_account => 'Account';

  @override
  String get settings_accountTile => 'Sign in or manage your account';

  @override
  String get settings_about => 'About';

  @override
  String get settings_dataAttribution =>
      'Nutrition data comes from USDA FoodData Central and Open Food Facts. Open Food Facts data is available under the Open Database License.';

  @override
  String get settings_licenses => 'Open source licenses';

  @override
  String get account_title => 'Account';

  @override
  String get account_signInBody =>
      'Sign in to sync your recipes across your devices and share them. Everything else works without an account.';

  @override
  String get account_signInWithGoogle => 'Sign in with Google';

  @override
  String get account_signInWithApple => 'Sign in with Apple';

  @override
  String get account_driveNeedsGoogle =>
      'Syncing through Google Drive needs a Google account.';

  @override
  String get account_unnamedUser => 'Your account';

  @override
  String get account_signedIn => 'Signed in';

  @override
  String get account_signedInWithGoogle => 'Signed in with Google';

  @override
  String get account_signedInWithApple => 'Signed in with Apple';

  @override
  String get account_signOutNote =>
      'Your recipes stay on this device when you sign out.';

  @override
  String get account_signOut => 'Sign out';

  @override
  String get account_deleteAccount => 'Delete account';

  @override
  String get account_deleteTitle => 'Delete your account?';

  @override
  String get account_deleteBody =>
      'This deletes your account and everything Sousvite stores for you online. It can\'t be undone. Your recipes stay on this device, and recipes you share jointly stay with the others in the share.';

  @override
  String get account_deleteConfirm => 'Delete account';

  @override
  String get account_deleted => 'Account deleted';

  @override
  String get account_error =>
      'Couldn\'t reach your account. Check your connection and try again.';
}
