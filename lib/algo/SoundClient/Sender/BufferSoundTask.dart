import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import '../BitFrequencyConverter.dart';
import '../CallbackSendRec.dart';
import '../audioTrack.dart';

class BufferSoundTask {
  //Work flag
  bool work = true;
  //Play time of one tone (can play on 0.18, optimal on 0.20, best on 0.27)
  double durationSec = 0.270;
  //Number of samples input 1s
  int sampleRate = 44100;
  //Object for playing tones

  //If chat text of message, if data name of file
  List<int> message;
  //If chat null, if data context of file
  List<int> messageFile;
  //Progress bar for publishing sent progress
  var progressBar;
  //Callback for activity to know sending is done
  CallbackSendRec callbackSR;

  /* static String DEF_START_FREQUENCY= "17500";
     static String DEF_END_FREQUENCY= "20000";
     static String DEF_BIT_PER_TONE="4";
     static bool DEF_ENCODING=false;
     static bool DEF_ERROR_DETECTION=false;
     static String DEF_ERROR_BYTE_NUM="4";
 */

  Future<bool> execute() async {
    AudioTrack.clear();
    //Load settings parameters
    int startFreq = 17500;
    int endFreq = 20000;
    int bitsPerTone = 4;
    int encoding = 0;
    int errorDet = 0;
    int errorDetBNum = 4;
    //Create bit to frequency converter
    BitFrequencyConverter bitConverter = new BitFrequencyConverter(
      endFreq: endFreq,
      numberOfBits: bitsPerTone,
      startFreq: startFreq,
    );
    List<int> encodedMessage = message;
    List<int> encodedMessageFile = messageFile;
    //If encoding is on

    //If error detection is on
    /*  if(errorDet==1){
            //Cut byte arrays to size of 256-NumberOfErrorBytes because ReedSolomons works only
            //input chunks of 256B
            ByteArrayParser bParser=new ByteArrayParser();
            List<Uint8List> tempList= bParser.divideInto256Chunks(encodedMessage, errorDetBNum);
            EncoderDecoder encoder = new EncoderDecoder();
            //Encode byte arrays with Reed Solomon
            for(int i=0; i<tempList.size(); i++){
                try {
                    byte[] tempArr = encoder.encodeData(tempList.get(i), errorDetBNum);
                    bParser.mergeArray(tempArr);
                } catch (EncoderDecoder.DataTooLargeException e) {
                    e.printStackTrace();
                    return null;
                }
            }
            //Merge encoded chunks
            encodedMessage=bParser.getAndResetOutputByteArray();
            //If file is send, do same for data of file
            if(encodedMessageFile!=null){
                tempList= bParser.divideInto256Chunks(encodedMessageFile, errorDetBNum);
                encoder = new EncoderDecoder();

                for(int i=0; i<tempList.size(); i++){
                    try {
                        byte[] tempArr = encoder.encodeData(tempList.get(i), errorDetBNum);
                        bParser.mergeArray(tempArr);
                    } catch (EncoderDecoder.DataTooLargeException e) {
                        e.printStackTrace();
                        return null;
                    }
                }
                encodedMessageFile=bParser.getAndResetOutputByteArray();
            }
        }
 */
    if (encodedMessage == null) {
      return null;
    }

    List<int> freqs = bitConverter.calculateFrequency(encodedMessage);

    List<int> freqsFile;
    if (encodedMessageFile != null) {
      freqsFile = bitConverter.calculateFrequency(encodedMessageFile);
    }
    if (!work) {
      return null;
    }
    //Create object for playing tones
    /*     int bufferSize = AudioTrack.getMinBufferSize(sampleRate, AudioFormat.CHANNEL_OUT_MONO, AudioFormat.ENCODING_PCM_16BIT);
        myTone = new AudioTrack(AudioManager.STREAM_MUSIC,
                sampleRate, AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT, bufferSize,
                AudioTrack.MODE_STREAM);
        myTone.play(); */

    await AudioTrack.registerAudio();

    //Calculate number of tones to be played
    int currProgress = 0;
    int allLength = freqs.length * 2 + 4;
    if (freqsFile != null) {
      allLength += freqsFile.length * 2 + 4;
    }
    //Start communication with start handshake
    await playTone(
        bitConverter.getHandshakeStartFreq().ceilToDouble(), durationSec);
    progressBar = (((++currProgress) * 100) / allLength);
    await playTone(
        bitConverter.getHandshakeStartFreq().ceilToDouble(), durationSec);
    progressBar = (((++currProgress) * 100) / allLength);
    //Transfer message if chat and file extension if data
    for (int freq in freqs) {
      //playTone(freq,durationSec);
      await playTone(freq.ceilToDouble(), durationSec / 2);
      progressBar = (((++currProgress) * 100) / allLength);
      await playTone(
          bitConverter.getHandshakeStartFreq().ceilToDouble(), durationSec);
      progressBar = (((++currProgress) * 100) / allLength);
      if (!work) {
        await AudioTrack.releaseTone();
        return null;
      }
    }
    //End communication with end handshake
    await playTone(
        bitConverter.getHandshakeEndFreq().ceilToDouble(), durationSec);
    progressBar = (((++currProgress) * 100) / allLength);
    await playTone(
        bitConverter.getHandshakeEndFreq().ceilToDouble(), durationSec);
    progressBar = (((++currProgress) * 100) / allLength);
    //If file is being send, send file data too
    if (freqsFile != null) {
      await playTone(
          bitConverter.getHandshakeStartFreq().ceilToDouble(), durationSec);
      progressBar = (((++currProgress) * 100) / allLength);
      await playTone(
          bitConverter.getHandshakeStartFreq().ceilToDouble(), durationSec);
      progressBar = (((++currProgress) * 100) / allLength);
      for (int freq in freqsFile) {
        //playTone(freq,durationSec);
        await playTone(freq.ceilToDouble(), durationSec / 2);
        progressBar = (((++currProgress) * 100) / allLength);
        await playTone(
            bitConverter.getHandshakeStartFreq().ceilToDouble(), durationSec);
        progressBar = (((++currProgress) * 100) / allLength);
        if (!work) {
          await AudioTrack.releaseTone();
          return null;
        }
      }
      await playTone(
          bitConverter.getHandshakeEndFreq().ceilToDouble(), durationSec);
      progressBar = (((++currProgress) * 100) / allLength);
      await playTone(
          bitConverter.getHandshakeEndFreq().ceilToDouble(), durationSec);
      progressBar = (((++currProgress) * 100) / allLength);
    }

    if (Platform.isIOS || Platform.isMacOS) await AudioTrack.writeIOS();
    callbackSR.actionDone(CallbackSendRec.SEND_ACTION, null);
    return true;
  }

  //On update refresh progress bar to current state

  //After task finishes to inform callback activity
  /*  @Override
    protected void onPostExecute(Void aVoid) {
        super.onPostExecute(aVoid);
        if(callbackSR!=null) {
            
        }
    }
 */
  //Called to play tone of specific frequency for specific duration
  Future<void> playTone(double freqOfTone, double duration) async {
    try {
      //Calculate number of samples input given duration
      double dnumSamples = duration * sampleRate;

      int numSamples = dnumSamples.ceil();
      List<double> sample = [];
      //Every sample 16bit
      Uint16List generatedSnd = Uint16List(2 * numSamples);

      //Fill the sample array with sin of given frequency
      double anglePadding = (freqOfTone * 2 * math.pi) / (sampleRate);
      double angleCurrent = 0;

      for (int i = 0; i < numSamples; ++i) {
        sample.add(math.sin(angleCurrent));
        angleCurrent += anglePadding;
      }

      //Convert to 16 bit pcm (pulse code modulation) sound array
      //assumes the sample buffer is normalized.
      int idx = 0;
      int i = 0;
      //Amplitude ramp as a percent of sample count
      int ramp = numSamples ~/ 20;
      //Ramp amplitude up (to avoid clicks)
      for (i = 0; i < ramp; ++i) {
        double dVal = sample[i];

        //Ramp up to maximum
        final int val = ((dVal * 32767 * i ~/ ramp));

        //In 16 bit wav PCM, first byte is the low order byte
        generatedSnd[idx++] = (val & 0x00ff);
        generatedSnd[idx++] = ((val & 0xff00) >> 8);
      }

      // Max amplitude for most of the samples
      for (i = i; i < numSamples - ramp; ++i) {
        double dVal = sample[i];
        //Scale to maximum amplitude
        final int val = (dVal * 32767).ceil();
        //In 16 bit wav PCM, first byte is the low order byte
        generatedSnd[idx++] = (val & 0x00ff);
        generatedSnd[idx++] = ((val & 0xff00) >> 8);
      }
      //Ramp amplitude down

      for (i = i; i < numSamples; ++i) {
        double dVal = sample[i];
        //Ramp down to zero
        final int val = ((dVal * 32767 * (numSamples - i) ~/ ramp));
        //In 16 bit wav PCM, first byte is the low order byte
        generatedSnd[idx++] = (val & 0x00ff);
        generatedSnd[idx++] = ((val & 0xff00) >> 8);
      }

      if (Platform.isIOS || Platform.isMacOS)
        await AudioTrack.addTone(
            generatedSnd: Uint8List.fromList(regression(generatedSnd)));
      else
        await AudioTrack.writeAndroid(
            generatedSnd: Uint8List.fromList(regression(generatedSnd)));
      // myTone.write(generatedSnd, 0, generatedSnd.length);
    } catch (e) {
      print(e.toString());
    }
  }

  void setBuffer(List<int> message) => this.message = message;

  void setFileBuffer(List<int> messageFile) => this.messageFile = messageFile;

  CallbackSendRec getCallbackSR() => callbackSR;

  void setCallbackSR(CallbackSendRec callback) => this.callbackSR = callback;

  bool isWork() => work;

  void setWorkFalse() => this.work = false;
}

List<int> regression(Uint16List generatedSnd) {
  List<int> regressionList = [];
  try {
    for (var item in generatedSnd) {
      if (item > 127) {
        regressionList.add(item - 256);
      } else {
        regressionList.add(item);
      }
    }
    return regressionList;
  } catch (e) {
    print(e.toString());
    return null;
  }
}
