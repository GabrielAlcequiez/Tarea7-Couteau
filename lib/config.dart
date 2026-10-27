/// Sustituir estos datos al recibir la información del autor.
abstract final class AppConfig {
  static const author = 'Tu nombre aquí';
  static const bio =
      'Desarrollador/a de aplicaciones móviles. '
      'Este espacio mostrará tu perfil profesional.';
  static const enrollment = 'Matrícula pendiente';
  static const email = '';
  static const phone = '';
  static const portfolio = '';
  static const isPlaceholder = true;
  static const genderApiKey = String.fromEnvironment('GENDERIZE_API_KEY');
  static const newsSite = 'WordPress News';
  static const newsHome = 'https://wordpress.org/news/';
  static const newsEndpoint = 'https://wordpress.org/news/wp-json/wp/v2/posts';
}
