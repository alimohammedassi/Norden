import 'package:flutter/foundation.dart';
import '../models/season.dart' as season_model;
import '../config/api_config.dart';
import 'api_service.dart';

/// Season service — fetches seasons from backend with local fallback
class BackendSeasonService {
  static final BackendSeasonService _instance =
      BackendSeasonService._internal();
  factory BackendSeasonService() => _instance;
  BackendSeasonService._internal();

  Future<List<season_model.Season>> getSeasons() async {
    try {
      final response = await ApiService.get(ApiConfig.seasonsEndpoint);
      final rawData = response['data'] ?? response;
      if (rawData is List) {
        return rawData
            .map(
              (json) =>
                  season_model.Season.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return season_model.Season.fallbackSeasons;
    } catch (e) {
      debugPrint('BackendSeasonService.getSeasons error: $e — using fallback');
      return season_model.Season.fallbackSeasons;
    }
  }
}
