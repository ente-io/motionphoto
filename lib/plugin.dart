import 'dart:async';
import 'dart:ffi';
import 'dart:io';
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

  Future<int> mediaSubTypes(String id) async {
    if (Platform.isAndroid) {
      return Future.value(-1);
    }
    final params = {
      'id': id,
    };
    return await _channel.invokeMethod('mediaSubTypes', params);
  }

  Future<String?> getLivePhotoFile(String id) async {
    if (Platform.isAndroid) {
      return Future.value(null);
    }
    final params = {
      'id': id,
    };
    return _channel.invokeMethod('getLivePhotoUrl', params);
  }
}

mixin BasePlugin {
  final MethodChannel _channel = MethodChannel('io.ente/motionphoto');
}
