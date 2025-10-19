/// Address model for API compatibility
class Address {
  final String id;
  final String label;
  final String name;
  final String phone;
  final String street;
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? placeId;
  final String? formattedAddress;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.street,
    required this.city,
    required this.country,
    this.latitude,
    this.longitude,
    this.placeId,
    this.formattedAddress,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Address to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'name': name,
      'phone': phone,
      'street': street,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'placeId': placeId,
      'formattedAddress': formattedAddress,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create Address from API JSON response
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      placeId: json['placeId'],
      formattedAddress: json['formattedAddress'],
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert Address to Map (for backward compatibility)
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// Create Address from Map (for backward compatibility)
  factory Address.fromMap(Map<String, dynamic> map, String id) {
    return Address.fromJson(map);
  }

  /// Create a copy with updated values
  Address copyWith({
    String? id,
    String? label,
    String? name,
    String? phone,
    String? street,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? placeId,
    String? formattedAddress,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get full address as string
  String get fullAddress => '$street, $city, $country';
}
