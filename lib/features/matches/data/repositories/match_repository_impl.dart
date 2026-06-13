import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/match_repository.dart';
import '../sources/matches_datasource.dart';

class MatchRepositoryImpl implements MatchRepository {
  final MatchesDatasource _datasource;
  MatchRepositoryImpl(this._datasource);

  @override
  Future<List<MatchEntity>> getMatchByDate(DateTime date) =>
      _datasource.obtenerPorFecha(date);

  @override
  Future<MatchEntity> getMatchByID(String id) => _datasource.obtenerPorId(id);
}
