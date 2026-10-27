import 'package:flutter/material.dart';

import 'data/api_service.dart';
import 'ui/pages.dart';
import 'ui/shared.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _api = ApiService();
  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Caja de herramientas',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F6F0),
      colorScheme: ColorScheme.fromSeed(
        seedColor: ink,
        primary: ink,
        secondary: orange,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F6F0),
        foregroundColor: ink,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: ink,
          letterSpacing: -1,
        ),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: ink),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        bodyMedium: TextStyle(color: ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: muted),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    ),
    home: HomePage(_api),
  );
}

class HomePage extends StatelessWidget {
  final ApiService api;
  const HomePage(this.api, {super.key});
  @override
  Widget build(BuildContext context) {
    final tools =
        <({String title, String description, IconData icon, Widget page})>[
          (
            title: 'Género',
            description: 'Una predicción por nombre',
            icon: Icons.auto_awesome_outlined,
            page: GenderPage(api),
          ),
          (
            title: 'Persona aleatoria',
            description: 'Conoce un perfil ficticio',
            icon: Icons.face_outlined,
            page: RandomPersonPage(api),
          ),
          (
            title: 'Universidades',
            description: 'Explora por país',
            icon: Icons.school_outlined,
            page: UniversitiesPage(api),
          ),
          (
            title: 'Clima en RD',
            description: 'Santo Domingo, hoy',
            icon: Icons.wb_sunny_outlined,
            page: WeatherPage(api),
          ),
          (
            title: 'Pokémon',
            description: 'Datos, habilidades y sonido',
            icon: Icons.catching_pokemon,
            page: PokemonPage(api),
          ),
          (
            title: 'Noticias',
            description: 'Lo último de WordPress',
            icon: Icons.newspaper_outlined,
            page: NewsPage(api),
          ),
          (
            title: 'Acerca de',
            description: 'Perfil y contacto',
            icon: Icons.person_outline,
            page: const AboutPage(),
          ),
        ];
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.work_outline),
            SizedBox(width: 10),
            Text('Mi caja', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 24),
            child: Chip(label: Text('TAREA 7')),
          ),
        ],
      ),
      body: PageBody(
        children: [
          const Intro(
            'Una app, muchas posibilidades',
            'Tu caja de\nherramientas digital.',
            'Explora, consulta y descubre. Todo lo que necesitas, en un solo lugar.',
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/toolbox.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ilustración provisional · foto de herramientas pendiente',
            style: TextStyle(color: muted, fontSize: 11),
          ),
          const SizedBox(height: 28),
          Text(
            '¿Qué quieres descubrir?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < tools.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: Text(tools[i].title)),
                        body: SafeArea(child: tools[i].page),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: i.isEven
                                ? const Color(0xFFE9F0EA)
                                : const Color(0xFFFFF1DE),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(tools[i].icon, color: ink),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tools[i].title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tools[i].description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_outward, size: 20, color: muted),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'HECHO CON CURIOSIDAD · FLUTTER',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 10, letterSpacing: 2),
          ),
        ],
      ),
    );
  }
}
