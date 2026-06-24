class BackendConfig {
  /// Centralized base URL configuration for local LAN debugging.
  /// Easily editable by hand. Avoid using localhost to support real tablet testing.
  static const String defaultBaseUrl = 'https://frontend-nexthouseinstant.pages.dev/api';
  static const String defaultPrivacyUrl = 'https://nexthousecopenhagen.com/privacy-policy';

  final String baseUrl;
  final Duration timeout;
  final String privacyPolicyUrl;

  const BackendConfig({
    this.baseUrl = defaultBaseUrl,
    this.timeout = const Duration(seconds: 15),
    this.privacyPolicyUrl = defaultPrivacyUrl,
  });

  /// Helper to get a clean baseUrl without accidental spaces.
  String get cleanedBaseUrl => baseUrl.trim().replaceAll(' ', '');

  /// Helper utility to construct absolute URLs based on the [baseUrl]
  /// and the endpoint [path] (with optional query parameters).
  Uri getUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final base = Uri.parse(cleanedBaseUrl);
    
    var combinedPath = '${base.path}$cleanPath';
    if (base.path.endsWith('/api') && cleanPath.startsWith('/api')) {
      combinedPath = base.path + cleanPath.substring(4);
    }
    
    return base.replace(
      path: combinedPath.replaceAll('//', '/'),
      queryParameters: queryParameters,
    );
  }
}
