import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/client_api.dart';
import '../../../../core/utils/mundial_utils.dart' as du;
import '../models/match_model.dart';

class MatchesDatasource {
  final Dio _dio;
  List<MatchModel>? _partidos;

  MatchesDatasource({Dio? dio}) : _dio = dio ?? ClientApi.instance;

  Future<List<MatchModel>> obtenerPorFecha(DateTime fecha) async {
    final todos = await _obtenerPartidos();
    return todos.where((p) {
      if (p.fechaPartido == null) return false;
      final local = p.fechaPartido!.toLocal();
      return du.MundialUtils.sameDay(local, fecha);
    }).toList()..sort(
      (actual, partido) => (actual.fechaPartido ?? DateTime(0)).compareTo(
        partido.fechaPartido ?? DateTime(0),
      ),
    );
  }

  Future<MatchModel> obtenerPorId(String id) async {
    final todos = await _obtenerPartidos();
    final partido = todos.where((p) => p.id == id).firstOrNull;
    if (partido == null) throw ServerException('Partido no encontrado (id: $id)');
    return partido;
  }

  Future<List<MatchModel>> _obtenerPartidos() async {
    if (_partidos != null) return _partidos!;
    try {
      final respuesta = await _dio.get('/get/games');
      final datos = respuesta.data;

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

      _partidos = lista
          .map((p) => MatchModel.fromJson(p as Map<String, dynamic>))
          .toList();
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
