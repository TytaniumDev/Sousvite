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

  /// Title of the recipe page before its name loads.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get recipe_title;

  /// Title of the recipe editor.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get editor_title;

  /// Title of the recipe import screen.
  ///
  /// In en, this message translates to:
  /// **'Import recipe'**
  String get import_title;

  /// Title of the nutrition match review screen.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition_title;

  /// Title of cooking mode.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get cooking_title;

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
