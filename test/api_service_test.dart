import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tarea7_intromovil/data/api_service.dart';
import 'package:tarea7_intromovil/data/models.dart';

void main() {
  test('Genderize conserva el resultado desconocido', () async {
    final api = ApiService(
      client: MockClient((request) async {
        expect(request.url.queryParameters['name'], 'Nombre raro');
        return http.Response(
          '{"name":"Nombre raro","gender":null,"probability":0}',
          200,
        );
      }),
    );
    addTearDown(api.close);
    expect((await api.gender(' Nombre raro ')).gender, isNull);
  });
  test('El país se codifica como un único parámetro', () async {
    final api = ApiService(
      client: MockClient((request) async {
        expect(request.url.queryParameters['country'], 'Dominican Republic');
        return http.Response(
          '[{"name":"ITLA","domains":["itla.edu.do"],"web_pages":["https://itla.edu.do"]}]',
          200,
        );
      }),
    );
    addTearDown(api.close);
    final result = await api.universities('Dominican Republic');
    expect(result.single.domains.single, 'itla.edu.do');
    expect(result.single.websites.single, 'https://itla.edu.do');
  });
  test('Universidades vacías son un resultado válido', () async {
    final api = ApiService(
      client: MockClient((_) async => http.Response('[]', 200)),
    );
    addTearDown(api.close);
    expect(await api.universities('Atlantis'), isEmpty);
  });
  test('Pokémon normaliza el nombre, usa latest y conserva la caché', () async {
    var calls = 0;
    final api = ApiService(
      client: MockClient((request) async {
        calls++;
        expect(request.url.path, '/api/v2/pokemon/pikachu');
        return http.Response(
          jsonEncode({
            'name': 'pikachu',
            'base_experience': 112,
            'sprites': {'front_default': 'https://example.com/sprite.png'},
            'cries': {
              'latest': 'https://example.com/latest.ogg',
              'legacy': 'old.ogg',
            },
            'abilities': [
              {
                'ability': {'name': 'static'},
              },
            ],
          }),
          200,
        );
      }),
    );
    addTearDown(api.close);
    final result = await api.pokemon(' PIKACHU ');
    expect(result.cry, 'https://example.com/latest.ogg');
    expect(result.image, 'https://example.com/sprite.png');
    expect(result.experience, 112);
    expect(result.abilities, ['static']);
    await api.pokemon('pikachu');
    expect(calls, 1);
  });
  test('WordPress pide las tres últimas y limpia HTML y entidades', () async {
    final api = ApiService(
      client: MockClient((request) async {
        expect(request.url.queryParameters['per_page'], '3');
        expect(request.url.queryParameters['order'], 'desc');
        expect(request.url.queryParameters['orderby'], 'date');
        return http.Response(
          jsonEncode([
            {
              'title': {'rendered': 'Flutter &amp; WordPress'},
              'excerpt': {'rendered': '<p>Una <strong>noticia</strong>.</p>'},
              'link': 'https://example.com/news',
              'date': '2026-10-27T10:00:00',
            },
          ]),
          200,
        );
      }),
    );
    addTearDown(api.close);
    final post = (await api.news()).single;
    expect(post.title, 'Flutter & WordPress');
    expect(post.excerpt, 'Una noticia.');
  });
  test('El clima respeta el día devuelto por la API dominicana', () async {
    final api = ApiService(
      client: MockClient((request) async {
        expect(
          request.url.queryParameters['timezone'],
          'America/Santo_Domingo',
        );
        expect(request.url.queryParameters['forecast_days'], '1');
        return http.Response(
          jsonEncode({
            'current': {
              'temperature_2m': 28.5,
              'weather_code': 61,
              'time': '2026-10-27T23:55',
            },
            'daily': {
              'time': ['2026-10-27'],
              'temperature_2m_min': [23],
              'temperature_2m_max': [30],
              'precipitation_probability_max': [80],
            },
          }),
          200,
        );
      }),
    );
    addTearDown(api.close);
    final weather = await api.weather();
    expect(weather.date, DateTime(2026, 10, 27));
    expect(weather.rain, 80);
    expect(weather.description, 'Lluvia');
  });
  test('Una cuota agotada tiene un mensaje comprensible', () async {
    final api = ApiService(
      client: MockClient((_) async => http.Response('{}', 429)),
    );
    addTearDown(api.close);
    expect(
      api.gender('Irma'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'mensaje',
          contains('límite'),
        ),
      ),
    );
  });
  test('JSON incorrecto no se presenta como un resultado válido', () async {
    final api = ApiService(
      client: MockClient((_) async => http.Response('<html>error</html>', 200)),
    );
    addTearDown(api.close);
    expect(api.news(), throwsA(isA<ApiException>()));
  });
  test('La persona contiene todos los campos requeridos', () {
    final person = RandomPerson.fromJson({
      'name': {'first': 'Ana', 'last': 'Pérez'},
      'picture': {'large': 'https://example.com/a.jpg'},
      'dob': {'date': '2000-02-03T10:00:00Z', 'age': 26},
    });
    expect(person.first, 'Ana');
    expect(person.last, 'Pérez');
    expect(person.birthday.day, 3);
    expect(person.age, 26);
  });
}
