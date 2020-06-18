import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'RIFF/RIFF.dart';

class AudioTrack {
  // static AudioPlayer audioPlugin = AudioPlayer();
  static const _channel = const MethodChannel("dataoversound");
  static List<List<int>> soundList = [];
  static List<File> soundFiles = [];

  static Future<String> registerAudio() {
    return (Platform.isAndroid)
        ? _channel.invokeMethod<String>('registerAudio')
        : null;
  }

  static Future<String> releaseTone() {
    return (Platform.isAndroid)
        ? _channel.invokeMethod<String>('releaseTone')
        : null;
  }

  static addTone({
    @required Uint8List generatedSnd,
  }) {
    soundList.add(generatedSnd);
  }

  static Future<String> writeIOS() async {
    try {
      Directory tempDir = await getLibraryDirectory();

      print(tempDir);

      for (var i = 0; i < soundList.length; i++) {
        var mp3Uri =
            await copyWaveFile(soundList[i], '${tempDir.path}/demo$i.wav');

        if (mp3Uri != null) soundFiles.add(File('${tempDir.path}/demo$i.wav'));
      }

      for (var i = 0; i < soundFiles.length; i++) {
        await playTone(wavFile: 'demo$i.wav');
        await Future.delayed(Duration(milliseconds: 270));
      }

      if (soundFiles.length > 0)
        for (var i = 0; i < soundFiles.length; i++) {
          await soundFiles[i].delete();
          print('--------------------------------------------------------->');
          print("DELETED");
          print('--------------------------------------------------------->');
        }
      clear();

      return "";
    } catch (e) {
      print(e.toString());
      return "";
    } finally {}
    // */return _channel.invokeMethod<String>('playTone', mapData);
  }

  static void clear() {
    soundList = [];
    soundFiles = [];
  }

  static Future<String> writeAndroid({
    @required Uint8List generatedSnd,
  }) async {
    var mapData = Map<dynamic, dynamic>();
    mapData["generatedSnd"] = generatedSnd;

    return _channel.invokeMethod<String>('playTone', mapData);
  }

  static Future<String> playTone({
    @required String wavFile,
  }) async {
    var mapData = Map<dynamic, dynamic>();
    mapData["wavFile"] = wavFile;
    return _channel.invokeMethod<String>('playTone', mapData);
  }
}
