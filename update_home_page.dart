import 'dart:io';

void main() {
  final file = File('lib/screens/home_page.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll('_t.', 't.');
  content = content.replaceAll('final t = _t;', ''); // Remove this redundant assignment
  content = content.replaceAll('SeasonScope.of(context).season', 'SeasonScope.of(context).mode');
  
  // Fix _switchSeason
  content = content.replaceFirst(
    'void _switchSeason(SeasonMode mode) {\n    if (mode == _season) return;\n    HapticFeedback.mediumImpact();\n    setState(() {\n      _season = mode;\n      _catIndex = 0;\n      _currentSlide = 0;\n    });',
    'void _switchSeason(SeasonMode mode) {\n    if (mode == _season) return;\n    HapticFeedback.mediumImpact();\n    SeasonScope.read(context).switchTo(mode);\n    setState(() {\n      _catIndex = 0;\n      _currentSlide = 0;\n    });'
  );

  file.writeAsStringSync(content);
}
