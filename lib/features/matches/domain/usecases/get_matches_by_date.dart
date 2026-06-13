import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class GetMatchesByDateUseCase {
  final MatchRepository _repository;
  GetMatchesByDateUseCase(this._repository);

  Future<List<MatchEntity>> call(DateTime date) =>
      _repository.getMatchByDate(date);
}
