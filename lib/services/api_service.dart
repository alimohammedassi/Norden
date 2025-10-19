import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Base API service with common functionality
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Handle API response and throw exceptions for errors
  static void handleApiResponse(Map<String, dynamic> response) {
    if (response['success'] == false) {
      final error = response['error'];
      throw ApiException(
        error['code'] ?? 'UNKNOWN_ERROR',
        error['message'] ?? 'An error occurred',
        error['details'],
      );
    }
  }

  /// Make GET request
  static Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers ?? ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        handleApiResponse(data);
        return data;
      } else {
        throw ApiException(
          'HTTP_ERROR',
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('NETWORK_ERROR', 'Network request failed: $e');
    }
  }

  /// Make POST request
  static Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers ?? ApiConfig.getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        handleApiResponse(data);
        return data;
      } else {
        throw ApiException(
          'HTTP_ERROR',
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('NETWORK_ERROR', 'Network request failed: $e');
    }
  }

  /// Make PUT request
  static Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers ?? ApiConfig.getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        handleApiResponse(data);
        return data;
      } else {
        throw ApiException(
          'HTTP_ERROR',
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('NETWORK_ERROR', 'Network request failed: $e');
    }
  }

  /// Make DELETE request
  static Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers ?? ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        handleApiResponse(data);
        return data;
      } else {
        throw ApiException(
          'HTTP_ERROR',
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('NETWORK_ERROR', 'Network request failed: $e');
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  ApiException(this.code, this.message, [this.details]);

  @override
  String toString() => 'ApiException: $code - $message';
}
