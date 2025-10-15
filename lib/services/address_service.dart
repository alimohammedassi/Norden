import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to manage user addresses
class AddressService extends ChangeNotifier {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _addresses = [];
  List<Map<String, dynamic>> get addresses => _addresses;

  /// Get default address
  Map<String, dynamic>? get defaultAddress {
    if (_addresses.isEmpty) return null;

    try {
      return _addresses.firstWhere(
        (addr) => addr['isDefault'] == true,
        orElse: () => _addresses.first,
      );
    } catch (e) {
      debugPrint('Error getting default address: $e');
      return null;
    }
  }

  /// Load addresses from Firestore
  Future<void> loadAddresses() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('addresses').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['addresses'] != null) {
          _addresses = List<Map<String, dynamic>>.from(
            data['addresses'] as List,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    }
  }

  /// Save addresses to Firestore
  Future<void> _saveAddresses() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('addresses').doc(user.uid).set({
        'addresses': _addresses,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving addresses: $e');
    }
  }

  /// Add new address
  Future<void> addAddress(Map<String, dynamic> address) async {
    // If this is the first address, make it default
    if (_addresses.isEmpty) {
      address['isDefault'] = true;
    }

    _addresses.add(address);
    await _saveAddresses();
  }

  /// Update address
  Future<void> updateAddress(int index, Map<String, dynamic> address) async {
    if (index >= 0 && index < _addresses.length) {
      _addresses[index] = address;
      await _saveAddresses();
    }
  }

  /// Remove address
  Future<void> removeAddress(int index) async {
    if (index >= 0 && index < _addresses.length) {
      final wasDefault = _addresses[index]['isDefault'] == true;
      _addresses.removeAt(index);

      // If we removed the default address, make the first one default
      if (wasDefault && _addresses.isNotEmpty) {
        _addresses[0]['isDefault'] = true;
      }

      await _saveAddresses();
    }
  }

  /// Set default address
  Future<void> setDefaultAddress(int index) async {
    if (index >= 0 && index < _addresses.length) {
      // Remove default from all
      for (var addr in _addresses) {
        addr['isDefault'] = false;
      }
      // Set new default
      _addresses[index]['isDefault'] = true;
      await _saveAddresses();
    }
  }

  /// Clear all addresses
  Future<void> clearAddresses() async {
    _addresses.clear();
    await _saveAddresses();
  }

  /// Clear local state (for sign out)
  void clearLocalState() {
    _addresses.clear();
    notifyListeners();
  }
}
