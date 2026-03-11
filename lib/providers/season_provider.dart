import 'package:flutter/material.dart';
import '../models/season.dart';
import '../config/app_theme.dart';

/// Global season/theme state — NORDEN Maison de Luxe
///
/// Wrap your widget tree with [SeasonScope] to make [SeasonProvider]
/// available to all descendants. Use [SeasonProvider.of(context)] or
/// the [SeasonConsumer] widget to read the current season.
class SeasonProvider extends ChangeNotifier {
  SeasonMode _mode = SeasonMode.winter;

  SeasonMode get mode => _mode;
  SeasonTokens get tokens => AppTheme.of(_mode);

  bool get isWinter => _mode == SeasonMode.winter;
  bool get isSummer => _mode == SeasonMode.summer;

  /// Season-appropriate product categories
  List<String> get categories => isWinter ? _winterCategories : _summerCategories;

  static const _winterCategories = [
    'All',
    'Coats',
    'Suits',
    'Blazers',
    'Dress Shirts',
    'Trousers',
    'Knitwear',
    'Accessories',
  ];

  static const _summerCategories = [
    'All',
    'T-Shirts',
    'Shirts',
    'Shorts',
    'Linen Trousers',
    'Polo',
    'Swimwear',
    'Accessories',
  ];

  void switchTo(SeasonMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void toggleSeason() {
    _mode = _mode == SeasonMode.winter ? SeasonMode.summer : SeasonMode.winter;
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────
//  InheritedWidget to expose SeasonProvider down the tree
// ─────────────────────────────────────────────────────────
class SeasonScope extends InheritedNotifier<SeasonProvider> {
  const SeasonScope({
    super.key,
    required SeasonProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static SeasonProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SeasonScope>();
    assert(scope != null, 'No SeasonScope found in context');
    return scope!.notifier!;
  }

  /// Read without subscribing (useful in callbacks)
  static SeasonProvider read(BuildContext context) {
    final scope = context.findAncestorWidgetOfExactType<SeasonScope>();
    assert(scope != null, 'No SeasonScope found in context');
    return scope!.notifier!;
  }
}

/// Convenience builder — rebuilds whenever season changes
class SeasonConsumer extends StatelessWidget {
  final Widget Function(BuildContext context, SeasonProvider season) builder;

  const SeasonConsumer({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final season = SeasonScope.of(context);
    return builder(context, season);
  }
}
