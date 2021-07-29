import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class Plugin with BasePlugin {
  static final Plugin _plugin = Plugin._();

  factory Plugin() => _plugin;

  Plugin._();

  Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

mixin BasePlugin {
  final MethodChannel _channel = MethodChannel('io.ente/motionphoto');
}
