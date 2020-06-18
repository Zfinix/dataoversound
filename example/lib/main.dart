import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/providerRegistrar.dart';
import 'views/fancyHome.dart';
import 'views/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: registerProviders,
      child: MaterialApp(
        title: 'DOS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
           textTheme: GoogleFonts.latoTextTheme(
            Theme.of(context).textTheme,
          ),
        
          primarySwatch: Colors.red,
          primaryColor: Colors.red[800],
        ),
        home: HomePage(),
      ),
    );
  }
}
