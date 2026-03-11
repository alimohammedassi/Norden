/// Onboarding page model — NORDEN Maison de Luxe
class OnboardingPage {
  final String id;
  final String headline;
  final String description;
  final String imageUrl;
  final int order;

  const OnboardingPage({
    required this.id,
    required this.headline,
    required this.description,
    required this.imageUrl,
    required this.order,
  });

  factory OnboardingPage.fromJson(Map<String, dynamic> json) {
    return OnboardingPage(
      id: json['id']?.toString() ?? '',
      headline: json['headline'] ?? json['title'] ?? '',
      description: json['description'] ?? json['subtitle'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'] ?? json['bannerImage'] ?? '',
      order: (json['order'] ?? json['sortOrder'] ?? 0) as int,
    );
  }

  /// Fallback pages shown when backend is unavailable
  static List<OnboardingPage> get fallback => const [
    OnboardingPage(
      id: 'ob1',
      headline: 'Welcome to Norden',
      description:
          'Discover timeless luxury fashion crafted for the discerning gentleman.',
      imageUrl: '',
      order: 1,
    ),
    OnboardingPage(
      id: 'ob2',
      headline: 'Curated for Gentlemen',
      description:
          'Premium clothing made with extraordinary precision and elegance.',
      imageUrl: '',
      order: 2,
    ),
  ];
}
