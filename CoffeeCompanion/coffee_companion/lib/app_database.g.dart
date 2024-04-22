// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  RoastDao? _roastDaoInstance;

  BrewDao? _brewDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Roast` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `roastLevel` TEXT NOT NULL, `origin` TEXT NOT NULL, `date` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Brew` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `roastId` INTEGER NOT NULL, `brewType` INTEGER NOT NULL, `time` INTEGER NOT NULL, `grindSetting` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  RoastDao get roastDao {
    return _roastDaoInstance ??= _$RoastDao(database, changeListener);
  }

  @override
  BrewDao get brewDao {
    return _brewDaoInstance ??= _$BrewDao(database, changeListener);
  }
}

class _$RoastDao extends RoastDao {
  _$RoastDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _roastInsertionAdapter = InsertionAdapter(
            database,
            'Roast',
            (Roast item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'roastLevel': item.roastLevel,
                  'origin': item.origin,
                  'date': item.date
                }),
        _roastDeletionAdapter = DeletionAdapter(
            database,
            'Roast',
            ['id'],
            (Roast item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'roastLevel': item.roastLevel,
                  'origin': item.origin,
                  'date': item.date
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Roast> _roastInsertionAdapter;

  final DeletionAdapter<Roast> _roastDeletionAdapter;

  @override
  Future<List<Roast>> findAllRoasts() async {
    return _queryAdapter.queryList('SELECT * FROM Roast',
        mapper: (Map<String, Object?> row) => Roast(
            id: row['id'] as int?,
            name: row['name'] as String,
            roastLevel: row['roastLevel'] as String,
            origin: row['origin'] as String,
            date: row['date'] as int));
  }

  @override
  Future<List<Roast>> getRoastName(int id) async {
    return _queryAdapter.queryList(
        'SELECT name FROM Roast WHERE id = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => Roast(
            id: row['id'] as int?,
            name: row['name'] as String,
            roastLevel: row['roastLevel'] as String,
            origin: row['origin'] as String,
            date: row['date'] as int),
        arguments: [id]);
  }

  @override
  Future<List<Roast>> findAllRoastsDesc() async {
    return _queryAdapter.queryList('SELECT * FROM Roast ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => Roast(
            id: row['id'] as int?,
            name: row['name'] as String,
            roastLevel: row['roastLevel'] as String,
            origin: row['origin'] as String,
            date: row['date'] as int));
  }

  @override
  Future<List<Roast>> findAllRoastsDate() async {
    return _queryAdapter.queryList('SELECT * FROM Roast ORDER BY date',
        mapper: (Map<String, Object?> row) => Roast(
            id: row['id'] as int?,
            name: row['name'] as String,
            roastLevel: row['roastLevel'] as String,
            origin: row['origin'] as String,
            date: row['date'] as int));
  }

  @override
  Future<List<Roast>> findAllRoastsDateDesc() async {
    return _queryAdapter.queryList('SELECT * FROM Roast ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => Roast(
            id: row['id'] as int?,
            name: row['name'] as String,
            roastLevel: row['roastLevel'] as String,
            origin: row['origin'] as String,
            date: row['date'] as int));
  }

  @override
  Future<Roast?> findRoastById(int id) async {
    return _queryAdapter.query('SELECT * FROM Roast WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Roast(
            id: row['id'] as int?,
            name: row['name'] as String,
            roastLevel: row['roastLevel'] as String,
            origin: row['origin'] as String,
            date: row['date'] as int),
        arguments: [id]);
  }

  @override
  Future<void> updateRoast(
    int id,
    String name,
    String roastLevel,
    String origin,
    int date,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Roast SET name = ?2, roastLevel = ?3, origin = ?4, date = ?5 WHERE id = ?1',
        arguments: [id, name, roastLevel, origin, date]);
  }

  @override
  Future<List<int>> insertRoast(List<Roast> roast) {
    return _roastInsertionAdapter.insertListAndReturnIds(
        roast, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRoast(Roast roast) async {
    await _roastDeletionAdapter.delete(roast);
  }
}

class _$BrewDao extends BrewDao {
  _$BrewDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _brewInsertionAdapter = InsertionAdapter(
            database,
            'Brew',
            (Brew item) => <String, Object?>{
                  'id': item.id,
                  'roastId': item.roastId,
                  'brewType': item.brewType,
                  'time': item.time,
                  'grindSetting': item.grindSetting
                }),
        _brewDeletionAdapter = DeletionAdapter(
            database,
            'Brew',
            ['id'],
            (Brew item) => <String, Object?>{
                  'id': item.id,
                  'roastId': item.roastId,
                  'brewType': item.brewType,
                  'time': item.time,
                  'grindSetting': item.grindSetting
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Brew> _brewInsertionAdapter;

  final DeletionAdapter<Brew> _brewDeletionAdapter;

  @override
  Future<List<Brew>> findAllBrew() async {
    return _queryAdapter.queryList('SELECT * FROM Brew',
        mapper: (Map<String, Object?> row) => Brew(
            id: row['id'] as int?,
            roastId: row['roastId'] as int,
            brewType: row['brewType'] as int,
            time: row['time'] as int,
            grindSetting: row['grindSetting'] as int));
  }

  @override
  Future<List<Brew>> findBrewByType(int brewType) async {
    return _queryAdapter.queryList('SELECT * FROM Brew WHERE brewType = ?1',
        mapper: (Map<String, Object?> row) => Brew(
            id: row['id'] as int?,
            roastId: row['roastId'] as int,
            brewType: row['brewType'] as int,
            time: row['time'] as int,
            grindSetting: row['grindSetting'] as int),
        arguments: [brewType]);
  }

  @override
  Future<List<Brew>> findBrewByRoast(int id) async {
    return _queryAdapter.queryList('SELECT * FROM Brew WHERE roastId = ?1',
        mapper: (Map<String, Object?> row) => Brew(
            id: row['id'] as int?,
            roastId: row['roastId'] as int,
            brewType: row['brewType'] as int,
            time: row['time'] as int,
            grindSetting: row['grindSetting'] as int),
        arguments: [id]);
  }

  @override
  Future<List<Brew>> findBrewByTypeIdOrderDesc(int brewType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Brew WHERE brewType = ?1 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => Brew(
            id: row['id'] as int?,
            roastId: row['roastId'] as int,
            brewType: row['brewType'] as int,
            time: row['time'] as int,
            grindSetting: row['grindSetting'] as int),
        arguments: [brewType]);
  }

  @override
  Future<List<Brew>> findBrewByTypeRoastOrderDesc(int brewType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Brew WHERE brewType = ?1 ORDER BY roastId DESC',
        mapper: (Map<String, Object?> row) => Brew(
            id: row['id'] as int?,
            roastId: row['roastId'] as int,
            brewType: row['brewType'] as int,
            time: row['time'] as int,
            grindSetting: row['grindSetting'] as int),
        arguments: [brewType]);
  }

  @override
  Future<List<Brew>> findBrewByTypeIdOrder(int brewType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Brew WHERE brewType = ?1 ORDER BY id',
        mapper: (Map<String, Object?> row) => Brew(
            id: row['id'] as int?,
            roastId: row['roastId'] as int,
            brewType: row['brewType'] as int,
            time: row['time'] as int,
            grindSetting: row['grindSetting'] as int),
        arguments: [brewType]);
  }

  @override
  Future<List<Brew>> findBrewByTypeRoastOrder(int brewType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Brew WHERE brewType = ?1 ORDER BY roastId',
        mapper: (Map<String, Object?> row) => Brew(
            id: row['id'] as int?,
            roastId: row['roastId'] as int,
            brewType: row['brewType'] as int,
            time: row['time'] as int,
            grindSetting: row['grindSetting'] as int),
        arguments: [brewType]);
  }

  @override
  Future<List<Brew>> findBrewByGrind(int grind) async {
    return _queryAdapter.queryList('SELECT * FROM Brew WHERE grindSetting = ?1',
        mapper: (Map<String, Object?> row) => Brew(
            id: row['id'] as int?,
            roastId: row['roastId'] as int,
            brewType: row['brewType'] as int,
            time: row['time'] as int,
            grindSetting: row['grindSetting'] as int),
        arguments: [grind]);
  }

  @override
  Future<Brew?> findExactMatch(
    int brewType,
    int roastId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM Brew WHERE brewType = ?1 AND roastId = ?2',
        mapper: (Map<String, Object?> row) => Brew(
            id: row['id'] as int?,
            roastId: row['roastId'] as int,
            brewType: row['brewType'] as int,
            time: row['time'] as int,
            grindSetting: row['grindSetting'] as int),
        arguments: [brewType, roastId]);
  }

  @override
  Future<Brew?> findById(int id) async {
    return _queryAdapter.query('SELECT * FROM Brew WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Brew(
            id: row['id'] as int?,
            roastId: row['roastId'] as int,
            brewType: row['brewType'] as int,
            time: row['time'] as int,
            grindSetting: row['grindSetting'] as int),
        arguments: [id]);
  }

  @override
  Future<void> updateBrew(
    int id,
    int roastId,
    int brewType,
    int time,
    int grindSetting,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Brew SET roastId = ?2, brewType = ?3, time = ?4, grindSetting = ?5 WHERE id = ?1',
        arguments: [id, roastId, brewType, time, grindSetting]);
  }

  @override
  Future<List<int>> insertBrew(List<Brew> brew) {
    return _brewInsertionAdapter.insertListAndReturnIds(
        brew, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteBrew(Brew brew) async {
    await _brewDeletionAdapter.delete(brew);
  }
}
