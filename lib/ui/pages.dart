import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import '../data/api_service.dart';
import '../data/models.dart';
import 'shared.dart';

class GenderPage extends StatelessWidget {
  final ApiService api;
  const GenderPage(this.api, {super.key});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const Intro(
        '01 / Descubre',
        'Un nombre, una predicción',
        'Consulta la predicción estadística asociada a un nombre y su probabilidad.',
      ),
      QueryView<GenderPrediction>(
        load: api.gender,
        inputLabel: 'Nombre de la persona',
        result: (person) {
          final male = person.gender == 'male';
          final known = male || person.gender == 'female';
          return Surface(
            color: known
                ? (male ? const Color(0xFFDCEBFF) : const Color(0xFFFFE2EF))
                : null,
            child: Column(
              children: [
                Icon(
                  known
                      ? (male ? Icons.male : Icons.female)
                      : Icons.help_outline,
                  size: 80,
                  color: ink,
                ),
                const SizedBox(height: 16),
                Text(
                  person.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Detail(
                  'Predicción',
                  known ? (male ? 'Masculino' : 'Femenino') : 'Sin predicción',
                ),
                if (known)
                  Detail(
                    'Probabilidad',
                    '${(person.probability * 100).toStringAsFixed(1)} %',
                  ),
                const Text(
                  'Una estimación basada en nombres; no determina la identidad de una persona.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}

class RandomPersonPage extends StatelessWidget {
  final ApiService api;
  const RandomPersonPage(this.api, {super.key});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const Intro(
        '02 / Personas',
        'Alguien por descubrir',
        'Genera un perfil ficticio con Random User.',
      ),
      QueryView<RandomPerson>(
        load: (_) => api.randomPerson(),
        autoLoad: true,
        button: 'Otra persona',
        result: (person) => Surface(
          child: Column(
            children: [
              RemoteImage(person.photo),
              const SizedBox(height: 20),
              Detail('Nombre', person.first),
              Detail('Apellido', person.last),
              Detail(
                'Fecha de nacimiento',
                DateFormat('dd/MM/yyyy').format(person.birthday),
              ),
              Detail('Edad', '${person.age} años'),
            ],
          ),
        ),
      ),
    ],
  );
}

class UniversitiesPage extends StatelessWidget {
  final ApiService api;
  const UniversitiesPage(this.api, {super.key});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const Intro(
        '03 / Educación',
        'Estudia en cualquier lugar',
        'Escribe el país en inglés. Por ejemplo: Dominican Republic, Canada o Spain.',
      ),
      QueryView<List<University>>(
        load: api.universities,
        inputLabel: 'País en inglés',
        initial: 'Dominican Republic',
        result: (universities) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${universities.length} universidades',
              style: const TextStyle(color: muted),
            ),
            const SizedBox(height: 16),
            if (universities.isEmpty)
              const Surface(
                child: Text('No se encontraron universidades para ese país.'),
              ),
            for (final university in universities)
              Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.school_outlined, color: muted),
                    const SizedBox(height: 12),
                    Text(
                      university.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Detail(
                      'Dominios',
                      university.domains.isEmpty
                          ? 'No disponibles'
                          : university.domains.join('\n'),
                    ),
                    if (university.websites.isEmpty)
                      const Text('Página web no disponible'),
                    for (final website in university.websites)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => openLink(context, website),
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: Text(website, softWrap: true),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class WeatherPage extends StatefulWidget {
  final ApiService api;
  const WeatherPage(this.api, {super.key});
  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> with WidgetsBindingObserver {
  int _refresh = 0;
  Timer? _timer;
  // La fecha dominicana se calcula independientemente de la zona del teléfono.
  String get _today => DateTime.now()
      .toUtc()
      .subtract(const Duration(hours: 4))
      .toIso8601String()
      .split('T')
      .first;
  late String _lastDay = _today;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _checkDay());
  }

  void _checkDay() {
    if (mounted && _lastDay != _today) {
      setState(() {
        _lastDay = _today;
        _refresh++;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkDay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const Intro(
        '04 / República Dominicana',
        'El día en Santo Domingo',
        'Condiciones actuales y pronóstico de hoy, en la hora local dominicana.',
      ),
      QueryView<Weather>(
        key: ValueKey(_refresh),
        load: (_) => widget.api.weather(),
        autoLoad: true,
        button: 'Actualizar clima',
        result: (weather) => Surface(
          color: const Color(0xFFE4EFE9),
          child: Column(
            children: [
              Text(
                DateFormat('EEEE d MMMM yyyy', 'es').format(weather.date),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Icon(
                weather.code == 0
                    ? Icons.wb_sunny_outlined
                    : weather.code >= 51
                    ? Icons.water_drop_outlined
                    : Icons.cloud_outlined,
                size: 76,
                color: ink,
              ),
              Text(
                '${weather.temperature.toStringAsFixed(0)}°C',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                weather.description,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Detail(
                'Mínima / Máxima',
                '${weather.minimum.toStringAsFixed(0)}° / ${weather.maximum.toStringAsFixed(0)}°C',
              ),
              Detail('Probabilidad máxima de lluvia hoy', '${weather.rain} %'),
              Text(
                'Actualizado: ${weather.updated.replaceFirst('T', ' · ')}',
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      TextButton(
        onPressed: () => openLink(context, 'https://open-meteo.com/'),
        child: const Text('Datos meteorológicos: Open-Meteo'),
      ),
    ],
  );
}

class PokemonPage extends StatefulWidget {
  final ApiService api;
  const PokemonPage(this.api, {super.key});
  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final _player = AudioPlayer();
  bool _playing = false;
  bool _starting = false;
  StreamSubscription<PlayerState>? _subscription;
  @override
  void initState() {
    super.initState();
    _subscription = _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playing = state == PlayerState.playing);
    });
  }

  Future<void> _play(String source) async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      if (_playing) {
        await _player.stop();
      } else {
        await _player.play(UrlSource(source));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo reproducir el sonido. Intenta de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const Intro(
        '05 / Pokédex',
        'Encuentra tu Pokémon',
        'Busca por nombre. Prueba con pikachu, eevee o charizard.',
      ),
      QueryView<Pokemon>(
        load: widget.api.pokemon,
        inputLabel: 'Nombre del Pokémon',
        initial: 'pikachu',
        beforeLoad: () {
          unawaited(_player.stop());
        },
        result: (pokemon) => Surface(
          color: const Color(0xFFFFF2DB),
          child: Column(
            children: [
              RemoteImage(pokemon.image, size: 220),
              const SizedBox(height: 16),
              Text(
                pokemon.name.toUpperCase(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Detail(
                'Experiencia base',
                pokemon.experience?.toString() ?? 'No disponible',
              ),
              const Detail('Habilidades', ''),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pokemon.abilities
                    .map((a) => Chip(label: Text(a.replaceAll('-', ' '))))
                    .toList(),
              ),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: pokemon.cry == null || _starting
                    ? null
                    : () => _play(pokemon.cry!),
                icon: Icon(_playing ? Icons.stop : Icons.volume_up_outlined),
                label: Text(
                  pokemon.cry == null
                      ? 'Sonido no disponible'
                      : _playing
                      ? 'Detener sonido'
                      : 'Escuchar sonido (latest)',
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class NewsPage extends StatelessWidget {
  final ApiService api;
  const NewsPage(this.api, {super.key});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      Row(
        children: [
          Image.asset('assets/images/wordpress.png', width: 52, height: 52),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              AppConfig.newsSite,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      const Intro(
        '06 / Actualidad',
        'Las últimas publicaciones',
        'Tres novedades del sitio oficial de WordPress, de más reciente a más antigua.',
      ),
      QueryView<List<NewsPost>>(
        load: (_) => api.news(),
        autoLoad: true,
        button: 'Actualizar noticias',
        result: (posts) => Column(
          children: [
            if (posts.isEmpty)
              const Surface(
                child: Text('El sitio todavía no tiene publicaciones.'),
              ),
            for (final post in posts)
              Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(post.date),
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      post.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      post.excerpt.isEmpty
                          ? 'Resumen no disponible.'
                          : post.excerpt,
                      style: const TextStyle(height: 1.6, color: muted),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => openLink(context, post.link),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Visitar noticia'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const Intro(
        '07 / Acerca de',
        'Hagamos algo juntos',
        'Desarrollo móvil, ideas y oportunidades.',
      ),
      Surface(
        child: Column(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/profile.png',
                width: 140,
                height: 140,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppConfig.author,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(AppConfig.enrollment, style: TextStyle(color: muted)),
            const SizedBox(height: 20),
            const Text(AppConfig.bio, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (AppConfig.email.isNotEmpty)
              TextButton.icon(
                onPressed: () => openLink(context, 'mailto:${AppConfig.email}'),
                icon: const Icon(Icons.mail_outline),
                label: const Text(AppConfig.email),
              ),
            if (AppConfig.phone.isNotEmpty)
              TextButton.icon(
                onPressed: () => openLink(context, 'tel:${AppConfig.phone}'),
                icon: const Icon(Icons.phone_outlined),
                label: const Text(AppConfig.phone),
              ),
            if (AppConfig.portfolio.isNotEmpty)
              TextButton.icon(
                onPressed: () => openLink(context, AppConfig.portfolio),
                icon: const Icon(Icons.language),
                label: const Text('Visitar portafolio'),
              ),
            if (AppConfig.isPlaceholder)
              const Text(
                'Foto y datos de contacto pendientes de personalizar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 12),
              ),
          ],
        ),
      ),
      const Text(
        'Caja de herramientas · v1.0.0\nProyecto académico desarrollado con Flutter.',
        textAlign: TextAlign.center,
        style: TextStyle(color: muted, fontSize: 12),
      ),
    ],
  );
}
