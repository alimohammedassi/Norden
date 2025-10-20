import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address.dart';

/// Address service using local storage (no backend)
class AddressService with ChangeNotifier {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  static const String _prefsKey = 'local_addresses_v1';

  List<Address> _addresses = [];
  Address? _defaultAddress;

  List<Address> get addresses => _addresses;
  Address? get defaultAddress => _defaultAddress;

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _addresses.map((e) => e.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(jsonList));
  }

  Future<void> loadAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_prefsKey);
      _addresses = [];
      if (data != null && data.isNotEmpty) {
        final List<dynamic> list = jsonDecode(data);
        _addresses = list
            .map((e) => Address.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      _defaultAddress = _addresses.where((a) => a.isDefault).isNotEmpty
          ? _addresses.firstWhere((a) => a.isDefault)
          : (_addresses.isNotEmpty ? _addresses.first : null);
      notifyListeners();
    } catch (e) {
      debugPrint('Addresses load error: $e');
    }
  }

  Future<List<Address>> getAddresses() async {
    await loadAddresses();
    return _addresses;
  }

  Future<void> addAddress({
    required String label,
    required String name,
    required String phone,
    required String street,
    required String city,
    required String country,
    bool isDefault = false,
  }) async {
    final now = DateTime.now();
    final newAddress = Address(
      id: 'addr_${now.millisecondsSinceEpoch}',
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
    if (isDefault) {
      _addresses = _addresses
          .map((a) => a.copyWith(isDefault: false, updatedAt: now))
          .toList();
    }
    _addresses.add(newAddress);
    if (isDefault || _defaultAddress == null) {
      _defaultAddress = newAddress;
    }
    await _persist();
    notifyListeners();
  }

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
    final now = DateTime.now();
    for (var i = 0; i < _addresses.length; i++) {
      if (_addresses[i].id == addressId) {
        _addresses[i] = _addresses[i].copyWith(
          label: label,
          name: name,
          phone: phone,
          street: street,
          city: city,
          country: country,
          isDefault: isDefault,
          updatedAt: now,
        );
        break;
      }
    }
    if (isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        if (_addresses[i].id != addressId && _addresses[i].isDefault) {
          _addresses[i] = _addresses[i].copyWith(
            isDefault: false,
            updatedAt: now,
          );
        }
      }
      _defaultAddress = _addresses.firstWhere((a) => a.id == addressId);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> deleteAddress(String addressId) async {
    _addresses.removeWhere((a) => a.id == addressId);
    if (_defaultAddress?.id == addressId) {
      _defaultAddress = _addresses.isNotEmpty ? _addresses.first : null;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setDefaultAddress(String addressId) async {
    final now = DateTime.now();
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(
        isDefault: _addresses[i].id == addressId,
        updatedAt: now,
      );
    }
    _defaultAddress = _addresses.firstWhere((a) => a.id == addressId);
    await _persist();
    notifyListeners();
  }

  Future<Address?> getDefaultAddress() async {
    await loadAddresses();
    return _defaultAddress;
  }

  Future<Address?> getAddressById(String addressId) async {
    await loadAddresses();
    try {
      return _addresses.firstWhere((a) => a.id == addressId);
    } catch (_) {
      return null;
    }
  }

  Future<void> addAddressObject(Address address) async {
    await addAddress(
      label: address.label,
      name: address.name,
      phone: address.phone,
      street: address.street,
      city: address.city,
      country: address.country,
      isDefault: address.isDefault,
    );
  }

  Future<void> updateAddressByIndex(int index, Address address) async {
    if (index >= 0 && index < _addresses.length) {
      await updateAddress(
        addressId: _addresses[index].id,
        label: address.label,
        name: address.name,
        phone: address.phone,
        street: address.street,
        city: address.city,
        country: address.country,
        isDefault: address.isDefault,
      );
    }
  }

  Future<void> setDefaultAddressByIndex(int index) async {
    if (index >= 0 && index < _addresses.length) {
      await setDefaultAddress(_addresses[index].id);
    }
  }

  Future<void> removeAddress(int index) async {
    if (index >= 0 && index < _addresses.length) {
      await deleteAddress(_addresses[index].id);
    }
  }

  Future<void> initialize() async {
    await loadAddresses();
  }
}
