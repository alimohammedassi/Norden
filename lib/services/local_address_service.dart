import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/address.dart';

/// Local address service for guest users using SharedPreferences
class LocalAddressService with ChangeNotifier {
  static final LocalAddressService _instance = LocalAddressService._internal();
  factory LocalAddressService() => _instance;
  LocalAddressService._internal();

  static const String _addressesKey = 'local_addresses';

  List<Address> _addresses = [];
  Address? _defaultAddress;

  /// Get all addresses
  List<Address> get addresses => _addresses;

  /// Get default address
  Address? get defaultAddress => _defaultAddress;

  /// Initialize the service
  Future<void> initialize() async {
    await _loadAddresses();
  }

  /// Load addresses from local storage
  Future<void> _loadAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getStringList(_addressesKey) ?? [];

      _addresses = addressesJson
          .map((json) => Address.fromJson(jsonDecode(json)))
          .toList();

      // Find default address
      if (_addresses.isNotEmpty) {
        _defaultAddress = _addresses.firstWhere(
          (address) => address.isDefault,
          orElse: () => _addresses.first,
        );
      } else {
        _defaultAddress = null;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading addresses: $e');
      _addresses = [];
      _defaultAddress = null;
    }
  }

  /// Save addresses to local storage
  Future<void> _saveAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = _addresses
          .map((address) => jsonEncode(address.toJson()))
          .toList();

      await prefs.setStringList(_addressesKey, addressesJson);
    } catch (e) {
      debugPrint('Error saving addresses: $e');
    }
  }

  /// Add new address
  Future<void> addAddress(Address address) async {
    try {
      // If this is the first address or marked as default, make it default
      if (_addresses.isEmpty || address.isDefault) {
        // Remove default from all other addresses
        for (int i = 0; i < _addresses.length; i++) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }
        address = address.copyWith(isDefault: true);
      }

      _addresses.add(address);
      _defaultAddress = address.isDefault ? address : _defaultAddress;

      await _saveAddresses();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding address: $e');
      rethrow;
    }
  }

  /// Update address by index
  Future<void> updateAddressByIndex(int index, Address address) async {
    try {
      if (index >= 0 && index < _addresses.length) {
        // If setting as default, remove default from others
        if (address.isDefault) {
          for (int i = 0; i < _addresses.length; i++) {
            if (i != index) {
              _addresses[i] = _addresses[i].copyWith(isDefault: false);
            }
          }
        }

        _addresses[index] = address;
        _defaultAddress = address.isDefault ? address : _defaultAddress;

        await _saveAddresses();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating address: $e');
      rethrow;
    }
  }

  /// Delete address by index
  Future<void> deleteAddressByIndex(int index) async {
    try {
      if (index >= 0 && index < _addresses.length) {
        final wasDefault = _addresses[index].isDefault;
        _addresses.removeAt(index);

        // If we deleted the default address, set a new default
        if (wasDefault && _addresses.isNotEmpty) {
          _addresses[0] = _addresses[0].copyWith(isDefault: true);
          _defaultAddress = _addresses[0];
        } else if (_addresses.isEmpty) {
          _defaultAddress = null;
        }

        await _saveAddresses();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting address: $e');
      rethrow;
    }
  }

  /// Set default address by index
  Future<void> setDefaultAddressByIndex(int index) async {
    try {
      if (index >= 0 && index < _addresses.length) {
        // Remove default from all addresses
        for (int i = 0; i < _addresses.length; i++) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }

        // Set the selected address as default
        _addresses[index] = _addresses[index].copyWith(isDefault: true);
        _defaultAddress = _addresses[index];

        await _saveAddresses();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error setting default address: $e');
      rethrow;
    }
  }

  /// Clear all addresses
  Future<void> clearAllAddresses() async {
    try {
      _addresses.clear();
      _defaultAddress = null;
      await _saveAddresses();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing addresses: $e');
      rethrow;
    }
  }
}
