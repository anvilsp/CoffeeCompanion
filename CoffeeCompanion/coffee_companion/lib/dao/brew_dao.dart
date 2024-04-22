import 'package:floor/floor.dart';
import '../entity/brew.dart';

@dao
abstract class BrewDao {
  @Query('SELECT * FROM Brew')
  Future<List<Brew>> findAllBrew();

  @Query('SELECT * FROM Brew WHERE brewType = :brewType')
  Future<List<Brew>> findBrewByType(int brewType);

  @Query('SELECT * FROM Brew WHERE roastId = :id')
  Future<List<Brew>> findBrewByRoast(int id);

  @Query('SELECT * FROM Brew WHERE brewType = :brewType ORDER BY id DESC')
  Future<List<Brew>> findBrewByTypeIdOrderDesc(int brewType);

  @Query('SELECT * FROM Brew WHERE brewType = :brewType ORDER BY roastId DESC')
  Future<List<Brew>> findBrewByTypeRoastOrderDesc(int brewType);

  @Query('SELECT * FROM Brew WHERE brewType = :brewType ORDER BY id')
  Future<List<Brew>> findBrewByTypeIdOrder(int brewType);

  @Query('SELECT * FROM Brew WHERE brewType = :brewType ORDER BY roastId')
  Future<List<Brew>> findBrewByTypeRoastOrder(int brewType);

  @Query('SELECT * FROM Brew WHERE grindSetting = :grind')
  Future<List<Brew>> findBrewByGrind(int grind);

  @Query('SELECT * FROM Brew WHERE brewType = :brewType AND roastId = :roastId')
  Future<Brew?> findExactMatch(int brewType, int roastId);

  @Query('SELECT * FROM Brew WHERE id = :id')
  Future<Brew?> findById(int id);

  @Query('UPDATE Brew SET roastId = :roastId, brewType = :brewType, time = :time, grindSetting = :grindSetting WHERE id = :id')
  Future<void> updateBrew(int id, int roastId, int brewType, int time, int grindSetting);

  @delete
  Future<void> deleteBrew(Brew brew);

  @insert
  Future<List<int>> insertBrew(List<Brew> brew);
}