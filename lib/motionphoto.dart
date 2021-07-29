import 'plugin.dart';

Plugin _plugin = Plugin();

class Motionphoto {
  static Future<String?> get platformVersion async {
    return _plugin.platformVersion;
  }
}
