/// API Configuration — NORDEN Maison de Luxe
///
/// To switch environments, change [baseUrl] only.
/// All other endpoints are derived from it automatically.
class ApiConfig {
  // ── Base URL ──────────────────────────────────────────────────────────────
  // Change this single value to point to your backend environment.
  // Example dev:        'http://192.168.1.4:5129/api'
  // Example staging:    'https://api-staging.norden-luxe.com/api'
  // Example production: 'https://api.norden-luxe.com/api'
  static const String baseUrl = 'http://192.168.1.4:5129/api';

  // ── Endpoints ─────────────────────────────────────────────────────────────
  static const String authEndpoint = '$baseUrl/auth';
  static const String productsEndpoint = '$baseUrl/products';
  static const String categoriesEndpoint = '$baseUrl/categories';
  static const String seasonsEndpoint = '$baseUrl/seasons';
  static const String cartEndpoint = '$baseUrl/cart';
  static const String wishlistEndpoint = '$baseUrl/wishlist';
  static const String ordersEndpoint = '$baseUrl/orders';
  static const String addressesEndpoint = '$baseUrl/addresses';
  static const String reviewsEndpoint = '$baseUrl/reviews';
  static const String profileEndpoint = '$baseUrl/profile';

  // ── Headers ───────────────────────────────────────────────────────────────
  static Map<String, String> getAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  static Map<String, String> getHeaders() => {
    'Content-Type': 'application/json',
  };

  // ── Token storage keys ────────────────────────────────────────────────────
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}
