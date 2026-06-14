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
    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F8),
      appBar: AppBar(
        title: const Text(
          'Detalle del Partido',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0C2B4D),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<MatchEntity>(
        future: _matchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError)
            return Center(child: Text(snapshot.error.toString()));
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TeamBlock(
                  name: match.equipolocal,
                  flagUrl: match.banderalocal,
                  label: 'Local',
                ),
                Text(
                  match.marcador,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B3A57),
                  ),
                ),
                _TeamBlock(
                  name: match.equipovisitante,
                  flagUrl: match.banderavisitante,
                  label: 'Visitante',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _DetailCard(
            children: [
              _buildInfoRow(
                Icons.access_time,
                'Fecha y hora',
                match.fechaPartido != null
                    ? du.MundialUtils.toLocalDate(
                        match.fechaPartido!.toIso8601String(),
                      )
                    : '—',
              ),
              _buildInfoRow(
                Icons.group,
                'Grupo',
                'Grupo ${match.grupo ?? "—"}',
              ),
              _buildInfoRow(
                Icons.flag,
                'Fase',
                match.fase.isNotEmpty ? match.fase : '—',
              ),
              _buildInfoRow(Icons.stadium, 'Estadio', match.estadio ?? '—'),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/mascota.png', fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1B3A57)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B3A57),
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

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _TeamBlock extends StatelessWidget {
  final String name;
  final String? flagUrl;
  final String label;

  const _TeamBlock({required this.name, this.flagUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            flagUrl ?? '',
            width: 50,
            height: 35,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
