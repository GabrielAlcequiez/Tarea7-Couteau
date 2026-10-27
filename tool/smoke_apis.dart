import 'dart:io';

import 'package:tarea7_intromovil/data/api_service.dart';

Future<void> main() async {
  final api = ApiService();
  final checks = <String, Future<String> Function()>{
    'Genderize': () async {
      final p = await api.gender('irma');
      return '${p.name}: ${p.gender}';
    },
    'Random User': () async {
      final p = await api.randomPerson();
      return 'Perfil recibido, edad ${p.age}';
    },
    'Universidades': () async =>
        '${(await api.universities('Dominican Republic')).length} resultados',
    'Clima': () async {
      final w = await api.weather();
      return '${w.date}: ${w.temperature} °C';
    },
    'Pokémon': () async {
      final p = await api.pokemon('pikachu');
      return '${p.name}, latest: ${p.cry != null}';
    },
    'WordPress': () async => '${(await api.news()).length} publicaciones',
  };
  await Future.wait(
    checks.entries.map((e) async {
      try {
        stdout.writeln('OK ${e.key}: ${await e.value()}');
      } catch (error) {
        stdout.writeln('ERROR ${e.key}: $error');
        exitCode = 1;
      }
    }),
  );
  api.close();
}
