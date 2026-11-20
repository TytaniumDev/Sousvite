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
  String get library_importRecipe => 'Import from a link';

  @override
  String get library_writeRecipe => 'Write a recipe';

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
  String library_recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
    );
    return '$_temp0';
  }

  @override
  String get library_unsorted => 'Unsorted';

  @override
  String get library_pickFolderTitle => 'Add to which folder?';

  @override
  String get library_lastFolder => 'A recipe needs at least one folder';

  @override
  String library_deleteFolderTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String library_deleteFolderMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes are in no other folder and will be deleted too.',
      one: '1 recipe is in no other folder and will be deleted too.',
    );
    return '$_temp0';
  }

  @override
  String get library_deleteConfirm => 'Delete';

  @override
  String library_folderAndRecipesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Folder and $count recipes deleted',
      one: 'Folder and 1 recipe deleted',
    );
    return '$_temp0';
  }

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
  String get recipe_showJarredGarlic => 'Show as jarred garlic';

  @override
  String get recipe_showGarlicCloves => 'Show as garlic cloves';

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
  String get editor_newTitle => 'New recipe';

  @override
  String get editor_save => 'Save';

  @override
  String get editor_nameRequired => 'Give the recipe a name first';

  @override
  String get editor_name => 'Recipe name';

  @override
  String get editor_servings => 'Servings';

  @override
  String get editor_totalMinutes => 'Total time in minutes';

  @override
  String editor_importedFrom(String source) {
    return 'Imported from $source. Check the ingredients and steps, then save.';
  }

  @override
  String get editor_ingredients => 'Ingredients';

  @override
  String get editor_ingredientHint => '1 ½ cups rolled oats';

  @override
  String get editor_addIngredient => 'Add ingredient';

  @override
  String get editor_removeIngredient => 'Remove ingredient';

  @override
  String get editor_addSection => 'Add section';

  @override
  String get editor_sectionName => 'Section name';

  @override
  String get editor_removeSection => 'Remove section';

  @override
  String editor_reorderSection(String section) {
    return 'Reorder $section';
  }

  @override
  String get editor_amount => 'Amount';

  @override
  String get editor_ingredient => 'Ingredient';

  @override
  String get editor_preparation => 'Preparation';

  @override
  String get editor_steps => 'Steps';

  @override
  String get editor_stepHint => 'Describe this step';

  @override
  String get editor_addStep => 'Add step';

  @override
  String get editor_removeStep => 'Remove step';

  @override
  String get editor_notes => 'Notes';

  @override
  String get editor_addPhoto => 'Add photo';

  @override
  String get editor_changePhoto => 'Change photo';

  @override
  String get editor_takePhoto => 'Take a photo';

  @override
  String get editor_choosePhoto => 'Choose a photo';

  @override
  String get editor_removePhoto => 'Remove photo';

  @override
  String get editor_photoFailed =>
      'That photo couldn\'t be opened. Try another one.';

  @override
  String get editor_moreOptions => 'More options';

  @override
  String get editor_duplicate => 'Duplicate';

  @override
  String editor_copyTitle(String title) {
    return '$title (copy)';
  }

  @override
  String get editor_delete => 'Delete recipe';

  @override
  String get editor_deleted => 'Recipe deleted';

  @override
  String get editor_undo => 'Undo';

  @override
  String get editor_discardTitle => 'Discard changes?';

  @override
  String get editor_discardMessage =>
      'Your changes to this recipe haven\'t been saved.';

  @override
  String get editor_discard => 'Discard';

  @override
  String get editor_keepEditing => 'Keep editing';

  @override
  String get import_title => 'Import recipe';

  @override
  String get import_close => 'Close';

  @override
  String get import_fromWeb => 'From a web page';

  @override
  String get import_urlLabel => 'Recipe link';

  @override
  String get import_urlHint => 'Paste a link to a recipe';

  @override
  String get import_importButton => 'Import';

  @override
  String get import_importing => 'Getting the recipe…';

  @override
  String get import_thisSite => 'this site';

  @override
  String get import_invalidUrl =>
      'That doesn\'t look like a link. Check it and try again.';

  @override
  String import_unreachable(String site) {
    return 'Couldn\'t reach $site. Check your connection and try again.';
  }

  @override
  String import_noRecipe(String site) {
    return 'Couldn\'t find a recipe on $site. You can add it by hand instead.';
  }

  @override
  String get import_invalidFile =>
      'That file isn\'t an Umami HTML export. In Umami, export your recipes as HTML, then pick the zip file.';

  @override
  String get import_notAvailable => 'This kind of import isn\'t ready yet.';

  @override
  String get import_failed =>
      'Something went wrong with the import. Try again.';

  @override
  String get import_umami => 'Umami';

  @override
  String get import_umamiMessage =>
      'Bring your Umami library in, or export your recipes in a format Umami can read.';

  @override
  String get import_umamiImport => 'Import from Umami';

  @override
  String get import_umamiImporting => 'Importing…';

  @override
  String get import_umamiImportingTitle => 'Importing from Umami';

  @override
  String get import_umamiReading => 'Reading the export…';

  @override
  String import_umamiSavingRecipes(int done, int total) {
    return 'Saving recipes: $done of $total';
  }

  @override
  String import_umamiSavingPhotos(int done, int total) {
    return 'Saving photos: $done of $total';
  }

  @override
  String get import_umamiKeepOpen => 'Keep Sousvite open until this finishes.';

  @override
  String get import_umamiExport => 'Export for Umami';

  @override
  String get import_umamiExporting => 'Exporting…';

  @override
  String import_umamiImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count recipes',
      one: 'Imported 1 recipe',
    );
    return '$_temp0';
  }

  @override
  String import_umamiExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count recipes',
      one: 'Exported 1 recipe',
    );
    return '$_temp0';
  }

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
  String get nutrition_fixAll => 'Fix all';

  @override
  String nutrition_matchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Matched $count ingredients.',
      one: 'Matched 1 ingredient.',
      zero: 'No clear matches found.',
    );
    return '$_temp0';
  }

  @override
  String nutrition_stillUnmatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count still need a match.',
      one: '1 still needs a match.',
    );
    return '$_temp0';
  }

  @override
  String get nutrition_matchLibrary => 'Match nutrition for all recipes';

  @override
  String get nutrition_matchLibraryDescription =>
      'Matches ingredients to USDA foods where the fit is clear';

  @override
  String get nutrition_searchFoods => 'Search foods';

  @override
  String get nutrition_noFoods => 'No foods found';

  @override
  String get cooking_title => 'Cooking';

  @override
  String get cooking_close => 'Close cooking mode';

  @override
  String cooking_progress(int number, int count) {
    return 'Step $number of $count';
  }

  @override
  String cooking_sectionProgress(String section, int number, int count) {
    return '$section · Step $number of $count';
  }

  @override
  String get cooking_back => 'Back';

  @override
  String get cooking_next => 'Next';

  @override
  String get cooking_done => 'Done';

  @override
  String get cooking_stepIngredients => 'Ingredients for this step';

  @override
  String get cooking_measureWith => 'Use';

  @override
  String get cooking_timerDone => 'Time\'s up';

  @override
  String get cooking_noStepsTitle => 'No steps yet';

  @override
  String get cooking_noStepsMessage =>
      'Add steps to this recipe to cook it step by step.';

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
  String get grocery_sectionProduce => 'Produce';

  @override
  String get grocery_sectionMeatAndSeafood => 'Meat and seafood';

  @override
  String get grocery_sectionDairyAndEggs => 'Dairy and eggs';

  @override
  String get grocery_sectionBakery => 'Bakery';

  @override
  String get grocery_sectionFrozen => 'Frozen';

  @override
  String get grocery_sectionSpices => 'Spices';

  @override
  String get grocery_sectionPantry => 'Pantry';

  @override
  String get grocery_sectionBeverages => 'Drinks';

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
  String get experiments_shareWithOthers => 'Share with others';

  @override
  String get experiments_shareWithOthersBody =>
      'Everyone you share this recipe with can see, edit, and cook this experiment.';

  @override
  String get experiments_ingredients => 'Ingredients';

  @override
  String get experiments_steps => 'Steps';

  @override
  String get sharing_title => 'Share';

  @override
  String get sharing_signInTitle => 'Sign in to share';

  @override
  String get sharing_signInBody =>
      'Sharing goes through Sousvite, so it needs a Google or Apple sign-in.';

  @override
  String get sharing_signIn => 'Sign in';

  @override
  String get sharing_copyTitle => 'Send a copy';

  @override
  String get sharing_copyBody =>
      'They get their own version to change as they like. Your recipe stays as it is.';

  @override
  String get sharing_copyCreate => 'Create copy link';

  @override
  String get sharing_copyExpiry =>
      'Anyone who opens this link in the next 14 days gets a copy.';

  @override
  String get sharing_linkTitle => 'Link for anyone';

  @override
  String get sharing_linkBody =>
      'Anyone with the link can read this recipe, even without the app.';

  @override
  String get sharing_linkCreate => 'Create view-only link';

  @override
  String get sharing_linkTurnOff => 'Turn off link';

  @override
  String get sharing_linkTurnedOff => 'Link turned off';

  @override
  String get sharing_copyLink => 'Copy link';

  @override
  String get sharing_linkCopied => 'Link copied';

  @override
  String get sharing_failed =>
      'Couldn\'t share. Check your connection and try again.';

  @override
  String get sharing_jointTitle => 'Share together';

  @override
  String get sharing_jointBody =>
      'Everyone you invite can edit this recipe, and you all see each other\'s changes.';

  @override
  String get sharing_jointSharedBody =>
      'You\'re editing this recipe together. Invite more people, or leave to keep your own copy.';

  @override
  String get sharing_jointCreate => 'Create invite link';

  @override
  String get sharing_jointExpiry =>
      'Anyone who opens this link in the next 14 days can join.';

  @override
  String get sharing_jointLeave => 'Leave share';

  @override
  String get sharing_jointLeaveTitle => 'Leave this share?';

  @override
  String get sharing_jointLeaveBody =>
      'You keep the recipe as it is now, and the others keep theirs. You won\'t see each other\'s changes anymore.';

  @override
  String get sharing_jointLeaveConfirm => 'Leave';

  @override
  String get sharing_jointLeft =>
      'You left the share. The recipe stays in your library.';

  @override
  String get sharing_inviteTitle => 'Shared recipe';

  @override
  String sharing_inviteCopyFrom(String name, String title) {
    return '$name sent you a copy of $title';
  }

  @override
  String sharing_inviteCopy(String title) {
    return 'You were sent a copy of $title';
  }

  @override
  String get sharing_inviteCopyBody =>
      'It becomes your own recipe to change as you like. Theirs won\'t change.';

  @override
  String get sharing_inviteAccept => 'Add to my recipes';

  @override
  String sharing_inviteJointFrom(String name, String title) {
    return '$name invited you to share $title';
  }

  @override
  String sharing_inviteJoint(String title) {
    return 'You were invited to share $title';
  }

  @override
  String get sharing_inviteJointBody =>
      'You\'ll all edit the same recipe and see each other\'s changes.';

  @override
  String get sharing_inviteJoin => 'Join';

  @override
  String get sharing_inviteJoined =>
      'Joined. The recipe shows up in your library once it syncs.';

  @override
  String get sharing_inviteSignIn =>
      'Sign in to add this recipe to your library.';

  @override
  String get sharing_inviteGone => 'This link no longer works';

  @override
  String get sharing_inviteGoneBody =>
      'Ask the person who shared it for a new link.';

  @override
  String get sharing_inviteAdded => 'Recipe added';

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

  @override
  String get account_syncSynced => 'Synced';

  @override
  String get account_syncSyncing => 'Syncing';

  @override
  String get account_syncOffline =>
      'Offline. Changes are saved on this device.';

  @override
  String get account_syncError => 'Couldn\'t sync. It will try again.';

  @override
  String get account_syncSignInAgain =>
      'Sign in again to sync with Google Drive';

  @override
  String get account_syncSource => 'Sync source';

  @override
  String get account_syncSourceBeta => 'Beta';

  @override
  String get account_syncSourceCloud => 'Sousvite cloud';

  @override
  String get account_syncSourceDrive => 'Google Drive';

  @override
  String get account_syncSourceDriveNeedsGoogle =>
      'Google Drive needs a Google account';

  @override
  String get account_syncSourceSwitchFailed =>
      'Couldn\'t switch. Your recipes are still syncing where they were.';

  @override
  String account_lastSynced(String time) {
    return 'Last synced $time';
  }

  @override
  String get account_signInCalloutTitle => 'Back up your recipes for free';

  @override
  String get account_signInCalloutBody =>
      'Sign in with Google for free backup and sync through your Google Drive.';

  @override
  String get account_signInCalloutAction => 'Sign in';

  @override
  String get account_signInCalloutDismiss => 'Not now';
}
