import 'package:floor/floor.dart';

@entity
class Roast {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String name; // roast name or something
  final String roastLevel; // light, medium, dark etc
  final String origin; // country of origin, single/mixed (this will prob just be an input field
  final int date; // roast date

  Roast({ this.id,
      required this.name,
      required this.roastLevel,
      required this.origin,
      required this.date
    });
}