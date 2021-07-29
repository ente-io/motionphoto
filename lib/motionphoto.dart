import 'dart:ffi';
import 'dart:io';

import 'plugin.dart';

Plugin _plugin = Plugin();

class Motionphoto {
  static Future<String?> get platformVersion async {
    return _plugin.platformVersion;
  }

  static Future<int> assetMediaSubTypes(String id) async {
    return _plugin.mediaSubTypes(id);
  }

  static Future<File?> getLivePhotoFile(String id) async {
    final path = await _plugin.getLivePhotoFile(id);
    if (path == null) {
      return null;
    }
    return File(path);
  }
}
