class BackendConfig {
  /// Centralized base URL configuration for local LAN debugging.
  /// Easily editable by hand. Avoid using localhost to support real tablet testing.
  static const String defaultBaseUrl = 'http://167.233.52.44:8080';

  final String baseUrl;
  final Duration timeout;

  const BackendConfig({
    this.baseUrl = defaultBaseUrl,
    this.timeout = const Duration(seconds: 15),
  });

  /// Helper to get a clean baseUrl without accidental spaces.
  String get cleanedBaseUrl => baseUrl.trim().replaceAll(' ', '');

  /// Helper utility to construct absolute URLs based on the [baseUrl]
  /// and the endpoint [path] (with optional query parameters).
  Uri getUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final base = Uri.parse(cleanedBaseUrl);
    return base.replace(
      path: '${base.path}$cleanPath'.replaceAll('//', '/'),
      queryParameters: queryParameters,
    );
  }
}
