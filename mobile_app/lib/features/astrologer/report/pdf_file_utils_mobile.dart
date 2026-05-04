import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> savePdfBytes(List<int> bytes, String fileName) async {
  final dir = await getTemporaryDirectory();
  final path = '${dir.path}/$fileName';
  await File(path).writeAsBytes(bytes);
  return path;
}
