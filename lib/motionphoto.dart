import 'dart:io';

import 'plugin.dart';

Plugin _plugin = Plugin();

class Motionphoto {
  static Future<String> get platformVersion async {
    return _plugin.platformVersion;
  }

  static Future<int> assetMediaSubTypes(String id) async {
    return _plugin.mediaSubTypes(id);
  }

  static Future<bool> isIOSLivePhoto(String id) async {
    final mediaType = await _plugin.mediaSubTypes(id);
    if (mediaType == -1) {
      return false;
    }
    return (mediaType & 8) != 0;
  }

  static Future<File?> getLivePhotoFile(String id) async {
    final path = await _plugin.getLivePhotoFile(id);
    if (null == path) {
      print("no live photo!! for " + id);
      return Future.value(null);
    }
    return File(path);
  }
}
