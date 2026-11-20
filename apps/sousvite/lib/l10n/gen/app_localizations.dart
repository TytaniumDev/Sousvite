import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The app's name, shown in the window title and task switcher.
  ///
  /// In en, this message translates to:
  /// **'Sousvite'**
  String get app_title;

  /// Placeholder body for screens that are not built yet.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get common_comingSoon;

  /// Fallback message when a screen fails to load.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get common_errorGeneric;

  /// Button that retries a failed load.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get common_retry;

  /// A duration under an hour, such as a recipe's total time.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String common_minutes(int minutes);

  /// A duration in whole hours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String common_hours(int hours);

  /// A duration in hours and minutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String common_hoursMinutes(int hours, int minutes);

  /// A unit word after an amount of one or less ("½ cup"). The unit is the Unit enum name. Abbreviations follow DESIGN_SYSTEM.md §11.
  ///
  /// In en, this message translates to:
  /// **'{unit, select, teaspoon{tsp} tablespoon{Tbsp} fluidOunce{fl oz} cup{cup} pint{pint} quart{quart} gallon{gallon} milliliter{ml} liter{l} gram{g} kilogram{kg} ounce{oz} pound{lb} pinch{pinch} piece{piece} other{}}'**
  String common_unitOne(String unit);

  /// A unit word after an amount over one ("2 cups"). Abbreviations never take a plural.
  ///
  /// In en, this message translates to:
  /// **'{unit, select, teaspoon{tsp} tablespoon{Tbsp} fluidOunce{fl oz} cup{cups} pint{pints} quart{quarts} gallon{gallons} milliliter{ml} liter{l} gram{g} kilogram{kg} ounce{oz} pound{lb} pinch{pinches} piece{pieces} other{}}'**
  String common_unitOther(String unit);

  /// Snackbar action that reverses what just happened.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get common_undo;

  /// Navigation destination for the recipe library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get nav_library;

  /// Navigation destination for the grocery list.
  ///
  /// In en, this message translates to:
  /// **'Grocery list'**
  String get nav_grocery;

  /// Navigation destination for settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// Title of the recipe library screen.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library_title;

  /// Hint in the library's search field.
  ///
  /// In en, this message translates to:
  /// **'Search recipes, ingredients, folders'**
  String get library_searchHint;

  /// Filter chip that shows every recipe instead of one folder.
  ///
  /// In en, this message translates to:
  /// **'All recipes'**
  String get library_allRecipes;

  /// Chip and dialog title for creating a folder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get library_newFolder;

  /// Label of the folder name field.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get library_folderName;

  /// Button that creates a folder.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get library_createFolder;

  /// Menu item and dialog title for renaming the selected folder.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get library_renameFolder;

  /// Menu item that deletes the selected folder. Its recipes stay in the library.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get library_deleteFolder;

  /// Snackbar after deleting a folder.
  ///
  /// In en, this message translates to:
  /// **'Folder deleted'**
  String get library_folderDeleted;

  /// Snackbar action that undoes the last change.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get library_undo;

  /// Tooltip of the menu button for the selected folder.
  ///
  /// In en, this message translates to:
  /// **'Folder options'**
  String get library_folderOptions;

  /// Floating button and empty-state action that adds a recipe.
  ///
  /// In en, this message translates to:
  /// **'Add recipe'**
  String get library_addRecipe;

  /// Option that adds a recipe from a web page.
  ///
  /// In en, this message translates to:
  /// **'Import from a link'**
  String get library_importRecipe;

  /// Option that opens the editor for a new recipe.
  ///
  /// In en, this message translates to:
  /// **'Write a recipe'**
  String get library_writeRecipe;

  /// Title when the library has no recipes.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get library_emptyTitle;

  /// Message when the library has no recipes.
  ///
  /// In en, this message translates to:
  /// **'Paste a link or write your own.'**
  String get library_emptyMessage;

  /// Title when the selected folder has no recipes.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this folder yet'**
  String get library_emptyFolderTitle;

  /// Message when the selected folder has no recipes.
  ///
  /// In en, this message translates to:
  /// **'Press and hold a recipe to add it to folders.'**
  String get library_emptyFolderMessage;

  /// Title when a search finds nothing.
  ///
  /// In en, this message translates to:
  /// **'No matching recipes'**
  String get library_noMatchesTitle;

  /// Message when a search finds nothing.
  ///
  /// In en, this message translates to:
  /// **'Try another word, or clear the search.'**
  String get library_noMatchesMessage;

  /// Title when the library fails to load.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your recipes'**
  String get library_loadErrorTitle;

  /// Message when the library fails to load.
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment.'**
  String get library_loadErrorMessage;

  /// Title of the sheet that puts a recipe in folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get library_foldersSheetTitle;

  /// Shown in the folders sheet when there are no folders.
  ///
  /// In en, this message translates to:
  /// **'No folders yet. Create one to sort your recipes.'**
  String get library_noFolders;

  /// Screen reader hint for pressing and holding a recipe card.
  ///
  /// In en, this message translates to:
  /// **'Edit folders'**
  String get library_editFoldersHint;

  /// How many recipes a folder holds, under its tile.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recipe} other{{count} recipes}}'**
  String library_recipeCount(int count);

  /// Tile and page title for recipes that are in no folder yet.
  ///
  /// In en, this message translates to:
  /// **'Unsorted'**
  String get library_unsorted;

  /// Title of the sheet that picks a folder for a new recipe, from the library's main page.
  ///
  /// In en, this message translates to:
  /// **'Add to which folder?'**
  String get library_pickFolderTitle;

  /// Under a recipe's only folder in the folders sheet, explaining why it can't be unticked.
  ///
  /// In en, this message translates to:
  /// **'A recipe needs at least one folder'**
  String get library_lastFolder;

  /// Title of the dialog confirming a folder delete that also deletes recipes.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String library_deleteFolderTitle(String name);

  /// Body of the dialog confirming a folder delete: how many recipes go with it.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recipe is in no other folder and will be deleted too.} other{{count} recipes are in no other folder and will be deleted too.}}'**
  String library_deleteFolderMessage(int count);

  /// Button that confirms deleting a folder and its recipes.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get library_deleteConfirm;

  /// Snackbar after deleting a folder along with recipes in no other folder.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Folder and 1 recipe deleted} other{Folder and {count} recipes deleted}}'**
  String library_folderAndRecipesDeleted(int count);

  /// Title of the recipe page before its name loads.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get recipe_title;

  /// Title when the recipe page opens a recipe that no longer exists.
  ///
  /// In en, this message translates to:
  /// **'Recipe not found'**
  String get recipe_notFoundTitle;

  /// Message when the recipe page opens a recipe that no longer exists.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted on another device.'**
  String get recipe_notFoundMessage;

  /// Where a recipe came from, under its name.
  ///
  /// In en, this message translates to:
  /// **'From {source}'**
  String recipe_source(String source);

  /// A recipe's prep time, under its name.
  ///
  /// In en, this message translates to:
  /// **'Prep {time}'**
  String recipe_prepTime(String time);

  /// A recipe's cook time, under its name.
  ///
  /// In en, this message translates to:
  /// **'Cook {time}'**
  String recipe_cookTime(String time);

  /// A recipe's total time, under its name.
  ///
  /// In en, this message translates to:
  /// **'Total {time}'**
  String recipe_totalTime(String time);

  /// The recipe page's main button, which opens cooking mode.
  ///
  /// In en, this message translates to:
  /// **'Start cooking'**
  String get recipe_startCooking;

  /// Button that adds the recipe's ingredients to the grocery list.
  ///
  /// In en, this message translates to:
  /// **'Add to grocery list'**
  String get recipe_addToGrocery;

  /// Tooltip of the recipe page's overflow menu.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get recipe_moreOptions;

  /// Menu item that opens the recipe editor.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get recipe_edit;

  /// Menu item that puts the recipe into folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get recipe_folders;

  /// Menu item that opens the recipe's experiments and history.
  ///
  /// In en, this message translates to:
  /// **'Experiments and history'**
  String get recipe_experiment;

  /// Menu item that shares the recipe.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get recipe_share;

  /// Heading of the ingredients section.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipe_ingredients;

  /// Word after the number in the servings stepper: 4 servings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{serving} other{servings}}'**
  String recipe_servings(int count);

  /// Tooltip of the servings stepper's minus button.
  ///
  /// In en, this message translates to:
  /// **'Fewer servings'**
  String get recipe_fewerServings;

  /// Tooltip of the servings stepper's plus button.
  ///
  /// In en, this message translates to:
  /// **'More servings'**
  String get recipe_moreServings;

  /// Button that undoes scaling the recipe.
  ///
  /// In en, this message translates to:
  /// **'Back to the original amounts'**
  String get recipe_resetScale;

  /// Unit choice that shows amounts the way the recipe wrote them.
  ///
  /// In en, this message translates to:
  /// **'As written'**
  String get recipe_unitsOriginal;

  /// Unit choice for US customary units (cups, ounces).
  ///
  /// In en, this message translates to:
  /// **'US'**
  String get recipe_unitsUs;

  /// Unit choice for metric units (grams, milliliters).
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get recipe_unitsMetric;

  /// Screen reader action on a garlic clove amount. Shows it as teaspoons of jarred minced garlic instead, in every recipe.
  ///
  /// In en, this message translates to:
  /// **'Show as jarred garlic'**
  String get recipe_showJarredGarlic;

  /// Screen reader action on a garlic amount shown as jarred garlic. Shows it as cloves again, in every recipe.
  ///
  /// In en, this message translates to:
  /// **'Show as garlic cloves'**
  String get recipe_showGarlicCloves;

  /// Heading of the steps section.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get recipe_steps;

  /// How many steps a step section has.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String recipe_stepCount(int count);

  /// What a screen reader says before a step's text.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String recipe_stepLabel(int number);

  /// Heading of the recipe's notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get recipe_notes;

  /// Heading of the recipe's nutrition section.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get recipe_nutrition;

  /// Button that opens the full nutrition screen.
  ///
  /// In en, this message translates to:
  /// **'All nutrients'**
  String get recipe_allNutrients;

  /// Title of the recipe editor.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get editor_title;

  /// Title of the editor for a recipe that has not been saved yet.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get editor_newTitle;

  /// Button that saves the recipe.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editor_save;

  /// Shown when saving a recipe with no name.
  ///
  /// In en, this message translates to:
  /// **'Give the recipe a name first'**
  String get editor_nameRequired;

  /// Label of the recipe name field.
  ///
  /// In en, this message translates to:
  /// **'Recipe name'**
  String get editor_name;

  /// Label of the field for how many servings the recipe makes.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get editor_servings;

  /// Label of the recipe total time field.
  ///
  /// In en, this message translates to:
  /// **'Total time in minutes'**
  String get editor_totalMinutes;

  /// Shown at the top of the editor after importing a recipe.
  ///
  /// In en, this message translates to:
  /// **'Imported from {source}. Check the ingredients and steps, then save.'**
  String editor_importedFrom(String source);

  /// Heading of the ingredients part of the editor.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get editor_ingredients;

  /// Example ingredient line shown in an empty ingredient field.
  ///
  /// In en, this message translates to:
  /// **'1 ½ cups rolled oats'**
  String get editor_ingredientHint;

  /// Button that adds an ingredient line.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get editor_addIngredient;

  /// Tooltip of the button that removes an ingredient line.
  ///
  /// In en, this message translates to:
  /// **'Remove ingredient'**
  String get editor_removeIngredient;

  /// Button that adds a named section, such as "For the sauce".
  ///
  /// In en, this message translates to:
  /// **'Add section'**
  String get editor_addSection;

  /// Label of a section name field.
  ///
  /// In en, this message translates to:
  /// **'Section name'**
  String get editor_sectionName;

  /// Tooltip of the button that removes a section and what is in it.
  ///
  /// In en, this message translates to:
  /// **'Remove section'**
  String get editor_removeSection;

  /// What a screen reader says for a section's drag handle.
  ///
  /// In en, this message translates to:
  /// **'Reorder {section}'**
  String editor_reorderSection(String section);

  /// What a screen reader says before a parsed amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get editor_amount;

  /// What a screen reader says before a parsed ingredient name.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get editor_ingredient;

  /// What a screen reader says before a parsed preparation.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get editor_preparation;

  /// Heading of the steps part of the editor.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get editor_steps;

  /// Hint in an empty step field.
  ///
  /// In en, this message translates to:
  /// **'Describe this step'**
  String get editor_stepHint;

  /// Button that adds a step.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get editor_addStep;

  /// Tooltip of the button that removes a step.
  ///
  /// In en, this message translates to:
  /// **'Remove step'**
  String get editor_removeStep;

  /// Label of the recipe notes field.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get editor_notes;

  /// Button in the editor that adds a photo to a recipe without one.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get editor_addPhoto;

  /// Button in the editor that replaces or removes the recipe's photo.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get editor_changePhoto;

  /// Option that opens the camera to take the recipe's photo.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get editor_takePhoto;

  /// Option that opens the photo library or a file picker to choose the recipe's photo.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo'**
  String get editor_choosePhoto;

  /// Option that removes the recipe's photo.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get editor_removePhoto;

  /// Shown when a picked file isn't an image the app can read.
  ///
  /// In en, this message translates to:
  /// **'That photo couldn\'t be opened. Try another one.'**
  String get editor_photoFailed;

  /// Tooltip of the editor's overflow menu.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get editor_moreOptions;

  /// Menu item that makes a copy of the recipe.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get editor_duplicate;

  /// Name of a duplicated recipe.
  ///
  /// In en, this message translates to:
  /// **'{title} (copy)'**
  String editor_copyTitle(String title);

  /// Menu item that deletes the recipe.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe'**
  String get editor_delete;

  /// Shown after deleting a recipe, with Undo.
  ///
  /// In en, this message translates to:
  /// **'Recipe deleted'**
  String get editor_deleted;

  /// Button that brings back a deleted recipe.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get editor_undo;

  /// Title of the dialog shown when leaving the editor with unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get editor_discardTitle;

  /// Message of the dialog shown when leaving the editor with unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Your changes to this recipe haven\'t been saved.'**
  String get editor_discardMessage;

  /// Button that leaves the editor without saving.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get editor_discard;

  /// Button that stays in the editor.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get editor_keepEditing;

  /// Title of the recipe import screen.
  ///
  /// In en, this message translates to:
  /// **'Import recipe'**
  String get import_title;

  /// Tooltip of the button that closes the import screen when it was opened from the share sheet.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get import_close;

  /// Import screen section heading for importing from a URL.
  ///
  /// In en, this message translates to:
  /// **'From a web page'**
  String get import_fromWeb;

  /// Label of the field for a recipe's web address.
  ///
  /// In en, this message translates to:
  /// **'Recipe link'**
  String get import_urlLabel;

  /// Hint in the empty recipe link field.
  ///
  /// In en, this message translates to:
  /// **'Paste a link to a recipe'**
  String get import_urlHint;

  /// Button that imports the recipe at the link.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import_importButton;

  /// Shown while a recipe is being imported.
  ///
  /// In en, this message translates to:
  /// **'Getting the recipe…'**
  String get import_importing;

  /// Stands in for a site's name in import messages when it is unknown.
  ///
  /// In en, this message translates to:
  /// **'this site'**
  String get import_thisSite;

  /// Shown when the recipe link isn't a web address.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a link. Check it and try again.'**
  String get import_invalidUrl;

  /// Shown when the site can't be reached.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach {site}. Check your connection and try again.'**
  String import_unreachable(String site);

  /// Shown when the page has no recipe the app can read.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find a recipe on {site}. You can add it by hand instead.'**
  String import_noRecipe(String site);

  /// Shown when the picked file can't be read as an Umami export.
  ///
  /// In en, this message translates to:
  /// **'That file isn\'t an Umami HTML export. In Umami, export your recipes as HTML, then pick the zip file.'**
  String get import_invalidFile;

  /// Shown while an importer is still being built.
  ///
  /// In en, this message translates to:
  /// **'This kind of import isn\'t ready yet.'**
  String get import_notAvailable;

  /// Shown when an import fails for an unexpected reason.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong with the import. Try again.'**
  String get import_failed;

  /// Import screen section heading for Umami import and export.
  ///
  /// In en, this message translates to:
  /// **'Umami'**
  String get import_umami;

  /// Explains the Umami section.
  ///
  /// In en, this message translates to:
  /// **'Bring your Umami library in, or export your recipes in a format Umami can read.'**
  String get import_umamiMessage;

  /// Button that imports an Umami export file.
  ///
  /// In en, this message translates to:
  /// **'Import from Umami'**
  String get import_umamiImport;

  /// Import button label while an Umami import runs.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get import_umamiImporting;

  /// Title of the dialog shown while an Umami import runs.
  ///
  /// In en, this message translates to:
  /// **'Importing from Umami'**
  String get import_umamiImportingTitle;

  /// Umami import dialog status while the export file is read.
  ///
  /// In en, this message translates to:
  /// **'Reading the export…'**
  String get import_umamiReading;

  /// Umami import dialog status while recipes are saved.
  ///
  /// In en, this message translates to:
  /// **'Saving recipes: {done} of {total}'**
  String import_umamiSavingRecipes(int done, int total);

  /// Umami import dialog status while recipe photos download. Recipes are already saved and show in the library.
  ///
  /// In en, this message translates to:
  /// **'Saving photos: {done} of {total}'**
  String import_umamiSavingPhotos(int done, int total);

  /// Umami import dialog note: leaving the app pauses the import.
  ///
  /// In en, this message translates to:
  /// **'Keep Sousvite open until this finishes.'**
  String get import_umamiKeepOpen;

  /// Button that exports recipes in Umami's format.
  ///
  /// In en, this message translates to:
  /// **'Export for Umami'**
  String get import_umamiExport;

  /// Export button label while an Umami export runs.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get import_umamiExporting;

  /// Snackbar after an Umami import.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 recipe} other{Imported {count} recipes}}'**
  String import_umamiImported(int count);

  /// Snackbar after an Umami export.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Exported 1 recipe} other{Exported {count} recipes}}'**
  String import_umamiExported(int count);

  /// Title of the nutrition match review screen.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition_title;

  /// Toggle option: show nutrition for one serving.
  ///
  /// In en, this message translates to:
  /// **'Per serving'**
  String get nutrition_perServing;

  /// Toggle option: show nutrition for the whole recipe.
  ///
  /// In en, this message translates to:
  /// **'Per batch'**
  String get nutrition_perBatch;

  /// Says what nutrition numbers cover, with the number of servings the batch divides into.
  ///
  /// In en, this message translates to:
  /// **'Per serving (1 of {servings})'**
  String nutrition_perServingOf(String servings);

  /// Says nutrition numbers cover the whole recipe.
  ///
  /// In en, this message translates to:
  /// **'Whole batch'**
  String get nutrition_wholeBatch;

  /// Nutrient name.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get nutrition_calories;

  /// Nutrient name.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get nutrition_protein;

  /// Nutrient name: carbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get nutrition_carbs;

  /// Nutrient name.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get nutrition_fat;

  /// Nutrient name, shown under fat.
  ///
  /// In en, this message translates to:
  /// **'Saturated fat'**
  String get nutrition_saturatedFat;

  /// Nutrient name, shown under fat.
  ///
  /// In en, this message translates to:
  /// **'Trans fat'**
  String get nutrition_transFat;

  /// Nutrient name.
  ///
  /// In en, this message translates to:
  /// **'Cholesterol'**
  String get nutrition_cholesterol;

  /// Nutrient name.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get nutrition_sodium;

  /// Nutrient name, shown under carbs.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get nutrition_fiber;

  /// Nutrient name, shown under carbs.
  ///
  /// In en, this message translates to:
  /// **'Sugars'**
  String get nutrition_sugars;

  /// Nutrient name.
  ///
  /// In en, this message translates to:
  /// **'Vitamin D'**
  String get nutrition_vitaminD;

  /// Nutrient name.
  ///
  /// In en, this message translates to:
  /// **'Calcium'**
  String get nutrition_calcium;

  /// Nutrient name.
  ///
  /// In en, this message translates to:
  /// **'Iron'**
  String get nutrition_iron;

  /// Nutrient name.
  ///
  /// In en, this message translates to:
  /// **'Potassium'**
  String get nutrition_potassium;

  /// Nutrient name.
  ///
  /// In en, this message translates to:
  /// **'Vitamin A'**
  String get nutrition_vitaminA;

  /// Nutrient name.
  ///
  /// In en, this message translates to:
  /// **'Vitamin C'**
  String get nutrition_vitaminC;

  /// Unit after a calorie value.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get nutrition_unitKilocalories;

  /// Unit after a value in grams.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get nutrition_unitGrams;

  /// Unit after a value in milligrams.
  ///
  /// In en, this message translates to:
  /// **'mg'**
  String get nutrition_unitMilligrams;

  /// Unit after a value in micrograms.
  ///
  /// In en, this message translates to:
  /// **'µg'**
  String get nutrition_unitMicrograms;

  /// Next to nutrition totals: how many ingredients have no nutrition data and are left out.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Excludes 1 unmatched ingredient} other{Excludes {count} unmatched ingredients}}'**
  String nutrition_excludesUnmatched(int count);

  /// Link from the unmatched count to the nutrition screen, to match those ingredients.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get nutrition_fix;

  /// Label next to the number of servings nutrition divides into.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get nutrition_servingSize;

  /// Unit word after the number of servings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{serving} other{servings}}'**
  String nutrition_servingsUnit(int count);

  /// Button that lowers the number of servings.
  ///
  /// In en, this message translates to:
  /// **'Fewer servings'**
  String get nutrition_fewerServings;

  /// Button that raises the number of servings.
  ///
  /// In en, this message translates to:
  /// **'More servings'**
  String get nutrition_moreServings;

  /// Heading of the detailed nutrient table.
  ///
  /// In en, this message translates to:
  /// **'Nutrients'**
  String get nutrition_nutrients;

  /// Heading of the list of ingredient matches.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get nutrition_ingredients;

  /// Shown when the recipe has no ingredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients yet'**
  String get nutrition_noIngredients;

  /// Explains the empty ingredient list on the nutrition screen.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients to the recipe to see its nutrition.'**
  String get nutrition_noIngredientsMessage;

  /// Match source: USDA FoodData Central.
  ///
  /// In en, this message translates to:
  /// **'USDA'**
  String get nutrition_sourceUsda;

  /// Match source: Open Food Facts.
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts'**
  String get nutrition_sourceOpenFoodFacts;

  /// Match status: the user picked or changed the match.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get nutrition_edited;

  /// Match status: no nutrition data for this ingredient.
  ///
  /// In en, this message translates to:
  /// **'Not matched'**
  String get nutrition_notMatched;

  /// Under an unmatched ingredient.
  ///
  /// In en, this message translates to:
  /// **'Not counted in the totals'**
  String get nutrition_notCounted;

  /// Under an ingredient: the food it is matched to and its weight.
  ///
  /// In en, this message translates to:
  /// **'{food} · {grams} g'**
  String nutrition_matchedFood(String food, String grams);

  /// Title of the sheet for changing an ingredient's food.
  ///
  /// In en, this message translates to:
  /// **'Change match'**
  String get nutrition_changeMatch;

  /// Label of the field for an ingredient's weight in grams.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get nutrition_weight;

  /// Error when the app can't work out an ingredient's weight.
  ///
  /// In en, this message translates to:
  /// **'Enter the weight in grams'**
  String get nutrition_weightNeeded;

  /// Button that saves a corrected weight.
  ///
  /// In en, this message translates to:
  /// **'Save weight'**
  String get nutrition_saveWeight;

  /// Button that removes an ingredient's match so it is flagged instead of guessed.
  ///
  /// In en, this message translates to:
  /// **'Leave unmatched'**
  String get nutrition_leaveUnmatched;

  /// Button next to the unmatched count that matches every ingredient that clearly fits a USDA food, leaving the rest unmatched.
  ///
  /// In en, this message translates to:
  /// **'Fix all'**
  String get nutrition_fixAll;

  /// Snack bar after matching ingredients automatically: how many were matched.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No clear matches found.} =1{Matched 1 ingredient.} other{Matched {count} ingredients.}}'**
  String nutrition_matchedCount(int count);

  /// Follows nutrition_matchedCount in the snack bar: how many ingredients were left for the user to match.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 still needs a match.} other{{count} still need a match.}}'**
  String nutrition_stillUnmatched(int count);

  /// Settings row that matches the unmatched ingredients of every recipe.
  ///
  /// In en, this message translates to:
  /// **'Match nutrition for all recipes'**
  String get nutrition_matchLibrary;

  /// Explains the row that matches every recipe's ingredients; unclear ones are left for the user.
  ///
  /// In en, this message translates to:
  /// **'Matches ingredients to USDA foods where the fit is clear'**
  String get nutrition_matchLibraryDescription;

  /// Label of the food search field.
  ///
  /// In en, this message translates to:
  /// **'Search foods'**
  String get nutrition_searchFoods;

  /// Shown when a food search finds nothing.
  ///
  /// In en, this message translates to:
  /// **'No foods found'**
  String get nutrition_noFoods;

  /// Title of cooking mode.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get cooking_title;

  /// Tooltip of the button that leaves cooking mode, keeping your place.
  ///
  /// In en, this message translates to:
  /// **'Close cooking mode'**
  String get cooking_close;

  /// Where you are in cooking mode, for a step outside any section.
  ///
  /// In en, this message translates to:
  /// **'Step {number} of {count}'**
  String cooking_progress(int number, int count);

  /// Where you are in cooking mode: the step's section, then the step number in the whole recipe.
  ///
  /// In en, this message translates to:
  /// **'{section} · Step {number} of {count}'**
  String cooking_sectionProgress(String section, int number, int count);

  /// Button that goes to the previous step.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cooking_back;

  /// Button that goes to the next step.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get cooking_next;

  /// Button on the last step that finishes cooking.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get cooking_done;

  /// Heading of the checklist of the ingredients a step uses.
  ///
  /// In en, this message translates to:
  /// **'Ingredients for this step'**
  String get cooking_stepIngredients;

  /// Shown before the measuring cups and spoons to fill for an ingredient's amount in cooking mode, as in 'Use ½ Tbsp' for 1 ½ tsp of salt.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get cooking_measureWith;

  /// Shown on a timer chip when its time has run out.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up'**
  String get cooking_timerDone;

  /// Title in cooking mode when the recipe has no steps.
  ///
  /// In en, this message translates to:
  /// **'No steps yet'**
  String get cooking_noStepsTitle;

  /// Message in cooking mode when the recipe has no steps.
  ///
  /// In en, this message translates to:
  /// **'Add steps to this recipe to cook it step by step.'**
  String get cooking_noStepsMessage;

  /// Title of the grocery list screen.
  ///
  /// In en, this message translates to:
  /// **'Grocery list'**
  String get grocery_title;

  /// Heading when the grocery list has no items.
  ///
  /// In en, this message translates to:
  /// **'Your list is empty'**
  String get grocery_emptyTitle;

  /// Explains how to fill an empty grocery list.
  ///
  /// In en, this message translates to:
  /// **'Add a recipe\'s ingredients from its page, or add an item here.'**
  String get grocery_emptyMessage;

  /// Heading when the grocery list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your grocery list'**
  String get grocery_errorTitle;

  /// What to do when the grocery list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment.'**
  String get grocery_errorMessage;

  /// Button that adds an item to the grocery list by hand.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get grocery_addItem;

  /// Label of the text field for an item typed by hand.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get grocery_itemName;

  /// Confirms adding the typed item.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get grocery_add;

  /// Store section for items that have none.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get grocery_otherSection;

  /// Store section heading on the grocery list.
  ///
  /// In en, this message translates to:
  /// **'Produce'**
  String get grocery_sectionProduce;

  /// Store section heading on the grocery list.
  ///
  /// In en, this message translates to:
  /// **'Meat and seafood'**
  String get grocery_sectionMeatAndSeafood;

  /// Store section heading on the grocery list.
  ///
  /// In en, this message translates to:
  /// **'Dairy and eggs'**
  String get grocery_sectionDairyAndEggs;

  /// Store section heading on the grocery list.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get grocery_sectionBakery;

  /// Store section heading on the grocery list.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get grocery_sectionFrozen;

  /// Store section heading on the grocery list.
  ///
  /// In en, this message translates to:
  /// **'Spices'**
  String get grocery_sectionSpices;

  /// Store section heading on the grocery list.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get grocery_sectionPantry;

  /// Store section heading on the grocery list.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get grocery_sectionBeverages;

  /// Group at the bottom of the list holding checked-off items.
  ///
  /// In en, this message translates to:
  /// **'Checked'**
  String get grocery_checkedSection;

  /// Menu item that clears every checked-off item.
  ///
  /// In en, this message translates to:
  /// **'Remove checked items'**
  String get grocery_removeChecked;

  /// Snackbar after checked items are cleared.
  ///
  /// In en, this message translates to:
  /// **'Checked items removed'**
  String get grocery_checkedRemoved;

  /// Snackbar after an item is swiped away.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String grocery_itemRemoved(String name);

  /// Screen reader label of the grocery list's overflow menu.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get grocery_moreOptions;

  /// Title of the sheet that adds a recipe's ingredients to the list.
  ///
  /// In en, this message translates to:
  /// **'Add to grocery list'**
  String get grocery_addToGroceryList;

  /// Button that adds the selected ingredients to the grocery list.
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get grocery_addToList;

  /// Snackbar after a recipe's ingredients are added.
  ///
  /// In en, this message translates to:
  /// **'Added to grocery list'**
  String get grocery_addedToList;

  /// Shown in the add-to-list sheet for a recipe with no ingredients.
  ///
  /// In en, this message translates to:
  /// **'This recipe has no ingredients yet.'**
  String get grocery_noIngredients;

  /// Title of a recipe's history of versions and experiments.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get experiments_title;

  /// Heading when a recipe has no past versions or experiments.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get experiments_emptyTitle;

  /// Explains what fills a recipe's history.
  ///
  /// In en, this message translates to:
  /// **'Start an experiment to try a change without touching the recipe.'**
  String get experiments_emptyMessage;

  /// Heading when a recipe's history fails to load.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this history'**
  String get experiments_errorTitle;

  /// What to do when history fails to load.
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment.'**
  String get experiments_errorMessage;

  /// Button that starts an experiment as a copy of the recipe.
  ///
  /// In en, this message translates to:
  /// **'Start an experiment'**
  String get experiments_start;

  /// Badge and screen title marking an experiment.
  ///
  /// In en, this message translates to:
  /// **'Experiment'**
  String get experiments_badge;

  /// An experiment still being tried.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get experiments_outcomeOpen;

  /// An experiment that became the recipe.
  ///
  /// In en, this message translates to:
  /// **'Made the recipe'**
  String get experiments_outcomeAdopted;

  /// An experiment logged without changing the recipe; also the snackbar after keeping one.
  ///
  /// In en, this message translates to:
  /// **'Kept as an experiment'**
  String get experiments_outcomeKept;

  /// Shown for an experiment with no description of what changed.
  ///
  /// In en, this message translates to:
  /// **'Untitled experiment'**
  String get experiments_untitled;

  /// Shown for a past version with no summary.
  ///
  /// In en, this message translates to:
  /// **'Saved version'**
  String get experiments_savedVersion;

  /// Label of the field describing an experiment's change.
  ///
  /// In en, this message translates to:
  /// **'What changed'**
  String get experiments_whatChanged;

  /// Example text in the what-changed field.
  ///
  /// In en, this message translates to:
  /// **'Swapped butter for olive oil'**
  String get experiments_whatChangedHint;

  /// Label of the field for notes on how an experiment turned out.
  ///
  /// In en, this message translates to:
  /// **'How it went'**
  String get experiments_howItWent;

  /// Button that opens the experiment's copy of the recipe in the editor.
  ///
  /// In en, this message translates to:
  /// **'Edit the experiment'**
  String get experiments_edit;

  /// Button that opens the experiment in cooking mode.
  ///
  /// In en, this message translates to:
  /// **'Cook it'**
  String get experiments_cook;

  /// Button that replaces the recipe with the experiment.
  ///
  /// In en, this message translates to:
  /// **'Make this the recipe'**
  String get experiments_promote;

  /// Snackbar after an experiment becomes the recipe.
  ///
  /// In en, this message translates to:
  /// **'This is now the recipe'**
  String get experiments_promoted;

  /// Button that logs the experiment without changing the recipe.
  ///
  /// In en, this message translates to:
  /// **'Keep as an experiment'**
  String get experiments_keep;

  /// Shown when an opened experiment was deleted.
  ///
  /// In en, this message translates to:
  /// **'This experiment no longer exists.'**
  String get experiments_notFound;

  /// Shown when an opened version can't be found.
  ///
  /// In en, this message translates to:
  /// **'This version no longer exists.'**
  String get experiments_versionNotFound;

  /// Button that puts the recipe back the way it was at this version.
  ///
  /// In en, this message translates to:
  /// **'Restore this version'**
  String get experiments_restore;

  /// Snackbar after a version is restored.
  ///
  /// In en, this message translates to:
  /// **'Version restored'**
  String get experiments_restored;

  /// Switch that shares an experiment with everyone in the recipe's joint share.
  ///
  /// In en, this message translates to:
  /// **'Share with others'**
  String get experiments_shareWithOthers;

  /// What sharing an experiment with others does.
  ///
  /// In en, this message translates to:
  /// **'Everyone you share this recipe with can see, edit, and cook this experiment.'**
  String get experiments_shareWithOthersBody;

  /// Heading of a past version's ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get experiments_ingredients;

  /// Heading of a past version's steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get experiments_steps;

  /// Title of the share screen.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get sharing_title;

  /// Heading on the share screen when signed out.
  ///
  /// In en, this message translates to:
  /// **'Sign in to share'**
  String get sharing_signInTitle;

  /// Why sharing needs sign-in.
  ///
  /// In en, this message translates to:
  /// **'Sharing goes through Sousvite, so it needs a Google or Apple sign-in.'**
  String get sharing_signInBody;

  /// Button that opens the account screen to sign in.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get sharing_signIn;

  /// Heading of the send-a-copy option.
  ///
  /// In en, this message translates to:
  /// **'Send a copy'**
  String get sharing_copyTitle;

  /// Explains what sending a copy does.
  ///
  /// In en, this message translates to:
  /// **'They get their own version to change as they like. Your recipe stays as it is.'**
  String get sharing_copyBody;

  /// Button that makes an invite link for a copy.
  ///
  /// In en, this message translates to:
  /// **'Create copy link'**
  String get sharing_copyCreate;

  /// Shown under a new copy link.
  ///
  /// In en, this message translates to:
  /// **'Anyone who opens this link in the next 14 days gets a copy.'**
  String get sharing_copyExpiry;

  /// Heading of the view-only link option.
  ///
  /// In en, this message translates to:
  /// **'Link for anyone'**
  String get sharing_linkTitle;

  /// Explains what a view-only link does.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the link can read this recipe, even without the app.'**
  String get sharing_linkBody;

  /// Button that publishes a view-only link.
  ///
  /// In en, this message translates to:
  /// **'Create view-only link'**
  String get sharing_linkCreate;

  /// Button that unpublishes a view-only link.
  ///
  /// In en, this message translates to:
  /// **'Turn off link'**
  String get sharing_linkTurnOff;

  /// Snackbar after a view-only link is turned off.
  ///
  /// In en, this message translates to:
  /// **'Link turned off'**
  String get sharing_linkTurnedOff;

  /// Button that copies a link to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get sharing_copyLink;

  /// Snackbar after a link is copied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get sharing_linkCopied;

  /// Snackbar when making a share link fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share. Check your connection and try again.'**
  String get sharing_failed;

  /// Heading of the option to edit a recipe jointly with others.
  ///
  /// In en, this message translates to:
  /// **'Share together'**
  String get sharing_jointTitle;

  /// What sharing together does, before the recipe is shared.
  ///
  /// In en, this message translates to:
  /// **'Everyone you invite can edit this recipe, and you all see each other\'s changes.'**
  String get sharing_jointBody;

  /// What the joint option offers once the recipe is shared.
  ///
  /// In en, this message translates to:
  /// **'You\'re editing this recipe together. Invite more people, or leave to keep your own copy.'**
  String get sharing_jointSharedBody;

  /// Button that makes an invite link to edit the recipe together.
  ///
  /// In en, this message translates to:
  /// **'Create invite link'**
  String get sharing_jointCreate;

  /// Below a joint share invite link: how long it works.
  ///
  /// In en, this message translates to:
  /// **'Anyone who opens this link in the next 14 days can join.'**
  String get sharing_jointExpiry;

  /// Button to stop editing a recipe jointly.
  ///
  /// In en, this message translates to:
  /// **'Leave share'**
  String get sharing_jointLeave;

  /// Title of the dialog that confirms leaving a joint share.
  ///
  /// In en, this message translates to:
  /// **'Leave this share?'**
  String get sharing_jointLeaveTitle;

  /// What leaving a joint share does.
  ///
  /// In en, this message translates to:
  /// **'You keep the recipe as it is now, and the others keep theirs. You won\'t see each other\'s changes anymore.'**
  String get sharing_jointLeaveBody;

  /// Confirms leaving a joint share.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get sharing_jointLeaveConfirm;

  /// Snackbar after leaving a joint share.
  ///
  /// In en, this message translates to:
  /// **'You left the share. The recipe stays in your library.'**
  String get sharing_jointLeft;

  /// Title of the screen that opens an invite link.
  ///
  /// In en, this message translates to:
  /// **'Shared recipe'**
  String get sharing_inviteTitle;

  /// Heading when someone sent a copy. name is the sender, title the recipe.
  ///
  /// In en, this message translates to:
  /// **'{name} sent you a copy of {title}'**
  String sharing_inviteCopyFrom(String name, String title);

  /// Heading when someone without a known name sent a copy.
  ///
  /// In en, this message translates to:
  /// **'You were sent a copy of {title}'**
  String sharing_inviteCopy(String title);

  /// Explains what accepting a copy does.
  ///
  /// In en, this message translates to:
  /// **'It becomes your own recipe to change as you like. Theirs won\'t change.'**
  String get sharing_inviteCopyBody;

  /// Button that saves a sent copy into the library.
  ///
  /// In en, this message translates to:
  /// **'Add to my recipes'**
  String get sharing_inviteAccept;

  /// Heading of a joint share invite. name is the sender, title the recipe.
  ///
  /// In en, this message translates to:
  /// **'{name} invited you to share {title}'**
  String sharing_inviteJointFrom(String name, String title);

  /// Heading of a joint share invite without a known sender name.
  ///
  /// In en, this message translates to:
  /// **'You were invited to share {title}'**
  String sharing_inviteJoint(String title);

  /// What joining a joint share means, on its invite.
  ///
  /// In en, this message translates to:
  /// **'You\'ll all edit the same recipe and see each other\'s changes.'**
  String get sharing_inviteJointBody;

  /// Button that joins a joint share from its invite.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get sharing_inviteJoin;

  /// Snackbar after joining a joint share.
  ///
  /// In en, this message translates to:
  /// **'Joined. The recipe shows up in your library once it syncs.'**
  String get sharing_inviteJoined;

  /// Shown on an invite when signed out.
  ///
  /// In en, this message translates to:
  /// **'Sign in to add this recipe to your library.'**
  String get sharing_inviteSignIn;

  /// Heading when an invite is expired or missing.
  ///
  /// In en, this message translates to:
  /// **'This link no longer works'**
  String get sharing_inviteGone;

  /// What to do about a link that no longer works.
  ///
  /// In en, this message translates to:
  /// **'Ask the person who shared it for a new link.'**
  String get sharing_inviteGoneBody;

  /// Snackbar after a sent copy is saved.
  ///
  /// In en, this message translates to:
  /// **'Recipe added'**
  String get sharing_inviteAdded;

  /// Title of the settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// Settings section heading for the theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearance;

  /// Theme option that follows the device's light or dark mode.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_themeSystem;

  /// Theme option that is always light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_themeLight;

  /// Theme option that is always dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_themeDark;

  /// Settings section heading for units and measuring tools.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get settings_recipes;

  /// Label of the setting that picks US or metric amounts.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settings_units;

  /// Explains that the units setting is the default; each recipe can override it.
  ///
  /// In en, this message translates to:
  /// **'For recipes where you haven\'t picked units'**
  String get settings_unitsDescription;

  /// Units option that shows amounts the way the recipe wrote them.
  ///
  /// In en, this message translates to:
  /// **'As written'**
  String get settings_unitsOriginal;

  /// Units option for US customary units (cups, ounces).
  ///
  /// In en, this message translates to:
  /// **'US'**
  String get settings_unitsUs;

  /// Units option for metric units (grams, milliliters).
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get settings_unitsMetric;

  /// Settings row and page title for the cups and spoons the user owns.
  ///
  /// In en, this message translates to:
  /// **'My measuring tools'**
  String get settings_measuringTools;

  /// Explains what the measuring tools page is for.
  ///
  /// In en, this message translates to:
  /// **'Cooking mode suggests only the cups and spoons you have.'**
  String get settings_measuringToolsDescription;

  /// Heading for the list of measuring cups.
  ///
  /// In en, this message translates to:
  /// **'Cups'**
  String get settings_measuringCups;

  /// Heading for the list of measuring spoons.
  ///
  /// In en, this message translates to:
  /// **'Spoons'**
  String get settings_measuringSpoons;

  /// Shown under the only owned measuring tool, which can't be turned off.
  ///
  /// In en, this message translates to:
  /// **'Keep at least one'**
  String get settings_measuringToolsKeepOne;

  /// A measuring cup, such as '¾ cup'.
  ///
  /// In en, this message translates to:
  /// **'{amount} cup'**
  String settings_toolCup(String amount);

  /// A tablespoon measure, such as '½ Tbsp'.
  ///
  /// In en, this message translates to:
  /// **'{amount} Tbsp'**
  String settings_toolTablespoon(String amount);

  /// A teaspoon measure, such as '¼ tsp'.
  ///
  /// In en, this message translates to:
  /// **'{amount} tsp'**
  String settings_toolTeaspoon(String amount);

  /// Settings section heading for sign-in and the account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settings_account;

  /// Settings row that opens the account screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in or manage your account'**
  String get settings_accountTile;

  /// Settings section heading for data sources and licenses.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// Credits the nutrition data sources, as the Open Database License requires.
  ///
  /// In en, this message translates to:
  /// **'Nutrition data comes from USDA FoodData Central and Open Food Facts. Open Food Facts data is available under the Open Database License.'**
  String get settings_dataAttribution;

  /// Settings row that opens the list of open source licenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get settings_licenses;

  /// Title of the account and sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account_title;

  /// Explains on the account screen why someone might sign in.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your recipes across your devices and share them. Everything else works without an account.'**
  String get account_signInBody;

  /// Button that signs in with a Google account.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get account_signInWithGoogle;

  /// Button that signs in with an Apple account.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get account_signInWithApple;

  /// Note under the sign-in buttons: Apple accounts can't use Drive sync.
  ///
  /// In en, this message translates to:
  /// **'Syncing through Google Drive needs a Google account.'**
  String get account_driveNeedsGoogle;

  /// Shown in place of a name when the account has no name or email.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get account_unnamedUser;

  /// Fallback line under the account name when the sign-in method is unknown.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get account_signedIn;

  /// Line under the account name for a Google account.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Google'**
  String get account_signedInWithGoogle;

  /// Line under the account name for an Apple account.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Apple'**
  String get account_signedInWithApple;

  /// Shown above the sign-out button.
  ///
  /// In en, this message translates to:
  /// **'Your recipes stay on this device when you sign out.'**
  String get account_signOutNote;

  /// Button that signs out.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get account_signOut;

  /// Button that starts deleting the account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get account_deleteAccount;

  /// Title of the dialog that confirms deleting the account.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get account_deleteTitle;

  /// Explains what deleting the account removes and keeps (PRD 7.9).
  ///
  /// In en, this message translates to:
  /// **'This deletes your account and everything Sousvite stores for you online. It can\'t be undone. Your recipes stay on this device, and recipes you share jointly stay with the others in the share.'**
  String get account_deleteBody;

  /// Confirms deleting the account in the dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get account_deleteConfirm;

  /// Snackbar after the account is deleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get account_deleted;

  /// Snackbar when signing in, signing out, or deleting the account fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach your account. Check your connection and try again.'**
  String get account_error;

  /// Sync status icon label when everything is saved to the cloud.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get account_syncSynced;

  /// Sync status icon label while changes are sent or received.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get account_syncSyncing;

  /// Sync status icon label with no connection; not an error.
  ///
  /// In en, this message translates to:
  /// **'Offline. Changes are saved on this device.'**
  String get account_syncOffline;

  /// Sync status icon label when the last sync failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sync. It will try again.'**
  String get account_syncError;

  /// Sync status label and button when Google needs the user to sign in again before Drive syncs.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to sync with Google Drive'**
  String get account_syncSignInAgain;

  /// Settings row title for choosing where the library syncs.
  ///
  /// In en, this message translates to:
  /// **'Sync source'**
  String get account_syncSource;

  /// Small label next to the Sync source setting, saying it is a beta feature.
  ///
  /// In en, this message translates to:
  /// **'Beta'**
  String get account_syncSourceBeta;

  /// Sync source option: Sousvite's own service.
  ///
  /// In en, this message translates to:
  /// **'Sousvite cloud'**
  String get account_syncSourceCloud;

  /// Sync source option: the user's own Google Drive.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get account_syncSourceDrive;

  /// Shown under the Sync source setting for users signed in with Apple.
  ///
  /// In en, this message translates to:
  /// **'Google Drive needs a Google account'**
  String get account_syncSourceDriveNeedsGoogle;

  /// Snack bar when switching the sync source failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t switch. Your recipes are still syncing where they were.'**
  String get account_syncSourceSwitchFailed;

  /// Under the Sync source setting: when the last sync finished.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String account_lastSynced(String time);

  /// Title of the card and settings row that invite signed-out users to sign in.
  ///
  /// In en, this message translates to:
  /// **'Back up your recipes for free'**
  String get account_signInCalloutTitle;

  /// Body of the card and settings row that invite signed-out users to sign in.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google for free backup and sync through your Google Drive.'**
  String get account_signInCalloutBody;

  /// Button on the sign-in invitation card.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get account_signInCalloutAction;

  /// Button that hides the sign-in invitation card for 30 days.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get account_signInCalloutDismiss;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
