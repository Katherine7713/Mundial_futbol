import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/matches/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const Mundial2026App());
}

class Mundial2026App extends StatelessWidget {
  const Mundial2026App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundial 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B1538),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B1538),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      locale: const Locale('es', 'EC'),
      home: const HomeScreen(),
    );
  }
}
