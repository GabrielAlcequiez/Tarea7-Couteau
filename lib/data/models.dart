import 'package:html/parser.dart' as html;

String plainText(String value) => html.parse(value).body?.text.trim() ?? '';

class GenderPrediction {
  final String name;
  final String? gender;
  final double probability;
  const GenderPrediction(this.name, this.gender, this.probability);
  factory GenderPrediction.fromJson(Map<String, dynamic> json) =>
      GenderPrediction(
        json['name'] as String,
        json['gender'] as String?,
        (json['probability'] as num?)?.toDouble() ?? 0,
      );
}

class RandomPerson {
  final String first, last, photo;
  final DateTime birthday;
  final int age;
  const RandomPerson(
    this.first,
    this.last,
    this.photo,
    this.birthday,
    this.age,
  );
  factory RandomPerson.fromJson(Map<String, dynamic> json) => RandomPerson(
    json['name']['first'] as String,
    json['name']['last'] as String,
    json['picture']['large'] as String,
    DateTime.parse(json['dob']['date'] as String),
    json['dob']['age'] as int,
  );
}

class University {
  final String name;
  final List<String> domains, websites;
  const University(this.name, this.domains, this.websites);
  factory University.fromJson(Map<String, dynamic> json) => University(
    json['name'] as String? ?? 'Universidad sin nombre',
    (json['domains'] as List? ?? []).cast<String>(),
    (json['web_pages'] as List? ?? []).cast<String>(),
  );
}

class Pokemon {
  final String name;
  final String? image, cry;
  final int? experience;
  final List<String> abilities;
  const Pokemon(
    this.name,
    this.image,
    this.cry,
    this.experience,
    this.abilities,
  );
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>?;
    final other = sprites?['other'] as Map<String, dynamic>?;
    final artwork = other?['official-artwork'] as Map<String, dynamic>?;
    return Pokemon(
      json['name'] as String,
      (artwork?['front_default'] ?? sprites?['front_default']) as String?,
      (json['cries'] as Map<String, dynamic>?)?['latest'] as String?,
      json['base_experience'] as int?,
      (json['abilities'] as List? ?? [])
          .map((a) => a['ability']['name'] as String)
          .toList(),
    );
  }
}

class NewsPost {
  final String title, excerpt, link;
  final DateTime date;
  const NewsPost(this.title, this.excerpt, this.link, this.date);
  factory NewsPost.fromJson(Map<String, dynamic> json) => NewsPost(
    plainText(json['title']['rendered'] as String),
    plainText(json['excerpt']['rendered'] as String),
    json['link'] as String,
    DateTime.parse(json['date'] as String),
  );
}

class Weather {
  final DateTime date;
  final double temperature, minimum, maximum;
  final int code, rain;
  final String updated;
  const Weather(
    this.date,
    this.temperature,
    this.minimum,
    this.maximum,
    this.code,
    this.rain,
    this.updated,
  );
  factory Weather.fromJson(Map<String, dynamic> json) {
    final daily = json['daily'];
    final current = json['current'];
    return Weather(
      DateTime.parse(daily['time'][0] as String),
      (current['temperature_2m'] as num).toDouble(),
      (daily['temperature_2m_min'][0] as num).toDouble(),
      (daily['temperature_2m_max'][0] as num).toDouble(),
      (current['weather_code'] as num).toInt(),
      (daily['precipitation_probability_max'][0] as num?)?.toInt() ?? 0,
      current['time'] as String,
    );
  }
  String get description => switch (code) {
    0 => 'Despejado',
    1 || 2 => 'Parcialmente nublado',
    3 => 'Nublado',
    45 || 48 => 'Niebla',
    >= 51 && <= 57 => 'Llovizna',
    >= 61 && <= 67 => 'Lluvia',
    >= 71 && <= 77 => 'Nieve',
    >= 80 && <= 82 => 'Chubascos',
    85 || 86 => 'Chubascos de nieve',
    >= 95 => 'Tormenta',
    _ => 'Condición no disponible',
  };
}
