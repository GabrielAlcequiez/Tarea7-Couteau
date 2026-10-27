import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import 'models.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  final http.Client _client;
  final Map<String, Pokemon> _pokemonCache = {};
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  void close() => _client.close();
  Future<dynamic> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw ApiException(switch (response.statusCode) {
          401 || 403 => 'El servicio rechazó el acceso. Revisa su configuración o clave API.',
          402 => 'El servicio requiere una suscripción activa.',
          404 => 'No se encontró el recurso. Comprueba lo que escribiste.',
          429 => 'Se alcanzó el límite de consultas. Intenta más tarde.',
          _ =>
            'El servicio no está disponible (${response.statusCode}). Intenta otra vez.',
        });
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on TimeoutException {
      throw const ApiException(
        'El servicio tardó demasiado. Intenta otra vez.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No se pudo conectar. Revisa tu conexión a Internet.',
      );
    } on FormatException {
      throw const ApiException(
        'El servicio devolvió una respuesta inesperada.',
      );
    }
  }

  Future<GenderPrediction> gender(String name) async =>
      GenderPrediction.fromJson(
        await _get(
          Uri.https('api.genderize.io', '/', {
            'name': name.trim(),
            if (AppConfig.genderApiKey.isNotEmpty)
              'apikey': AppConfig.genderApiKey,
          }),
        ) as Map<String, dynamic>,
      );
  Future<RandomPerson> randomPerson() async {
    final data = await _get(
      Uri.https('randomuser.me', '/api/', {'results': '1'}),
    );
    return RandomPerson.fromJson(data['results'][0] as Map<String, dynamic>);
  }

  Future<List<University>> universities(String country) async {
    final data = await _get(
      Uri.https('adamix.net', '/proxy.php', {'country': country.trim()}),
    );
    if (data is! List) {
      throw const ApiException(
        'La API de universidades no devolvió una lista válida.',
      );
    }
    return data
        .map((e) => University.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Pokemon> pokemon(String name) async {
    final key = name.trim().toLowerCase();
    if (_pokemonCache.containsKey(key)) return _pokemonCache[key]!;
    final data = await _get(
      Uri.https('pokeapi.co', '/api/v2/pokemon/${Uri.encodeComponent(key)}'),
    );
    final pokemon = Pokemon.fromJson(data as Map<String, dynamic>);
    _pokemonCache[key] = pokemon;
    return pokemon;
  }

  Future<Weather> weather() async => Weather.fromJson(
    await _get(
      Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '18.4861',
        'longitude': '-69.9312',
        'current': 'temperature_2m,weather_code',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'timezone': 'America/Santo_Domingo',
        'forecast_days': '1',
      }),
    ) as Map<String, dynamic>,
  );
  Future<List<NewsPost>> news() async {
    final data = await _get(
      Uri.parse(AppConfig.newsEndpoint).replace(
        queryParameters: {
          'per_page': '3',
          'orderby': 'date',
          'order': 'desc',
          '_fields': 'id,date,link,title,excerpt',
        },
      ),
    );
    if (data is! List) {
      throw const ApiException(
        'La API de noticias no devolvió una lista válida.',
      );
    }
    return data
        .map((e) => NewsPost.fromJson(e as Map<String, dynamic>))
        .take(3)
        .toList();
  }
}
