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
    final theme = Theme.of(context);
    final ancho = MediaQuery.of(context).size.width;
    final esTablet = ancho >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mundial 2026',
          style: TextStyle(fontSize: esTablet ? 22 : 18),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        toolbarHeight: esTablet ? 64 : 56,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Seleccionar fecha',
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
                if (snapshot.hasError) {
                  return _ErrorView(error: snapshot.error.toString());
                }
                final matches = snapshot.data ?? [];
                if (matches.isEmpty) return const _EmptyView();

                // Tablet: grilla 2 columnas / Móvil: lista
                return RefreshIndicator(
                  onRefresh: () async => _load(_selectedDate),
                  child: esTablet
                      ? GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.6,
                              ),
                          itemCount: matches.length,
                          itemBuilder: (_, i) => MatchCard(
                            match: matches[i],
                            onTap: () => _goToDetail(matches[i]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16, top: 8),
                          itemCount: matches.length,
                          itemBuilder: (_, i) => MatchCard(
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
    final isToday = du.MundialUtils.sameDay(date, DateTime.now());
    final esTablet = MediaQuery.of(context).size.width >= 600;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: esTablet ? 32 : 20,
          vertical: esTablet ? 14 : 12,
        ),
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: esTablet ? 22 : 18,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              isToday
                  ? 'Hoy — ${du.MundialUtils.toDisplayDate(date)}'
                  : du.MundialUtils.toDisplayDate(date),
              style: TextStyle(
                fontSize: esTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
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
  Widget build(BuildContext context) {
    final esTablet = MediaQuery.of(context).size.width >= 600;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sports_soccer,
            size: esTablet ? 96 : 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay partidos del Mundial\nen esta fecha',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: esTablet ? 18 : 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    final esTablet = MediaQuery.of(context).size.width >= 600;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(esTablet ? 48 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: esTablet ? 96 : 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: esTablet ? 16 : 14,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
