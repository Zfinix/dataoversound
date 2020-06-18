import 'dart:io';

import 'package:flutter/services.dart';

import 'Callback.dart';

class Recorder {
  static const _audioChannel =
      const MethodChannel('dataoversound');

  Callback callback;

  Recorder(this.callback);

  setCallback(Callback val) {
    callback = val;
  }

  void sethandleMethod() {
    _audioChannel.setMethodCallHandler(handleMethod);
    print('handleMethod set');
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "setBufferSize":
        return callback.setBufferSize(call.arguments);
      case "onBufferAvailable":
        return callback.onBufferAvailable(call.arguments);
    }
  }

  Future<String> start() {
    return (Platform.isAndroid)
        ? _audioChannel.invokeMethod<String>('start')
        : null;
  }

  Future<String> stop() {
    return (Platform.isAndroid)
        ? _audioChannel.invokeMethod<String>('stop')
        : null;
  }
}

/*  _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "extractTextResult":
          final String result = call.arguments;
          print(result);
      }
      var t;
      return t;
    }); */
