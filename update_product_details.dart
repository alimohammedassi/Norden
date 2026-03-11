import 'dart:io';

void main() {
  final file = File('lib/screens/product_details.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll('const Color(0xFFD4AF37)', 't.gold');
  content = content.replaceAll('Color(0xFFD4AF37)', 't.gold');
  content = content.replaceAll('const Color(0xFF1A1A1A)', 't.surface');
  content = content.replaceAll('Color(0xFF1A1A1A)', 't.surface');
  content = content.replaceAll('const Color(0xFF0A0A0A)', 't.bg');
  content = content.replaceAll('Color(0xFF0A0A0A)', 't.bg');
  content = content.replaceAll('const LinearGradient', 'LinearGradient');
  
  file.writeAsStringSync(content);
}
