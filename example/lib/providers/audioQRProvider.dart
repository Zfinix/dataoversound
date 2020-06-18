import 'dart:convert';
import 'dart:typed_data';

import 'package:dataoversound/dataoversound.dart';
import 'package:dataoversound_example/model/user.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioQRProvider extends ChangeNotifier {
  AnimationController controller;
  Animation<Offset> offsetFloat;

  bool isSending = false;

  //Is listening flag
  bool _isListening = false;
  bool get isListening => _isListening;

  //Is listening and receiving flag
  bool _isReceiving = false;
  bool get isReceiving => _isReceiving;

  String sendButtonText = 'SEND';
  String listenButtonText = 'LISTEN';

  BufferSoundTask _sendTask;
  BufferSoundTask get sendTask => _sendTask;

  RecordTask _listenTask;
  RecordTask get listenTask => _listenTask;

  List<Message> _messageList = [];
  List<Message> get messageList => _messageList;

  final TextEditingController msg = new TextEditingController();

  set isListening(bool val) {
    _isListening = val;
    notifyListeners();
  }

  set isReceiving(bool val) {
    _isReceiving = val;
    notifyListeners();
  }

  set sendTask(BufferSoundTask val) {
    _sendTask = val;
    notifyListeners();
  }

  set listenTask(RecordTask val) {
    _listenTask = val;
    notifyListeners();
  }

  set messageList(List<Message> val) {
    _messageList = val;
    notifyListeners();
  }

  void sendMessage(CallbackSendRec callback) async {
    var message = msg.text;
    isSending = true;
    _sendTask = BufferSoundTask();
    notifyListeners();

    if (message != null && message.isNotEmpty)
      try {
        Uint8List byteText = utf8.encode(message);

        notifyListeners();
        _sendTask.setCallbackSR(callback);
        _sendTask.setBuffer(byteText);
        await _sendTask.execute();

        //controller.forward();
        notifyListeners();
      } catch (e) {
        print(e.toString());
      }
  }

  //Called to start listening task and update GUI to listening
  void listen(CallbackSendRec callbackSendRec) {
    try {
      _listenTask = new RecordTask();
      _isListening = true;
      listenButtonText = 'STOP';
      notifyListeners();
      notifyListeners();

      _listenTask.setCallbackRet(callbackSendRec);
      _listenTask.execute();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  //Called on listen button click
  Future<void> listenMessage(CallbackSendRec callbackSendRec) async {
    //If sending task is active, stop it and update GUI
    if (isSending) {
      stopSending();
      if (_sendTask != null) {
        _sendTask.setWorkFalse();
      }
    }
    //If its not listening check for mic permission and start listening
    if (!_isListening) {
      if (await Permission.microphone.request().isGranted) {
        listen(callbackSendRec);
      } else {
        await [
          Permission.microphone,
          Permission.storage,
        ].request();

        if (await Permission.microphone.request().isGranted) {
          listenMessage(callbackSendRec);
        }
      }
    }

    //If its already listening, stop listening and update GUI
    else {
      if (_listenTask != null) {
        _listenTask.setWorkFalse();
      }
      stopListening();
    }
    notifyListeners();
  }

  void stopListening() {
    if (_isReceiving) {
      _messageList.removeAt(0);

      _isReceiving = false;
      notifyListeners();
    }
    listenButtonText = 'LISTEN';
    _isListening = false;
    notifyListeners();
  }

  void stopSending() {
    sendButtonText = 'SEND';
    isSending = false;
    notifyListeners();
  }

  @override
  void dispose() {
    if (listenTask != null) {
      stopListening();
      _listenTask.setWorkFalse();
    }
    if (sendTask != null) {
      stopSending();
      _sendTask.setWorkFalse();
    }
    super.dispose();
  }

  void actionDone(int srFlag, String message) {
    print(CallbackSendRec.SEND_ACTION == srFlag);
    print(isSending);
    //If its sending task and activity is still in sending mode
    if (CallbackSendRec.SEND_ACTION == srFlag && isSending) {
      //Update GUI to initial state
      _messageList.insert(0, new Message(message: msg.text, user: 0, userID: 0));
      stopSending();
      //IF text was not changed while sending, clear it
      msg.text = "";
      //Update messages view and refresh it
      notifyListeners();
    } else {
      //If its receiving task and activity is still in receiving mode
      if (CallbackSendRec.RECEIVE_ACTION == srFlag && _isListening) {
        //Update GUI to initial state
        stopListening();
        //If received message exists put it in database and show it on view
        if (message != null && message.isNotEmpty) {
          _messageList.insert(0, Message(message: message, user: 1, userID: 1));
          notifyListeners();
        }
      }
    }
  }

  void receivingSomething() {
    //Update view and flag to show that something is receiving
    _messageList.insert(
        0,
        new Message(
            message: "Receiving message...", user: 1, isBold: true, userID: 1));
    _isReceiving = true;
    notifyListeners();
  }
}
