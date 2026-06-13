class MatchEntity {
  final String id;
  final String equipolocal;
  final String equipovisitante;
  final String? banderalocal;
  final String? banderavisitante;
  final int? goleslocal;
  final int? golesvisitante;
  final String estado;
  final String? estadio;
  final String? grupo;
  final String fase;
  final DateTime? fechaPartido;

  const MatchEntity({
    required this.id,
    required this.equipolocal,
    required this.equipovisitante,
    required this.banderalocal,
    required this.banderavisitante,
    required this.goleslocal,
    required this.golesvisitante,
    required this.estado,
    required this.estadio,
    required this.grupo,
    required this.fase,
    required this.fechaPartido,
  });

  String get marcador {
    if (estado == 'programado') return 'vs';
    if (goleslocal != null && golesvisitante != null)
      return '$goleslocal - $golesvisitante';
    return 'vs';
  }

  bool get haIniciado => estado != 'programado';
}
