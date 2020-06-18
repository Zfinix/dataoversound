import 'dart:io';
import 'dart:typed_data';

import 'AudioFormat.dart';

const int RECORDER_BPP = 16;
const String AUDIO_RECORDER_TEMP_FOLDER = "AudioRecorder";
const int RECORDER_SAMPLERATE = 44100;
const int RECORDER_CHANNELS = AudioFormat.CHANNEL_IN_MONO;
const int RECORDER_AUDIO_ENCODING = AudioFormat.ENCODING_PCM_16BIT;
int sampleRate = 44100;

Future<String> copyWaveFile(List<int> byteData, String filePath) async {
  File outPutFile;
  int totalAudioLen = 0;
  int totalDataLen = totalAudioLen + 36;
  int longSampleRate = RECORDER_SAMPLERATE;
  int channels = 1;
  int byteRate = RECORDER_BPP * RECORDER_SAMPLERATE * channels ~/ 8;

  try {
    outPutFile = new File(filePath);
    totalAudioLen = byteData.length;
    totalDataLen = totalAudioLen + 36;

    writeWaveFileHeader(outPutFile, totalAudioLen, totalDataLen, longSampleRate,
        channels, byteRate);

    //print('--------------------------------------------------------->');
    var p = outPutFile.writeAsBytes(Uint8List.fromList(byteData),
        mode: FileMode.append, flush: true);
  //  print("WRITE: ${(await p).readAsBytesSync().lengthInBytes}");
  //  print('--------------------------------------------------------->');

    return outPutFile.uri.toString();
  } catch (e) {
    print(e.toString());
    return null;
  }
}

void writeWaveFileHeader(File outPutFile, int totalAudioLen, int totalDataLen,
    int longSampleRate, int channels, int byteRate) {
  var header = List<int>(44);

  header[0] = 'R'.codeUnits[0]; // RIFF/WAVE header
  header[1] = 'I'.codeUnits[0];
  header[2] = 'F'.codeUnits[0];
  header[3] = 'F'.codeUnits[0];
  header[4] = (totalDataLen & 0xff);
  header[5] = ((totalDataLen >> 8) & 0xff);
  header[6] = ((totalDataLen >> 16) & 0xff);
  header[7] = ((totalDataLen >> 24) & 0xff);
  header[8] = 'W'.codeUnits[0];
  header[9] = 'A'.codeUnits[0];
  header[10] = 'V'.codeUnits[0];
  header[11] = 'E'.codeUnits[0];
  header[12] = 'f'.codeUnits[0]; // 'fmt ' chunk
  header[13] = 'm'.codeUnits[0];
  header[14] = 't'.codeUnits[0];
  header[15] = ' '.codeUnits[0];
  header[16] = 16; // 4 bytes: size of 'fmt ' chunk
  header[17] = 0;
  header[18] = 0;
  header[19] = 0;
  header[20] = 1; // format = 1
  header[21] = 0;
  header[22] = channels;
  header[23] = 0;
  header[24] = (longSampleRate & 0xff);
  header[25] = ((longSampleRate >> 8) & 0xff);
  header[26] = ((longSampleRate >> 16) & 0xff);
  header[27] = ((longSampleRate >> 24) & 0xff);
  header[28] = (byteRate & 0xff);
  header[29] = ((byteRate >> 8) & 0xff);
  header[30] = ((byteRate >> 16) & 0xff);
  header[31] = ((byteRate >> 24) & 0xff);
  header[32] = (((RECORDER_CHANNELS == AudioFormat.CHANNEL_IN_MONO) ? 1 : 2) *
      16 ~/
      8); // block align
  header[33] = 0;
  header[34] = RECORDER_BPP; // bits per sample
  header[35] = 0;
  header[36] = 'd'.codeUnits[0];
  header[37] = 'a'.codeUnits[0];
  header[38] = 't'.codeUnits[0];
  header[39] = 'a'.codeUnits[0];
  header[40] = (totalAudioLen & 0xff);
  header[41] = ((totalAudioLen >> 8) & 0xff);
  header[42] = ((totalAudioLen >> 16) & 0xff);
  header[43] = ((totalAudioLen >> 24) & 0xff);

  outPutFile.writeAsBytesSync(header, mode: FileMode.append, flush: true);
}
