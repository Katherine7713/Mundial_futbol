import 'package:flutter/material.dart';
import 'package:mundial_2026/features/matches/domain/entities/match_entity.dart';
import 'package:mundial_2026/features/matches/domain/usecases/get_match_by_id.dart';
import '../../../../core/utils/mundial_utils.dart' as du;

class MatchDetailScreen extends StatefulWidget {
  final String matchId;
  final GetMatchByIdUseCase getMatchByIdUseCase;

  const MatchDetailScreen({
    super.key,
    required this.matchId,
    required this.getMatchByIdUseCase,
  });

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  late Future<MatchEntity> _matchFuture;

  @override
  void initState() {
    super.initState();
    _matchFuture = widget.getMatchByIdUseCase(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    final esTablet = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalle del Partido',
          style: TextStyle(fontSize: esTablet ? 22 : 18),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        toolbarHeight: esTablet ? 64 : 56,
      ),
      body: FutureBuilder<MatchEntity>(
        future: _matchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          }
          return _DetailBody(match: snapshot.data!);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final MatchEntity match;
  const _DetailBody({required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ancho = MediaQuery.of(context).size.width;
    final esTablet = ancho >= 600;

    // Tablet: contenido centrado con ancho máximo
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: esTablet ? 640 : double.infinity),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(esTablet ? 32 : 20),
          child: Column(
            children: [
              SizedBox(height: esTablet ? 20 : 10),
              // Cabecera equipos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _TeamBlock(
                      name: match.equipolocal,
                      flagUrl: match.banderalocal,
                      label: 'Local',
                      esTablet: esTablet,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: esTablet ? 24 : 8,
                    ),
                    child: Text(
                      match.marcador,
                      style:
                          (esTablet
                                  ? theme.textTheme.displaySmall
                                  : theme.textTheme.headlineLarge)
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                    ),
                  ),
                  Expanded(
                    child: _TeamBlock(
                      name: match.equipovisitante,
                      flagUrl: match.banderavisitante,
                      label: 'Visitante',
                      esTablet: esTablet,
                    ),
                  ),
                ],
              ),
              SizedBox(height: esTablet ? 36 : 28),
              // Info rows
              _InfoRow(
                icon: Icons.access_time,
                label: 'Fecha y hora local',
                value: match.fechaPartido != null
                    ? du.MundialUtils.toLocalDate(
                        match.fechaPartido!.toIso8601String(),
                      )
                    : '—',
                esTablet: esTablet,
              ),
              if (match.grupo != null && match.grupo!.isNotEmpty)
                _InfoRow(
                  icon: Icons.group,
                  label: 'Grupo',
                  value: 'Grupo ${match.grupo}',
                  esTablet: esTablet,
                ),
              _InfoRow(
                icon: Icons.flag,
                label: 'Fase',
                value: match.fase.isNotEmpty ? match.fase : '—',
                esTablet: esTablet,
              ),
              if (match.estadio != null && match.estadio!.isNotEmpty)
                _InfoRow(
                  icon: Icons.stadium,
                  label: 'Estadio',
                  value: match.estadio!,
                  esTablet: esTablet,
                ),
              _InfoRow(
                icon: Icons.sports_soccer,
                label: 'Estado',
                value: _statusLabel(match.estado),
                esTablet: esTablet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return 'En curso';
      case 'finished':
        return 'Finalizado';
      case 'scheduled':
        return 'Programado';
      default:
        return status;
    }
  }
}

class _TeamBlock extends StatelessWidget {
  final String name;
  final String? flagUrl;
  final String label;
  final bool esTablet;

  const _TeamBlock({
    required this.name,
    this.flagUrl,
    required this.label,
    required this.esTablet,
  });

  @override
  Widget build(BuildContext context) {
    final flagW = esTablet ? 96.0 : 72.0;
    final flagH = esTablet ? 68.0 : 50.0;
    final iconSize = esTablet ? 80.0 : 60.0;

    return Column(
      children: [
        if (flagUrl != null && flagUrl!.isNotEmpty)
          Image.network(
            flagUrl!,
            width: flagW,
            height: flagH,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.flag, size: flagH),
          )
        else
          Icon(Icons.sports_soccer, size: iconSize),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: esTablet ? 18 : 15,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: esTablet ? 14 : 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool esTablet;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.esTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(
        horizontal: esTablet ? 20 : 16,
        vertical: esTablet ? 18 : 14,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: esTablet ? 26 : 22,
          ),
          SizedBox(width: esTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: esTablet ? 13 : 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: esTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
