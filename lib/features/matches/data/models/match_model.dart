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

  static const Map<String, String> _teamNamesEs = {
    'Mexico': 'México',
    'South Africa': 'Sudáfrica',
    'South Korea': 'Corea del Sur',
    'Czech Republic': 'República Checa',
    'Canada': 'Canadá',
    'Bosnia and Herzegovina': 'Bosnia y Herzegovina',
    'Qatar': 'Catar',
    'Switzerland': 'Suiza',
    'United States': 'Estados Unidos',
    'Paraguay': 'Paraguay',
    'Haiti': 'Haití',
    'Scotland': 'Escocia',
    'Brazil': 'Brasil',
    'Morocco': 'Marruecos',
    'Australia': 'Australia',
    'Turkey': 'Turquía',
    'Germany': 'Alemania',
    'Curaçao': 'Curazao',
    'Ivory Coast': 'Costa de Marfil',
    'Ecuador': 'Ecuador',
    'Netherlands': 'Países Bajos',
    'Japan': 'Japón',
    'Sweden': 'Suecia',
    'Tunisia': 'Túnez',
    'Iran': 'Irán',
    'New Zealand': 'Nueva Zelanda',
    'Spain': 'España',
    'Cape Verde': 'Cabo Verde',
    'Belgium': 'Bélgica',
    'Egypt': 'Egipto',
    'Saudi Arabia': 'Arabia Saudita',
    'Uruguay': 'Uruguay',
    'France': 'Francia',
    'Senegal': 'Senegal',
    'Iraq': 'Irak',
    'Norway': 'Noruega',
    'Argentina': 'Argentina',
    'Algeria': 'Argelia',
    'Austria': 'Austria',
    'Jordan': 'Jordania',
    'Portugal': 'Portugal',
    'Democratic Republic of the Congo': 'Rep. Dem. del Congo',
    'Uzbekistan': 'Uzbekistán',
    'Colombia': 'Colombia',
    'England': 'Inglaterra',
    'Croatia': 'Croacia',
    'Ghana': 'Ghana',
    'Panama': 'Panamá',
  };

  static const Map<String, String> _stadiumTimezoneOffsets = {
    '1': 'UTC-6',
    '2': 'UTC-6',
    '3': 'UTC-6',
    '4': 'UTC-5',
    '5': 'UTC-5',
    '6': 'UTC-5',
    '7': 'UTC-4',
    '8': 'UTC-4',
    '9': 'UTC-4',
    '10': 'UTC-4',
    '11': 'UTC-4',
    '12': 'UTC-4',
    '13': 'UTC-7',
    '14': 'UTC-7',
    '15': 'UTC-7',
    '16': 'UTC-7',
  };

  static String _nombreEs(String nombreEn) =>
      _teamNamesEs[nombreEn] ?? nombreEn;

  static int _offsetHoras(String tz) {
    switch (tz) {
      case 'UTC-7': return -7;
      case 'UTC-6': return -6;
      case 'UTC-5': return -5;
      case 'UTC-4': return -4;
      default: return -5;
    }
  }

  factory MatchModel.fromJson(
    Map<String, dynamic> json, {
    Map<String, Map<String, dynamic>>? teamMap,
    Map<String, Map<String, dynamic>>? stadiumMap,
  }) {
    DateTime? fechaParsed;
    final rawFecha = json['local_date'] as String?;
    if (rawFecha != null && rawFecha.isNotEmpty) {
      try {
        final parts = rawFecha.split(' ');
        if (parts.length == 2) {
          final dateParts = parts[0].split('/');
          if (dateParts.length == 3) {
            final mes = int.parse(dateParts[0]);
            final dia = int.parse(dateParts[1]);
            final anio = int.parse(dateParts[2]);
            final timeParts = parts[1].split(':');
            final hora = int.parse(timeParts[0]);
            final minuto = int.parse(timeParts[1]);

            final stadiumId = json['stadium_id'] as String?;
            final tz = _stadiumTimezoneOffsets[stadiumId] ?? 'UTC-5';
            final offset = _offsetHoras(tz);

            final local = DateTime(anio, mes, dia, hora, minuto);
            final ecuador = local.add(Duration(hours: -5 - offset));
            fechaParsed = ecuador.toUtc();
          }
        }
      } catch (_) {}
    }

    final homeTeamId = json['home_team_id'] as String?;
    final awayTeamId = json['away_team_id'] as String?;

    String teamLocal;
    String? flagLocal;
    if (homeTeamId != null && teamMap != null && teamMap.containsKey(homeTeamId)) {
      final t = teamMap[homeTeamId]!;
      teamLocal = _nombreEs(t['name_en'] as String? ?? 'Local');
      flagLocal = t['flag'] as String?;
    } else {
      teamLocal = _nombreEs(json['home_team_name_en'] as String? ?? json['home_team_label'] as String? ?? 'Local');
    }

    String teamVisitante;
    String? flagVisitante;
    if (awayTeamId != null && teamMap != null && teamMap.containsKey(awayTeamId)) {
      final t = teamMap[awayTeamId]!;
      teamVisitante = _nombreEs(t['name_en'] as String? ?? 'Visitante');
      flagVisitante = t['flag'] as String?;
    } else {
      teamVisitante = _nombreEs(json['away_team_name_en'] as String? ?? json['away_team_label'] as String? ?? 'Visitante');
    }

    final finishedVal = json['finished'] as String?;
    final finished = finishedVal == 'TRUE';
    final timeElapsed = json['time_elapsed'] as String?;

    String estado;
    if (finished || timeElapsed == 'finished') {
      estado = 'finished';
    } else if (timeElapsed == 'live' || timeElapsed == 'ongoing' || timeElapsed == 'started') {
      estado = 'live';
    } else {
      estado = 'scheduled';
    }

    String? nombreEstadio;
    final stadiumId = json['stadium_id'] as String?;
    if (stadiumId != null && stadiumMap != null && stadiumMap.containsKey(stadiumId)) {
      final s = stadiumMap[stadiumId]!;
      final name = s['name_en'] as String? ?? '';
      final city = s['city_en'] as String? ?? '';
      nombreEstadio = [name, city].where((x) => x.isNotEmpty).join(' — ');
    }

    return MatchModel(
      id: json['_id'] as String? ?? json['id']?.toString() ?? '',
      equipolocal: teamLocal,
      equipovisitante: teamVisitante,
      banderalocal: flagLocal,
      banderavisitante: flagVisitante,
      goleslocal: _parseScore(json['home_score']),
      golesvisitante: _parseScore(json['away_score']),
      estado: estado,
      estadio: nombreEstadio,
      grupo: json['group'] as String?,
      fase: json['type'] as String? ?? '',
      fechaPartido: fechaParsed,
    );
  }

  factory MatchModel.fromJsonEstatico(Map<String, dynamic> json) {
    final code = json['home_code'] as String? ?? '';
    final codeV = json['away_code'] as String? ?? '';

    DateTime? fechaParsed;
    final rawFecha = json['date'] as String?;
    if (rawFecha != null && rawFecha.isNotEmpty) {
      try {
        fechaParsed = DateTime.parse(rawFecha).toUtc();
      } catch (_) {}
    }

    return MatchModel(
      id: json['id'] as String? ?? '',
      equipolocal: _nombreEs(json['home'] as String? ?? 'Local'),
      equipovisitante: _nombreEs(json['away'] as String? ?? 'Visitante'),
      banderalocal: code.isNotEmpty ? 'https://flagcdn.com/w80/$code.png' : null,
      banderavisitante: codeV.isNotEmpty ? 'https://flagcdn.com/w80/$codeV.png' : null,
      goleslocal: _parseScore(json['home_score']),
      golesvisitante: _parseScore(json['away_score']),
      estado: json['status'] as String? ?? 'scheduled',
      estadio: json['stadium'] as String?,
      grupo: json['group'] as String?,
      fase: json['stage'] as String? ?? '',
      fechaPartido: fechaParsed,
    );
  }

  static int? _parseScore(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
