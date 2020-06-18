import 'package:dataoversound/dataoversound.dart';
import 'package:dataoversound_example/providers/audioQRProvider.dart';
import 'package:dataoversound_example/utils/margin.dart';
import 'package:dataoversound_example/widgets/messageWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements CallbackSendRec {
  AudioQRProvider provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AudioQRProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Data over Sound",
          style: TextStyle(
            color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: screenWidth(context),
        height: screenHeight(context),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                reverse: true,
                children: <Widget>[
                  for (var messageItem in provider.messageList)
                    MessageWidget(message: messageItem),
                ],
              ),
            ),
            const YMargin(20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.grey[400].withOpacity(0.1),
                    offset: Offset(0, 13),
                    blurRadius: 30)
              ]),
              child: Row(
                children: <Widget>[
                  const XMargin(10),
                  Container(
                    width: screenWidth(context, percent: 0.43),
                    child: TextField(
                        decoration: InputDecoration.collapsed(
                            hintText: 'Enter your message'),
                        controller: provider.msg,
                        autofocus: false),
                  ),
                  Container(
                    height: 50,
                    child: FlatButton(
                      onPressed: () {
                        provider.sendMessage(this);
                      },
                      color: Colors.white,
                      textColor: Colors.black,
                      child: Text(provider.sendButtonText),
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: 50,
                    child: IconButton(
                      onPressed: () {
                        provider.listenMessage(this);                    
                      },
                      color:
                          provider.isListening ? Colors.grey : Colors.redAccent,
                      icon: Icon(Icons.mic),
                    ),
                  ),
                  const XMargin(10),
                ],
              ),
            ),
            const YMargin(30)
          ],
        ),
      ),
    );
  }

  @override
  void actionDone(int srFlag, String message) =>
      provider.actionDone(srFlag, message);

  @override
  void receivingSomething() => provider.receivingSomething();
}
