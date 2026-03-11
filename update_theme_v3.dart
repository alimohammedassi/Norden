import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  if (!dir.existsSync()) return;

  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    
    // 1. Strip all previous injections to start fresh
    // Remove both the getter and the local variable
    content = content.replaceAll(RegExp(r'\n\s*SeasonTokens get t => SeasonScope\.of\(context\)\.tokens;'), '');
    content = content.replaceAll(RegExp(r'\s*final t = SeasonScope\.of\(context\)\.tokens;'), '');
    
    // Fix literal \n injected by previous run
    content = content.replaceAll('\\n', '\n');

    // 2. Class-by-class injection
    final classRegex = RegExp(r'(class\s+(\w+)\s+(?:extends|implements)\s+[\w<>\s,]+)\{');
    final matches = classRegex.allMatches(content).toList();
    
    if (matches.isNotEmpty) {
      String newContent = '';
      int lastEnd = 0;

      for (int i = 0; i < matches.length; i++) {
          final match = matches[i];
          final classHead = match.group(1)!;
          final className = match.group(2)!;
          
          int classEnd = (i + 1 < matches.length) ? matches[i+1].start : content.length;
          String classBody = content.substring(match.end, classEnd);
          
          if (className.startsWith('_') && className.endsWith('State')) {
               classBody = '\n  SeasonTokens get t => SeasonScope.of(context).tokens;' + classBody;
          } else if (classHead.contains('StatelessWidget') || classBody.contains('Widget build(BuildContext context)')) {
               classBody = classBody.replaceAllMapped(
                  RegExp(r'Widget build\(BuildContext context\)\s+\{'),
                  (m) => '${m.group(0)}\n    final t = SeasonScope.of(context).tokens;'
               );
          }
          
          newContent += content.substring(lastEnd, match.start) + classHead + '{' + classBody;
          lastEnd = classEnd;
      }
      newContent += content.substring(lastEnd);
      content = newContent;
    }

    // 3. Const removal
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
