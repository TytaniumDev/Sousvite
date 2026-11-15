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
  String get nav_library => 'Library';

  @override
  String get nav_grocery => 'Grocery list';

  @override
  String get nav_settings => 'Settings';

  @override
  String get library_title => 'Library';

  @override
  String get recipe_title => 'Recipe';

  @override
  String get editor_title => 'Edit recipe';

  @override
  String get import_title => 'Import recipe';

  @override
  String get nutrition_title => 'Nutrition';

  @override
  String get cooking_title => 'Cooking';

  @override
  String get grocery_title => 'Grocery list';

  @override
  String get experiments_title => 'History';

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
