import 'package:flutter/foundation.dart';
import '../models/address.dart';
import 'backend_address_service.dart';
import 'local_address_service.dart';
import 'backend_auth_service.dart';

/// Address service wrapper for backward compatibility
class AddressService with ChangeNotifier {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  final BackendAddressService _backendAddress = BackendAddressService();
  final LocalAddressService _localAddress = LocalAddressService();
  final BackendAuthService _authService = BackendAuthService();

  // Local cache
  List<Address> _addresses = [];
  Address? _defaultAddress;

  /// Check if user is authenticated
  bool get _isAuthenticated => _authService.currentUser != null;

  /// Get all user addresses
  Future<List<Address>> getAddresses() async {
    try {
      if (_isAuthenticated) {
        return await _backendAddress.getAddresses();
      } else {
        return _localAddress.addresses;
      }
    } catch (e) {
      debugPrint('Error getting addresses: $e');
      return _isAuthenticated ? [] : _localAddress.addresses;
    }
  }

  /// Add new address
  Future<void> addAddress({
    required String label,
    required String name,
    required String phone,
    required String street,
    required String city,
    required String country,
    bool isDefault = false,
  }) async {
    try {
      if (_isAuthenticated) {
        await _backendAddress.addAddress(
          label: label,
          name: name,
          phone: phone,
          street: street,
          city: city,
          country: country,
          isDefault: isDefault,
        );
      } else {
        final now = DateTime.now();
        final address = Address(
          id: now.millisecondsSinceEpoch.toString(),
          label: label,
          name: name,
          phone: phone,
          street: street,
          city: city,
          country: country,
          isDefault: isDefault,
          createdAt: now,
          updatedAt: now,
        );
        await _localAddress.addAddress(address);
      }
    } catch (e) {
      debugPrint('Error adding address: $e');
      rethrow;
    }
  }

  /// Update address
  Future<void> updateAddress({
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
      await _backendAddress.updateAddress(
        addressId: addressId,
        label: label,
        name: name,
        phone: phone,
        street: street,
        city: city,
        country: country,
        isDefault: isDefault,
      );
    } catch (e) {
      debugPrint('Error updating address: $e');
      rethrow;
    }
  }

  /// Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      await _backendAddress.deleteAddress(addressId);
    } catch (e) {
      debugPrint('Error deleting address: $e');
      rethrow;
    }
  }

  /// Set default address
  Future<void> setDefaultAddress(String addressId) async {
    try {
      await _backendAddress.setDefaultAddress(addressId);
    } catch (e) {
      debugPrint('Error setting default address: $e');
      rethrow;
    }
  }

  /// Get default address
  Future<Address?> getDefaultAddress() async {
    try {
      return await _backendAddress.getDefaultAddress();
    } catch (e) {
      debugPrint('Error getting default address: $e');
      return null;
    }
  }

  /// Get address by ID
  Future<Address?> getAddressById(String addressId) async {
    try {
      return await _backendAddress.getAddressById(addressId);
    } catch (e) {
      debugPrint('Error getting address by ID: $e');
      return null;
    }
  }

  /// Load addresses and update local cache
  Future<void> loadAddresses() async {
    try {
      if (_isAuthenticated) {
        _addresses = await _backendAddress.getAddresses();
        _defaultAddress = await _backendAddress.getDefaultAddress();
      } else {
        await _localAddress.initialize();
        _addresses = _localAddress.addresses;
        _defaultAddress = _localAddress.defaultAddress;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading addresses: $e');
      // Fallback to local storage for guest users
      if (!_isAuthenticated) {
        try {
          await _localAddress.initialize();
          _addresses = _localAddress.addresses;
          _defaultAddress = _localAddress.defaultAddress;
          notifyListeners();
        } catch (localError) {
          debugPrint('Error loading local addresses: $localError');
        }
      }
    }
  }

  /// Get addresses (cached version)
  List<Address> get addresses => _addresses;

  /// Get default address (cached version)
  Address? get defaultAddress => _defaultAddress;

  /// Add address (alternative method signature)
  Future<void> addAddressObject(Address address) async {
    try {
      if (_isAuthenticated) {
        await addAddress(
          label: address.label,
          name: address.name,
          phone: address.phone,
          street: address.street,
          city: address.city,
          country: address.country,
          isDefault: address.isDefault,
        );
      } else {
        await _localAddress.addAddress(address);
      }
      await loadAddresses();
    } catch (e) {
      debugPrint('Error adding address object: $e');
      rethrow;
    }
  }

  /// Update address by index (alternative method signature)
  Future<void> updateAddressByIndex(int index, Address address) async {
    try {
      if (_isAuthenticated) {
        if (index >= 0 && index < _addresses.length) {
          final addressId = _addresses[index].id;
          await updateAddress(
            addressId: addressId,
            label: address.label,
            name: address.name,
            phone: address.phone,
            street: address.street,
            city: address.city,
            country: address.country,
            isDefault: address.isDefault,
          );
        }
      } else {
        await _localAddress.updateAddressByIndex(index, address);
      }
      await loadAddresses();
    } catch (e) {
      debugPrint('Error updating address by index: $e');
      rethrow;
    }
  }

  /// Set default address by index
  Future<void> setDefaultAddressByIndex(int index) async {
    if (index >= 0 && index < _addresses.length) {
      final addressId = _addresses[index].id;
      await setDefaultAddress(addressId);
      await loadAddresses();
    }
  }

  /// Remove address by index
  Future<void> removeAddress(int index) async {
    if (index >= 0 && index < _addresses.length) {
      final addressId = _addresses[index].id;
      await deleteAddress(addressId);
      await loadAddresses();
    }
  }

  /// Initialize address service
  Future<void> initialize() async {
    await loadAddresses();
  }
}
