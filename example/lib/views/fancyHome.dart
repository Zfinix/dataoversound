
import 'package:dataoversound/dataoversound.dart';
import 'package:dataoversound_example/providers/audioQRProvider.dart';
import 'package:dataoversound_example/utils/margin.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class FancyHome extends StatefulWidget {
  FancyHome({Key key}) : super(key: key);

  @override
  _FancyHomeState createState() => _FancyHomeState();
}

class _FancyHomeState extends State<FancyHome>
    with SingleTickerProviderStateMixin
    implements CallbackSendRec {
  int duration = 2000;
  AudioQRProvider provider;
  double width = 300;

  @override
  void actionDone(int srFlag, String message) =>
      provider.actionDone(srFlag, message);

  @override
  void dispose() {
    var prov = Provider.of<AudioQRProvider>(context, listen: false);
    prov.controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    var prov = Provider.of<AudioQRProvider>(context, listen: false);

    //controller.repeat(min:0,max:29,period:Duration(seconds:2 ));

    prov.controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    prov.offsetFloat = Tween(begin: Offset(0, 100), end: Offset.zero).animate(
      CurvedAnimation(
        parent: prov.controller,
        curve: Curves.decelerate,
      ),
    );

    prov.offsetFloat.addListener(() {
     
      if (prov.offsetFloat.value == Offset(0, 0)) {
        prov.isSending = false;
        setState(() {
          width = 100;
        });
      } else  {
        setState(() {
          width = 250;
        });
      }
    });

   // prov.controller.forward();
  }

  @override
  void receivingSomething() => provider.receivingSomething();

  hold() async {
    setState(() {
      duration = 1000;
      width = 166;
    });
  }

  release() async {
    setState(() {
      width = 100;
    });
    duration = 2000;
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AudioQRProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const YMargin(70),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedContainer(
                curve: Curves.easeInOutCubic,
                width: width,
                duration: Duration(milliseconds: duration),
                child: GestureDetector(
                  onLongPress: () {
                    hold();
                  },
                  onLongPressEnd: (n) {
                    release();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1600),
                    child: Image.asset(
                      "assets/images/sound.gif",
                    ),
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          SlideTransition(
              position: provider.offsetFloat,
              child: CustomTextWidget(
                provider: provider,
                onTap: () {
                  provider.controller.reverse();
                  FocusScope.of(context).requestFocus(new FocusNode());
                  provider.sendMessage(this);
                  //remove focus
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => provider.msg.clear());
                },
              )),
          const YMargin(30)
        ],
      ),
    );
  }
}

class CustomTextWidget extends StatelessWidget {
  const CustomTextWidget({
    Key key,
    @required this.provider,
    @required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;
  final AudioQRProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      height: 55,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Colors.deepOrange.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: screenWidth(context, percent: 0.6),
                child: TextField(
                    style: GoogleFonts.notoSans(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w100,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(bottom: 5),
                        hintStyle: GoogleFonts.notoSans(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w100,
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        hintText: 'Enter your message',
                        border: InputBorder.none),
                    controller: provider.msg,
                    autofocus: false),
              ),
              Spacer(),
              Container(
                height: 50,
                child: InkResponse(
                  onTap: onTap,
                  child: Icon(
                    LineIcons.arrow_right,
                    color: Colors.red,
                    size: 20,
                  ),
                  splashColor: Colors.red,
                  hoverColor: Color(0xff2539d3).withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
