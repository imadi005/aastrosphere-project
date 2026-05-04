import 'package:open_filex/open_filex.dart';

class WebUtils {
  static Future<void> openFile(String path) async {
    await OpenFilex.open(path);
  }
}
