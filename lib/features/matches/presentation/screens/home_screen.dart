import 'package:flutter/material.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/usecases/get_matches_by_date.dart';
import '../../domain/usecases/get_match_by_id.dart';
import '../../data/sources/matches_datasource.dart';
import '../../data/repositories/match_repository_impl.dart';
import '../widgets/match_card.dart';
import '../../../../core/utils/mundial_utils.dart' as du;
import '../../../../match_detail/presentation/screens/match_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GetMatchesByDateUseCase _getMatchesByDate;
  late final GetMatchByIdUseCase _getMatchById;
  late DateTime _selectedDate;
  late Future<List<MatchEntity>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    final datasource = MatchesDatasource();
    final repo = MatchRepositoryImpl(datasource);
    _getMatchesByDate = GetMatchesByDateUseCase(repo);
    _getMatchById = GetMatchByIdUseCase(repo);
    _selectedDate = DateTime.now();
    _matchesFuture = _getMatchesByDate(_selectedDate);
  }

  void _load(DateTime date) {
    setState(() {
      _selectedDate = date;
      _matchesFuture = _getMatchesByDate(date);
    });
  }

  Future<void> _openDatePicker() async {
    final inicio = du.MundialUtils.worldCupStart;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(inicio) ? inicio : _selectedDate,
      firstDate: inicio,
      lastDate: du.MundialUtils.worldCupEnd,
      locale: const Locale('es', 'EC'),
      helpText: 'Selecciona una fecha del Mundial',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked != null && !du.MundialUtils.sameDay(picked, _selectedDate)) {
      _load(picked);
    }
  }

  void _goToDetail(MatchEntity match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchDetailScreen(
          matchId: match.id,
          getMatchByIdUseCase: _getMatchById,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F8),
      appBar: AppBar(
        title: const Text(
          'World Cup 2026',
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 5, 139, 34),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0C2B4D),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: _openDatePicker,
          ),
        ],
      ),
      body: Column(
        children: [
          _DateBar(date: _selectedDate, onTap: _openDatePicker),
          Expanded(
            child: FutureBuilder<List<MatchEntity>>(
              future: _matchesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError)
                  return _ErrorView(error: snapshot.error.toString());
                final matches = snapshot.data ?? [];
                if (matches.isEmpty) return const _EmptyView();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: matches.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MatchCard(
                      match: matches[i],
                      onTap: () => _goToDetail(matches[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBar extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  const _DateBar({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 252, 224, 224).withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // El icono ha sido removido
            Text(
              'HOY — ${du.MundialUtils.toDisplayDate(date).toUpperCase()}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B3A57),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'No hay partidos programados',
      style: TextStyle(color: Colors.grey),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});
  @override
  Widget build(BuildContext context) => Center(
    child: Text(error, style: const TextStyle(color: Colors.red)),
  );
}
