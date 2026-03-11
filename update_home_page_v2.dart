import 'dart:io';

void main() {
  final file = File('lib/screens/home_page.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll('_t', 't');
  
  file.writeAsStringSync(content);
}
