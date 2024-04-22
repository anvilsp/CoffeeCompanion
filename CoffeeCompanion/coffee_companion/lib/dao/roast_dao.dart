import 'package:floor/floor.dart';
import '../entity/roast.dart';

@dao
abstract class RoastDao {
  @Query('SELECT * FROM Roast')
  Future<List<Roast>> findAllRoasts();

  @Query('SELECT name FROM Roast WHERE id = :id LIMIT 1')
  Future<List<Roast>> getRoastName(int id);

  @Query('SELECT * FROM Roast ORDER BY id DESC')
  Future<List<Roast>> findAllRoastsDesc();

  @Query('SELECT * FROM Roast ORDER BY date')
  Future<List<Roast>> findAllRoastsDate();

  @Query('SELECT * FROM Roast ORDER BY date DESC')
  Future<List<Roast>> findAllRoastsDateDesc();

  @Query('SELECT * FROM Roast WHERE id = :id')
  Future<Roast?> findRoastById(int id);

  @Query('UPDATE Roast SET name = :name, roastLevel = :roastLevel, origin = :origin, date = :date WHERE id = :id')
  Future<void> updateRoast(int id, String name, String roastLevel, String origin, int date);

  @delete
  Future<void> deleteRoast(Roast roast);

  @insert
  Future<List<int>> insertRoast(List<Roast> roast);
}