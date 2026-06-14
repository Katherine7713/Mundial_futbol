import 'package:flutter/material.dart';
import '../../domain/entities/match_entity.dart';
import '../../../../core/utils/mundial_utils.dart' as du;

class MatchCard extends StatelessWidget {
  final MatchEntity match;
  final VoidCallback onTap;

  const MatchCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ancho = MediaQuery.of(context).size.width;
    final esTablet = ancho >= 600;

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: EdgeInsets.symmetric(
        horizontal: esTablet ? 32 : 16,
        vertical: 6,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: esTablet ? 24 : 16,
            vertical: esTablet ? 18 : 14,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: _StageBadge(
                        stage: match.fase, group: match.grupo),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: match.estado),
                ],
              ),
              SizedBox(height: esTablet ? 16 : 12),
              Row(
                children: [
                  Expanded(
                    child: _TeamColumn(
                      name: match.equipolocal,
                      flagUrl: match.banderalocal,
                      alignment: CrossAxisAlignment.start,
                      esTablet: esTablet,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: esTablet ? 20 : 12),
                    child: Text(
                      match.marcador,
                      style: (esTablet
                              ? theme.textTheme.headlineMedium
                              : theme.textTheme.headlineSmall)
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B3A57),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _TeamColumn(
                      name: match.equipovisitante,
                      flagUrl: match.banderavisitante,
                      alignment: CrossAxisAlignment.end,
                      esTablet: esTablet,
                    ),
                  ),
                ],
              ),
              SizedBox(height: esTablet ? 14 : 10),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Icon(Icons.access_time,
                      size: esTablet ? 15 : 13,
                      color: theme.colorScheme.onSurfaceVariant),
                  Text(
                    match.fechaPartido != null
                        ? du.MundialUtils.toLocalDate(
                            match.fechaPartido!.toIso8601String())
                        : '—',
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: esTablet ? 13 : 11,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  if (match.estadio != null) ...[
                    Text('·',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant)),
                    Icon(Icons.stadium,
                        size: esTablet ? 15 : 13,
                        color: theme.colorScheme.onSurfaceVariant),
                    Text(
                      match.estadio!,
                      style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: esTablet ? 13 : 11,
                          color: theme.colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  final String name;
  final String? flagUrl;
  final CrossAxisAlignment alignment;
  final bool esTablet;

  const _TeamColumn({
    required this.name,
    this.flagUrl,
    required this.alignment,
    required this.esTablet,
  });

  @override
  Widget build(BuildContext context) {
    final flagSize = esTablet ? 52.0 : 40.0;
    final flagH = esTablet ? 36.0 : 28.0;
    final iconSize = esTablet ? 44.0 : 36.0;
    final fontSize = esTablet ? 15.0 : 13.0;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (flagUrl != null && flagUrl!.isNotEmpty)
          Image.network(
            flagUrl!,
            width: flagSize,
            height: flagH,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.flag, size: flagH),
          )
        else
          Icon(Icons.sports_soccer, size: iconSize),
        const SizedBox(height: 6),
        Text(
          name,
          textAlign: alignment == CrossAxisAlignment.start
              ? TextAlign.left
              : TextAlign.right,
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: fontSize),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _StageBadge extends StatelessWidget {
  final String stage;
  final String? group;
  const _StageBadge({required this.stage, this.group});

  String get _label {
    final base = stage.isNotEmpty ? stage : 'Fase de Grupos';
    if (group != null && group!.isNotEmpty) return '$base · Grupo $group';
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'live':
        color = Colors.green;
        label = '● EN VIVO';
        break;
      case 'finished':
        color = Colors.grey;
        label = 'Finalizado';
        break;
      default:
        color = Theme.of(context).colorScheme.primary;
        label = 'Programado';
    }
    return Text(label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color));
  }
}