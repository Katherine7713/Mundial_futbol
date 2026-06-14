import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/client_api.dart';
import '../../../../core/utils/mundial_utils.dart' as du;
import '../models/match_model.dart';

class MatchesDatasource {
  final Dio _dio;
  List<MatchModel>? _partidos;
  Map<String, Map<String, dynamic>>? _teamMap;
  Map<String, Map<String, dynamic>>? _stadiumMap;

  MatchesDatasource({Dio? dio}) : _dio = dio ?? ClientApi.instance;

  String get _gamesPath => 'get/games';
  String get _teamsPath => 'get/teams';
  String get _stadiumsPath => 'get/stadiums';

  Future<Map<String, Map<String, dynamic>>> _fetchTeams() async {
    final resp = await _dio.get(_teamsPath);
    final data = resp.data;
    final lista = (data is Map && data.containsKey('teams'))
        ? data['teams'] as List<dynamic>
        : (data is List ? data : <dynamic>[]);
    final map = <String, Map<String, dynamic>>{};
    for (final t in lista) {
      final team = t as Map<String, dynamic>;
      final id = team['id']?.toString() ?? '';
      if (id.isNotEmpty) map[id] = team;
    }
    return map;
  }

  Future<Map<String, Map<String, dynamic>>> _fetchStadiums() async {
    final resp = await _dio.get(_stadiumsPath);
    final data = resp.data;
    final lista = (data is Map && data.containsKey('stadiums'))
        ? data['stadiums'] as List<dynamic>
        : (data is List ? data : <dynamic>[]);
    final map = <String, Map<String, dynamic>>{};
    for (final s in lista) {
      final stadium = s as Map<String, dynamic>;
      final id = stadium['id']?.toString() ?? '';
      if (id.isNotEmpty) map[id] = stadium;
    }
    return map;
  }

  Future<List<MatchModel>> obtenerPorFecha(DateTime fecha) async {
    final todos = await _obtenerPartidos();
    return todos.where((p) {
      if (p.fechaPartido == null) return false;
      final local = p.fechaPartido!.toLocal();
      return du.MundialUtils.sameDay(local, fecha);
    }).toList()..sort(
      (a, b) => (a.fechaPartido ?? DateTime(0)).compareTo(
        b.fechaPartido ?? DateTime(0),
      ),
    );
  }

  Future<MatchModel> obtenerPorId(String id) async {
    final todos = await _obtenerPartidos();
    final partido = todos.where((p) => p.id == id).firstOrNull;
    if (partido == null) {
      throw ServerException('Partido no encontrado (id: $id)');
    }
    return partido;
  }

  Future<List<MatchModel>> _obtenerPartidos() async {
    if (_partidos != null) return _partidos!;
    try {
      final results = await Future.wait([
        _dio.get(_gamesPath),
        _fetchTeams(),
        _fetchStadiums(),
      ]);

      _teamMap = results[1] as Map<String, Map<String, dynamic>>;
      _stadiumMap = results[2] as Map<String, Map<String, dynamic>>;

      final respuestaGames = results[0] as Response<dynamic>;
      final datos = respuestaGames.data;

      List<dynamic> lista;
      if (datos is List) {
        lista = datos;
      } else if (datos is Map && datos.containsKey('games')) {
        lista = datos['games'] as List<dynamic>;
      } else if (datos is Map && datos.containsKey('data')) {
        lista = datos['data'] as List<dynamic>;
      } else {
        lista = [];
      }

      _partidos = lista.map((p) => MatchModel.fromJson(
        p as Map<String, dynamic>,
        teamMap: _teamMap,
        stadiumMap: _stadiumMap,
      )).toList();
      return _partidos!;
    } on DioException catch (e) {
      _manejarErrorDio(e);
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  Never _manejarErrorDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        throw const TimeoutException();
      case DioExceptionType.badResponse:
        final codigo = e.response?.statusCode;
        final mensaje = e.response?.data?['message'] ?? 'Error del servidor';
        throw ServerException('Error $codigo: $mensaje', statusCode: codigo);
      case DioExceptionType.connectionError:
        throw const NetworkException('Sin conexión. Verifica tu red.');
      default:
        throw NetworkException('Error de red: ${e.message}');
    }
  }
}
