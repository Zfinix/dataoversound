import 'package:dataoversound/algo/FFT/Complex.dart';
import 'package:dataoversound/algo/FFT/FFT.dart';

import '../BitFrequencyConverter.dart';
import '../CallbackSendRec.dart';
import 'Callback.dart';
import 'ChunkElement.dart';
import 'dart:convert' show utf8;

import 'Recorder.dart';

class RecordTask implements Callback {
  BitFrequencyConverter bitConverter;
  final int bitPerTone = 4;
  //Size of recorded samples
  int bufferSizeInBytes = 0;

  //Callback (father) activity where message is passed after recording
  CallbackSendRec callbackRet;

  //Counter used to know when to end receiving
  int endCounter = 0;

  final int endFrequency = 20000;
  //If data is being sent, this is name of directory where file should be saved
  String fileName;

  int listeningStarted = 0;
  //Received message (after recording)
  String myString = "";

  List<int> namePartBArray;
  //List of samples that need to be calculated
  List<ChunkElement> recordedArray = [];

  //Semaphore for "producer consumer synchronization" around recordedArray
  final String recordedArraySem = "Semaphore";

  //Recorder task used for recording samples
  //Recorder recorder=null;
  Recorder recorder;

  //Counter used to know when to start receiving
  int startCounter = 0;

  final int startFrequency = 17500;
  //Working task flag
  bool work = true;


  execute() async {
    //Load passed settings arguments

    recordedArray = [];
    bitConverter = new BitFrequencyConverter(
        startFreq: startFrequency,
        endFreq: endFrequency,
        numberOfBits: bitPerTone);

    //Create recorder and start it
    recorder = new Recorder(this);
    recorder.sethandleMethod();
    recorder.setCallback(this);

    await recorder.start();

    //Convert received frequencies to bytes

    return null;
  }

  void loadSynchronize() {
    //Load chanel synchronization parameters
    int halfPadd = bitConverter.getPadding() ~/ 2;
    int handshakeStart = bitConverter.getHandshakeStartFreq();
    int handshakeEnd = bitConverter.getHandshakeEndFreq();
    //Flag used for start of receiving

    //Used if file is being received for name part of file

    //Flag used to know if data has been received before last synchronization bit
    int lastInfo = 2;
    while (work) {
      //Wait and get recorded data
      ChunkElement tempElem;
      while (recordedArray.isEmpty) {
        return;
      }

      tempElem = recordedArray.removeAt(0);

      //Calculate frequency from recorded data
      double currNum = calculate(
          tempElem.getBuffer(), startFrequency, endFrequency, halfPadd);
      
      //Check if listening started
      if (listeningStarted == 0) {
        //If listening didn't started and frequency is in range of StartHandshakeFrequency
        if ((currNum > (handshakeStart - halfPadd)) &&
            (currNum < (handshakeStart + halfPadd))) {
          startCounter++;
          //If there were two StartHandshakeFrequency one after another start recording
          if (startCounter >= 2) {
            listeningStarted = 1;
            //Used to tell callback that receiving started
            onProgressUpdate();
          }
        } else {
          //If its not StartHandshakeFrequency reset counter
          startCounter = 0;
        }
      }
      //If listening started
      else {
        //Check if its StartHandshakeFrequency (used as synchronization bit) after receiving
        //starts
        if ((currNum > (handshakeStart - halfPadd)) &&
            (currNum < (handshakeStart + halfPadd))) {
          //Reset flag for received data
          lastInfo = 2;
          //Reset end counter
          endCounter = 0;
        } else {
          //Check if its EndHandshakeFrequency
          if (currNum > (handshakeEnd - halfPadd)) {
            endCounter++;
            //If there were two EndHandshakeFrequency one after another stop recording if
            //chat message is expected fileName==null or if its data transfer and only name
            //has been received, reset counters and flags and start receiving file data.
            if (endCounter >= 2) {
              if (fileName != null && namePartBArray == null) {
                namePartBArray = bitConverter.getAndResetReadBytes();
                listeningStarted = 0;
                startCounter = 0;
                endCounter = 0;
              } else {
                setWorkFalse();
              }
            }
          } else {
            //Reset end counter
            endCounter = 0;
            //Check if data has been received before last synchronization bit
            if (lastInfo != 0) {
              //Set flag
              lastInfo = 0;
              //Add frequency to received frequencies
              bitConverter.calculateBits(currNum);
            }
          }
        }
      }
    }
  }

  //Called for calculating frequency with highest amplitude from sound sample
  double calculate(
      List<int> buffer, int startFrequency, int endFrequency, int halfPad) {
    int analyzedSize = 1024;
    List<Complex> fftTempArray1 = List<Complex>(analyzedSize);
    int tempI = -1;
    //Convert sound sample from byte to Complex array
    for (int i = 0; i < analyzedSize * 2; i += 2) {
      int buff = buffer[i + 1];
      int buff2 = buffer[i];
      buff = ((buff & 0xFF) << 8);
      buff2 = (buff2 & 0xFF);
      var tempShort = (buff | buff2);
      tempI++;
      fftTempArray1[tempI] = new Complex(tempShort.ceilToDouble(), 0);
    }
    //Do fast fourier transform
    final List<Complex> fftArray1 = FFT.fft(fftTempArray1);
    //Calculate position in array where analyzing should start and end

    int startIndex1 = ((startFrequency - halfPad) * (analyzedSize)) ~/ 44100;
    int endIndex1 = ((endFrequency + halfPad) * (analyzedSize)) ~/ 44100;

    int maxIndex1 = startIndex1;
    double maxMagnitude1 = fftArray1[maxIndex1].abs();
    double tempMagnitude;
    //Find position of frequency with highest amplitude

    for (int i = startIndex1; i < endIndex1; ++i) {
      tempMagnitude = fftArray1[i].abs();
      if (tempMagnitude > maxMagnitude1) {
        maxMagnitude1 = tempMagnitude;
        maxIndex1 = i;
      }
    }
    return 44100 * maxIndex1 / (analyzedSize);
  }

  //Called to inform callback activity that receiving finished

  //Called to inform callback activity that receiving started
  void onProgressUpdate() {
    if (callbackRet != null) {
      callbackRet.receivingSomething();
    }
  }

  //Called from recorder activity to put new samples

  void onBufferAvailable(List<int> buffer) async {
    loadSynchronize();

    recordedArray.add(new ChunkElement(buffer));
    print(buffer.length);

    while (recordedArray.length > 100) {
      try {
       // print(recordedArray.length);
      } catch (e) {
        print(e.toString());
      }
    }
  }

  //Called to turn off task
  void setWorkFalse() {
    if (recorder != null) {
      recorder.stop();
      recorder = null;
      List<int> readBytes = bitConverter.getAndResetReadBytes();
      myString = utf8.decode(readBytes);
      print(myString);
      print(readBytes);
      try {
        //If error check is on

        //If encoding is on

        if (namePartBArray == null) {
          //If its chat communication set message as return string
          myString = utf8.decode(readBytes);
        }
      } catch (e) {
        print(e.toString());
      }

      callbackRet.actionDone(CallbackSendRec.RECEIVE_ACTION, myString);
    }
    this.work = false;
  }

  void setBufferSize(int size) => bufferSizeInBytes = size;

  CallbackSendRec getCallbackRet() => callbackRet;

  void setCallbackRet(CallbackSendRec val) => callbackRet = val;

  void setFileName(String val) => fileName = val;
}
