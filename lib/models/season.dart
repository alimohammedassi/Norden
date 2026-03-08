/// Season model — NORDEN Maison de Luxe
import 'package:flutter/material.dart';

enum SeasonMode { winter, summer }

class Season {
  final String id;
  final String name;
  final String slug; // "winter" | "summer"
  final String description;
  final String bannerImageUrl;
  final Color accentColor;

  const Season({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.bannerImageUrl,
    required this.accentColor,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? 'winter',
      description: json['description'] ?? '',
      bannerImageUrl: json['bannerImageUrl'] ?? '',
      accentColor: json['accentColor'] != null
          ? Color(int.parse(json['accentColor'].replaceFirst('#', '0xFF')))
          : const Color(0xFFD4AF37),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'description': description,
    'bannerImageUrl': bannerImageUrl,
    'accentColor':
        '#${accentColor.value.toRadixString(16).substring(2).toUpperCase()}',
  };

  /// Offline fallback seasons
  static List<Season> get fallbackSeasons => [
    const Season(
      id: 'winter',
      name: 'Winter Collection',
      slug: 'winter',
      description: 'Deep luxury for the cold season',
      bannerImageUrl: 'assets/images/Slim_Fit_Wool-blend_coat_Image_2_of_6.jpg',
      accentColor: Color(0xFFD4AF37),
    ),
    const Season(
      id: 'summer',
      name: 'Summer Collection',
      slug: 'summer',
      description: 'Light elegance for warm days',
      bannerImageUrl: 'assets/images/Single-breasted_blazer (1).jpg',
      accentColor: Color(0xFFD4A85A),
    ),
  ];
}
