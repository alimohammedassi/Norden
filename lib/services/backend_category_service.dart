import 'package:flutter/foundation.dart';
import '../models/category.dart' as cat_model;
import '../config/api_config.dart';
import 'api_service.dart';

/// Category service — fetches categories from backend with local fallback
class BackendCategoryService {
  static final BackendCategoryService _instance =
      BackendCategoryService._internal();
  factory BackendCategoryService() => _instance;
  BackendCategoryService._internal();

  /// Get all categories, optionally filtered by season slug
  Future<List<cat_model.Category>> getCategories({String? season}) async {
    try {
      final queryParams = <String, String>{};
      if (season != null && season != 'all') {
        queryParams['season'] = season;
      }

      final uri = Uri.parse(
        ApiConfig.categoriesEndpoint,
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await ApiService.get(uri.toString());
      final rawData = response['data'] ?? response;
      if (rawData is List) {
        return rawData
            .map(
              (json) =>
                  cat_model.Category.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return cat_model.Category.fallbackCategories;
    } catch (e) {
      debugPrint(
        'BackendCategoryService.getCategories error: $e — using fallback',
      );
      return cat_model.Category.fallbackCategories;
    }
  }

  /// Get category names as strings (convenience method for UI)
  Future<List<String>> getCategoryNames({String? season}) async {
    final cats = await getCategories(season: season);
    return cats.map((c) => c.name).toList();
  }
}
