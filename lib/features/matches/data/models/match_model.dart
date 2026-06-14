import '../../domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  const MatchModel({
    required super.id,
    required super.equipolocal,
    required super.equipovisitante,
    required super.banderalocal,
    required super.banderavisitante,
    required super.goleslocal,
    required super.golesvisitante,
    required super.estado,
    required super.estadio,
    required super.grupo,
    required super.fase,
    required super.fechaPartido,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final local = json['home_team'] as Map<String, dynamic>? ?? {};
    final visitante = json['away_team'] as Map<String, dynamic>? ?? {};
    final estadio = json['stadium'] as Map<String, dynamic>? ?? {};

    DateTime? fechaParsed;
    final rawFecha = json['date'] as String?;
    if (rawFecha != null && rawFecha.isNotEmpty) {
      try {
        fechaParsed = DateTime.parse(rawFecha).toUtc();
      } catch (_) {}
    }

    final nombreEstadio =
        estadio['name_en'] as String? ?? estadio['name'] as String? ?? '';
    final ciudadEstadio =
        estadio['city_en'] as String? ?? estadio['city'] as String? ?? '';
    final nombreCompleto = [
      nombreEstadio,
      ciudadEstadio,
    ].where((s) => s.isNotEmpty).join(' — ');

    return MatchModel(
      id: json['_id'] as String? ?? json['id']?.toString() ?? '',
      equipolocal:
          local['name_en'] as String? ?? local['name'] as String? ?? 'Local',
      equipovisitante:
          visitante['name_en'] as String? ??
          visitante['name'] as String? ??
          'Visitante',
      banderalocal: local['flag'] as String?,
      banderavisitante: visitante['flag'] as String?,
      goleslocal: json['home_score'] as int?,
      golesvisitante: json['away_score'] as int?,
      estado: json['status'] as String? ?? 'scheduled',
      estadio: nombreCompleto.isNotEmpty ? nombreCompleto : null,
      grupo: json['group'] as String?,
      fase: json['stage'] as String? ?? '',
      fechaPartido: fechaParsed,
    );
  }
}
