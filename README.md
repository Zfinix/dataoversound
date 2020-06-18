# Data Over Sound

A new flutter plugin with native rappers that attempts to prove data transfer over sound by means of Frequency modulation (shifting frequency tones).
The concept of transferring data over sound is not new and there are many different approaches to handle this. https://chirp.io offered these services and were very great at it. But earlier this year they announced that they would no longer be offering such services hence my drive to crack this so-called tech block.

This project is highly experimental hence lots of bugs and such the goal here is to bring it to the community to bring it up to standard. There are three parts of this plugin: Native android wrapper, Native iOS, and macOS implementations and the dart bridge that connects them as a single dart package.

## Current Features

To integrate your plugin follow these steps:

1. Kindly add `dataoversound` package or run the `example` project.

2. implement **CallbackSendRec** in your class.

```dart
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements CallbackSendRec {

@override
  Widget build(BuildContext context) {...
   
 @override
   void actionDone(int srFlag, String message)...

 @override
    void receivingSomething()...
```
3. Make request
 ```dart
 ...
 sendMessage(this)
 ...
 void sendMessage(CallbackSendRec callback) async {
 
    var message = ""your message;
    var _sendTask = BufferSoundTask();
     
     try {
        //Convert String to Uint8List
        Uint8List byteText = utf8.encode(message);
        
        //Set Callback
       _sendTask.setCallbackSR(callback);
       
       //Set buffer text
        _sendTask.setBuffer(byteText);
        
        //Execute Request
        await _sendTask.execute();
        
      } catch (e) {
        print(e.toString());
      }
  }
 ```
## To be done
- Fix Pending Sound Receiving bugs on android.
- Implement Sound Receiving in swift for both ios and macos.
- Properly stucture the plugin.

## Issues and feedback

Plugin issues that can be filed here by creating an issue.

To contribute a change to this plugin,
and send a [pull request](https://github.com/zfinix/dataoversound/pulls).
