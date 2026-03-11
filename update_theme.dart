import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  if (!dir.existsSync()) return;

  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    
    // 0. Clean up previous mess
    content = content.replaceAll('Widget build(BuildContext context) {\\n    final t = SeasonScope.of(context).tokens;', 'Widget build(BuildContext context) {');
    content = content.replaceAll('Widget build(BuildContext context) {\n    final t = SeasonScope.of(context).tokens;', 'Widget build(BuildContext context) {');
    
    // Remove duplicate getters if they exist from previous runs
    content = content.replaceAll('\n  SeasonTokens get t => SeasonScope.of(context).tokens;\n  SeasonTokens get t => SeasonScope.of(context).tokens;', '\n  SeasonTokens get t => SeasonScope.of(context).tokens;');

    // 1. Inject getter into State classes (use replaceAllMapped to catch ALL classes)
    content = content.replaceAllMapped(
      RegExp(r'class\s+(_\w+State)\s+extends\s+State<[^>]+>\s+(?:with\s+[\w,\s]+\s+)?\{'),
      (m) => '${m.group(0)}\n  SeasonTokens get t => SeasonScope.of(context).tokens;'
    );

    // 2. Inject final t into StatelessWidget build methods
    // We already have build methods in States, but since we have a getter 't' in the class, 
    // we don't need a local 'final t' in States.
    // However, for StatelessWidgets, we MUST have it.
    // To distinguish, we can check if the class extends StatelessWidget.
    
    // Actually, to be safe and simple, let's just make sure ALL build methods have 'final t' 
    // IF the class doesn't have the getter.
    // But then 't' might be shadowed or duplicated.
    
    // Better: only inject into build() if 't' is not already defined in the class body.
    // This is hard with regex. 
    
    // Alternative: inject into ALL build methods, and if it's a State class, 
    // it will just shadow the getter, which is fine!
    content = content.replaceAllMapped(
      RegExp(r'Widget build\(BuildContext context\)\s+\{'),
      (m) {
         if (content.contains('SeasonTokens get t')) {
            // Already have getter, still fine to shadow with final t
            return '${m.group(0)}\n    final t = SeasonScope.of(context).tokens;';
         }
         return '${m.group(0)}\n    final t = SeasonScope.of(context).tokens;';
      }
    );

    // 3. Global replacements
    content = content.replaceAll('const Color(0xFF0A0A0A)', 't.bg');
    content = content.replaceAll('Color(0xFF0A0A0A)', 't.bg');
    content = content.replaceAll('const Color(0xFF1A1A1A)', 't.surface');
    content = content.replaceAll('Color(0xFF1A1A1A)', 't.surface');
    content = content.replaceAll('const Color(0xFF141414)', 't.surface2');
    content = content.replaceAll('Color(0xFF141414)', 't.surface2');
    content = content.replaceAll('const Color(0xFF0F0F0F)', 't.surface2');
    content = content.replaceAll('Color(0xFF0F0F0F)', 't.surface2');
    content = content.replaceAll('const Color(0xFFD4AF37)', 't.gold');
    content = content.replaceAll('Color(0xFFD4AF37)', 't.gold');

    // 4. Broad const removal
    final keywords = ['BoxDecoration', 'LinearGradient', 'RadialGradient', 'Icon', 'TextStyle', 'BorderSide', 'AlwaysStoppedAnimation', 'CircularProgressIndicator', 'EdgeInsets', 'Text', 'Padding', 'Center', 'Column', 'Row', 'Stack', 'Positioned', 'Container'];
    for (var kw in keywords) {
      content = content.replaceAll('const $kw(', '$kw(');
    }
    content = content.replaceAll('const [', '[');
    content = content.replaceAll('const {', '{');
    content = content.replaceAll('const <', '<');

    file.writeAsStringSync(content);
  }
}
