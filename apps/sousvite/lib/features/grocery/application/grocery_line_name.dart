import 'package:domain/domain.dart';

/// The name [line] goes on the grocery list under: its parsed name, or
/// the whole line when it has none.
String groceryNameOf(IngredientLine line) => line.name ?? line.rawText;
