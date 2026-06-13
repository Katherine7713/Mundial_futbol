import '../entities/match_entity.dart';

abstract class MatchRepository {
  Future<List<MatchEntity>> getMatchByDate(DateTime date);
  Future<MatchEntity> getMatchByID(String id);
}
