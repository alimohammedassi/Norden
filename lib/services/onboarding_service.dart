import 'package:flutter/foundation.dart';
import '../models/onboarding_page.dart';
import '../config/api_config.dart';
import 'api_service.dart';

/// Fetches onboarding pages from the backend with offline fallback.
class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  Future<List<OnboardingPage>> getPages() async {
    try {
      final response = await ApiService.get(
        ApiConfig.onboardingEndpoint,
      ).timeout(const Duration(seconds: 8));

      final raw = response['data'] ?? response['pages'] ?? response;
      if (raw is List && raw.isNotEmpty) {
        final pages = raw
            .map((e) => OnboardingPage.fromJson(e as Map<String, dynamic>))
            .toList();
        pages.sort((a, b) => a.order.compareTo(b.order));
        return pages;
      }
      return OnboardingPage.fallback;
    } catch (e) {
      debugPrint('OnboardingService.getPages error: $e — using fallback');
      return OnboardingPage.fallback;
    }
  }
}
