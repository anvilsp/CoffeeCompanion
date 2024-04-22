import 'package:floor/floor.dart';

@entity
class Brew {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final int roastId; // key for roast that is associated with this brew 
  final int brewType; // brew type, espresso/pourover/french press/moka pot/aeropress/chemex/other
  final int time;
  final int grindSetting;

  Brew({
    this.id,
    required this.roastId,
    required this.brewType,
    required this.time,
    required this.grindSetting
  });
}