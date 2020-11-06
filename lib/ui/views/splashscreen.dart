import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/locator.dart';
import 'package:fooddeliveryboiler/ui/views/login.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _init = false;
  bool _error = false;
  LocalStorage _storage = locator<LocalStorage>();

  final Color logoGreen = Color(0xff25bcbb);

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      try {
        // await http.get("https://www.example.com");
        await http.get("http://10.0.2.2:5500/api/v1");
      } catch (err) {
        print(err);
        setState(() {
          _error = true;
        });
      }
      setState(() {
        _init = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        _error = true;
      });
    }
  }

  startTime() async {
    var _duration = new Duration(seconds: 5);
    return new Timer(_duration, initializeFlutterFire);
  }

  void navigationPage() {
    Route route = MaterialPageRoute(builder: (context) => LoginPage());
    Navigator.pushReplacement(context, route);
  }

  @override
  void initState() {
    startTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_init && !_error) {
      return Scaffold(
        body: Container(
          height: double.infinity,
          width: double.maxFinite,
          child: Image(
            fit: BoxFit.fill,
            image: AssetImage('assets/splash/splash_test.png'),
          ),
        ),
      );
    } else {
      return Scaffold(
        // backgroundColor: Color.fromRGBO(225, 225, 220, 1),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //We take the image from the assets
            Image.asset(
              'assets/icons/marsLogo.png',
              height: 230,
            ),
            SizedBox(
              height: 20,
            ),
            //Texts and Styling of them
            Text(
              'Welcome!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 28),
            ),
            SizedBox(height: 20),
            Text(
              'A one-stop cafe for all your food needs',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            SizedBox(
              height: 30,
            ),
            _error
                ? Icon(
                    Icons.error,
                    size: 35.0,
                    color: Colors.red,
                  )
                : Container(),
            SizedBox(
              height: _error ? 10 : 0,
            ),
            _error
                ? Text(
                    "Please check your internet connection",
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.red,
                    ),
                  )
                : Container(),
            SizedBox(
              height: _error ? 30 : 0,
            ),
            //Our MaterialButton which when pressed will take us to a new screen named as
            //LoginScreen Only displayed if network is connected
            !_error && _init
                ? MaterialButton(
                    elevation: 0,
                    height: 50,
                    onPressed: () {
                      if (_storage.getFromDisk('notFirstTime') == true) {
                        Route route = MaterialPageRoute(
                            builder: (context) => LoginPage());
                        Navigator.pushReplacement(context, route);
                      } else {
                        _storage.saveGetStartedToDisk('notFirstTime', true);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => LoginPage()));
                      }
                    },
                    color: logoGreen,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            _storage.getFromDisk('notFirstTime') == true
                                ? 'Continue'
                                : 'Get Started',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(CupertinoIcons.forward)
                      ],
                    ),
                    textColor: Colors.white,
                  )
                : MaterialButton(
                    elevation: 0,
                    height: 50,
                    onPressed: () {
                      setState(() {
                        _init = false;
                        _error = false;
                      });
                      startTime();
                    },
                    color: Colors.amberAccent.shade700,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Retry',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          CupertinoIcons.restart,
                          color: Colors.green,
                        )
                      ],
                    ),
                    textColor: Colors.white,
                  )
          ],
        ),
      );
    }
  }
}
