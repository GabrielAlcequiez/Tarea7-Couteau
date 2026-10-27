/// Datos del autor y configuración de servicios.
abstract final class AppConfig {
  static const version = '1.0.1';
  static const author = 'Gabriel Alcequiez';
  static const bio =
      'Estudiante de desarrollo de software enfocado en implementar soluciones modernas y eficientes.';
  static const enrollment = '2025-1062';
  static const email = '20251062@itla.edu.do';
  static const phone = '';
  static const portfolio = '';
  static const isPlaceholder = false;
  static const genderApiKey = String.fromEnvironment('GENDERIZE_API_KEY');
  static const newsSite = 'WordPress News';
  static const newsHome = 'https://wordpress.org/news/';
  static const newsEndpoint = 'https://wordpress.org/news/wp-json/wp/v2/posts';
}
