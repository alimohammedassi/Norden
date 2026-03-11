import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  if (!dir.existsSync()) return;

  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    
    String normPath = file.path.replaceAll('\\', '/');
    String afterScreens = normPath.split('/screens/').last;
    int depth = afterScreens.split('/').length;
    
    // For files directly in lib/screens/ (depth 1), they need ../
    // For files in lib/screens/subdir/ (depth 2), they need ../../
    String prefix = '';
    for (int i = 0; i < depth; i++) prefix += '../';
    
    print('Updating imports for ${file.path} (depth: $depth, prefix: $prefix)');

    // Fix imports
    content = content.replaceAll(RegExp(r"import '[^']+providers/season_provider\.dart';"), "import '${prefix}providers/season_provider.dart';");
    content = content.replaceAll(RegExp(r"import '[^']+config/app_theme\.dart';"), "import '${prefix}config/app_theme.dart';");

    file.writeAsStringSync(content);
  }
}
