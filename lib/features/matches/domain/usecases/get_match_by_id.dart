import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class GetMatchByIdUseCase {
  final MatchRepository _repository;
  GetMatchByIdUseCase(this._repository);

  Future<MatchEntity> call(String id) => _repository.getMatchByID(id);
}
