/// API Configuration for Norden Backend
class ApiConfig {
  // Base URLs
  static const String baseUrl = 'http://192.168.1.4:5129/api';
  static const String swaggerUrl = 'http://192.168.1.4:5129';

  // Endpoints
  static const String authEndpoint = '$baseUrl/auth';
  static const String productsEndpoint = '$baseUrl/products';
  static const String cartEndpoint = '$baseUrl/cart';
  static const String ordersEndpoint = '$baseUrl/orders';
  static const String addressesEndpoint = '$baseUrl/addresses';
  static const String wishlistEndpoint = '$baseUrl/wishlist';

  // Headers
  static Map<String, String> getAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> getHeaders() {
    return {'Content-Type': 'application/json'};
  }

  // Token management keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}
