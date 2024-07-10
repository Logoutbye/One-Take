
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class DirHelper {
  static Future<String> getAppPath() async {
    String mainPath = await _getMainPath();
    String appPath = "$mainPath/TikTokVideos";
    _createPathIfNotExist(appPath);
    return appPath;
  }

  static Future<String> _getMainPath() async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  static void _createPathIfNotExist(String path) {
    Directory(path).createSync(recursive: true);
  }
}

  