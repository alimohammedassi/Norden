import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  if (!dir.existsSync()) return;

  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    
    // Split by class definition to handle each class separately
    final classRegex = RegExp(r'(class\s+(\w+)\s+(?:extends|implements)\s+[\w<>\s,]+)\{');
    final matches = classRegex.allMatches(content).toList();
    
    if (matches.isEmpty) continue;

    String newContent = '';
    int lastEnd = 0;

    for (int i = 0; i < matches.length; i++) {
        final match = matches[i];
        final classHead = match.group(1)!;
        final className = match.group(2)!;
        
        // Find end of this class
        int classEnd = (i + 1 < matches.length) ? matches[i+1].start : content.length;
        String classBody = content.substring(match.end, classEnd);
        
        // If it's a State class, use a getter. If it's a StatelessWidget, use a local in build.
        if (className.startsWith('_') && className.endsWith('State')) {
            // Remove local 't' from build
            classBody = classBody.replaceAll('    final t = SeasonScope.of(context).tokens;', '');
            // Ensure getter 't' is present
            if (!classBody.contains('SeasonTokens get t')) {
                classBody = '\n  SeasonTokens get t => SeasonScope.of(context).tokens;' + classBody;
            }
        } else if (classHead.contains('StatelessWidget')) {
            // Remove getter 't' if accidentally added
            classBody = classBody.replaceAll('SeasonTokens get t => SeasonScope.of(context).tokens;', '');
            // Ensure local 't' in build
            if (!classBody.contains('final t = SeasonScope.of(context).tokens;')) {
                classBody = classBody.replaceAllMapped(
                    RegExp(r'Widget build\(BuildContext context\)\s+\{'),
                    (m) => '${m.group(0)}\n    final t = SeasonScope.of(context).tokens;'
                );
            }
        } else {
            // For other classes like CustomPainter, they might need 't' passed in.
            // We'll handle them manually or if they have a build method with context.
            if (classBody.contains('Widget build(BuildContext context)')) {
                 if (!classBody.contains('final t = SeasonScope.of(context).tokens;')) {
                    classBody = classBody.replaceAllMapped(
                        RegExp(r'Widget build\(BuildContext context\)\s+\{'),
                        (m) => '${m.group(0)}\n    final t = SeasonScope.of(context).tokens;'
                    );
                }
            }
        }
        
        newContent += content.substring(lastEnd, match.start) + classHead + '{' + classBody;
        lastEnd = classEnd;
    }
    
    newContent += content.substring(lastEnd);
    file.writeAsStringSync(newContent);
  }
}
