import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fooddeliveryboiler/ui/views/home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var _duration = new Duration(seconds: 5);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Route route = MaterialPageRoute(builder: (context) => HomeScreen());
    Navigator.push(context, route);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        child: Image(
          fit: BoxFit.fill,
          image: AssetImage('assets/splash/splash.png'),
        ),
      ),
    );
  }
}
