import 'package:domain/domain.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Store section headings on the grocery list.
extension StoreSectionName on AppLocalizations {
  /// The heading for a section stored as [name]: a [StoreSection]'s name,
  /// a section the user typed, or null for "Other".
  String storeSectionName(String? name) => switch (StoreSection.byName(name)) {
    .produce => grocery_sectionProduce,
    .meatAndSeafood => grocery_sectionMeatAndSeafood,
    .dairyAndEggs => grocery_sectionDairyAndEggs,
    .bakery => grocery_sectionBakery,
    .frozen => grocery_sectionFrozen,
    .spices => grocery_sectionSpices,
    .pantry => grocery_sectionPantry,
    .beverages => grocery_sectionBeverages,
    .other => grocery_otherSection,
    null => name ?? grocery_otherSection,
  };
}
