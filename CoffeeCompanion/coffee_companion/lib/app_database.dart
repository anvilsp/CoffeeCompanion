import 'dart:async';
import 'package:floor/floor.dart';
import 'dao/roast_dao.dart';
import 'entity/roast.dart';
import 'dao/brew_dao.dart';
import 'entity/brew.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(version: 1, entities: [Roast, Brew])
abstract class AppDatabase extends FloorDatabase {
  RoastDao get roastDao;
  BrewDao get brewDao;
}