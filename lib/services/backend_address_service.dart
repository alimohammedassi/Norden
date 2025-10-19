import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/address.dart';
import 'api_service.dart';
import 'backend_auth_service.dart';

/// Address service using the custom backend API
class BackendAddressService {
  static final BackendAddressService _instance =
      BackendAddressService._internal();
  factory BackendAddressService() => _instance;
  BackendAddressService._internal();

  final BackendAuthService _authService = BackendAuthService();

  /// Get all user addresses
  Future<List<Address>> getAddresses() async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      final response = await ApiService.get(
        ApiConfig.addressesEndpoint,
        headers: headers,
      );

      final List<dynamic> addressesJson = response['data'];
      return addressesJson.map((json) => Address.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting addresses: $e');
      rethrow;
    }
  }

  /// Get address by ID
  Future<Address?> getAddressById(String addressId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      final response = await ApiService.get(
        '${ApiConfig.addressesEndpoint}/$addressId',
        headers: headers,
      );

      return Address.fromJson(response['data']);
    } catch (e) {
      debugPrint('Error getting address by ID: $e');
      return null;
    }
  }

  /// Get default address
  Future<Address?> getDefaultAddress() async {
    try {
      final addresses = await getAddresses();
      return addresses.firstWhere(
        (address) => address.isDefault,
        orElse: () => addresses.isNotEmpty ? addresses.first : null!,
      );
    } catch (e) {
      debugPrint('Error getting default address: $e');
      return null;
    }
  }

  /// Add new address
  Future<Address> addAddress({
    required String label,
    required String name,
    required String phone,
    required String street,
    required String city,
    required String country,
    bool isDefault = false,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      final response = await ApiService.post(
        ApiConfig.addressesEndpoint,
        headers: headers,
        body: {
          'label': label,
          'name': name,
          'phone': phone,
          'street': street,
          'city': city,
          'country': country,
          'isDefault': isDefault,
        },
      );

      return Address.fromJson(response['data']);
    } catch (e) {
      debugPrint('Error adding address: $e');
      rethrow;
    }
  }

  /// Update address
  Future<Address> updateAddress({
    required String addressId,
    required String label,
    required String name,
    required String phone,
    required String street,
    required String city,
    required String country,
    bool isDefault = false,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      final response = await ApiService.put(
        '${ApiConfig.addressesEndpoint}/$addressId',
        headers: headers,
        body: {
          'label': label,
          'name': name,
          'phone': phone,
          'street': street,
          'city': city,
          'country': country,
          'isDefault': isDefault,
        },
      );

      return Address.fromJson(response['data']);
    } catch (e) {
      debugPrint('Error updating address: $e');
      rethrow;
    }
  }

  /// Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      await ApiService.delete(
        '${ApiConfig.addressesEndpoint}/$addressId',
        headers: headers,
      );
    } catch (e) {
      debugPrint('Error deleting address: $e');
      rethrow;
    }
  }

  /// Set default address
  Future<void> setDefaultAddress(String addressId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      await ApiService.put(
        '${ApiConfig.addressesEndpoint}/$addressId/default',
        headers: headers,
      );
    } catch (e) {
      debugPrint('Error setting default address: $e');
      rethrow;
    }
  }
}
