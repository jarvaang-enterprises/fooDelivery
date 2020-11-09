import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/loginModel.dart';
import 'package:fooddeliveryboiler/locator.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/views/home.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {
  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);

  final Color logoGreen = Color(0xff2f9f1b);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  final Network _network = locator<Network>();

  @override
  Widget build(BuildContext context) {
    return BaseView<LoginModel>(onModelReady: (model) {
      if (model.logout == true)
        Timer(Duration(seconds: 1), () => model.checkCurrentUser());
      else
        model.checkCurrentUser();
    }, builder: (context, model, child) {
      if ((model.localUser == null)) {
        if (model.currentUser == null) {
          return Scaffold(
            key: _key,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            backgroundColor: primaryColor,
            body: model.state == ViewState.Busy
                ? Center(
                    heightFactor: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SpinKitChasingDots(
                          size: 30,
                          duration: new Duration(milliseconds: 800),
                          color: Color(0xfffd5f00),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  )
                : SafeArea(
                    child: Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Sign in to Mars Cafe Delivery',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.openSans(
                                  color: Colors.white, fontSize: 28),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Enter your email and password below to continue to Mars Cafe Delivery and let the food hunt begin!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.openSans(
                                  color: Colors.white, fontSize: 14),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            model.errorMessage != null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        model.errorMessage ?? '',
                                        style:
                                            TextStyle(color: Colors.redAccent),
                                      ),
                                    ],
                                  )
                                : Container(
                                    width: 0,
                                    height: 0,
                                  ),
                            SizedBox(
                              height: 20,
                            ),
                            _buildTextField(nameController,
                                FontAwesomeIcons.user, 'Email Address'),
                            SizedBox(
                              height: 20,
                            ),
                            _buildTextField(passwordController,
                                FontAwesomeIcons.lock, "Password",
                                enc: true),
                            SizedBox(
                              height: 30,
                            ),
                            MaterialButton(
                              elevation: 0,
                              minWidth: double.maxFinite,
                              height: 50,
                              onPressed: () {
                                var userN = nameController.text.trim();
                                var passW = passwordController.text.trim();
                                if (userN == '' || passW == '') {
                                  model.errorMessage =
                                      "Fill in the login details";
                                } else
                                  model.loginUsingEmail(userN, passW);
                              },
                              color: logoGreen,
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              textColor: Colors.white,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            MaterialButton(
                              elevation: 0,
                              minWidth: double.maxFinite,
                              height: 50,
                              onPressed: () {
                                // model.signInWithGoogle();
                                _key.currentState.showSnackBar(SnackBar(
                                    content: Text(
                                        "Sign Up Screen not implemented")));
                              },
                              color: Colors.orangeAccent.shade700,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(FontAwesomeIcons.google),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              textColor: Colors.white,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            MaterialButton(
                              elevation: 0,
                              minWidth: double.maxFinite,
                              height: 50,
                              onPressed: () {
                                model.signInWithGoogle();
                              },
                              color: Colors.blue,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.google),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Sign-in using Google',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              textColor: Colors.white,
                            ),
                            SizedBox(
                              height: 60,
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: _buildFooterLogo(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        } else {
          if (model.newUser) {
            _initializeUser(model, context: context);
            return Scaffold(
                key: _key,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                backgroundColor: primaryColor,
                body: model.state == ViewState.Busy
                    ? Center(
                        heightFactor: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SpinKitChasingDots(
                              size: 30,
                              duration: new Duration(milliseconds: 800),
                              color: Color(0xfffd5f00),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Text(model.errorMessage,
                                style: GoogleFonts.openSansCondensed(
                                    fontSize: 20.0))
                          ],
                        ),
                      )
                    : null);
          } else {
            if (model.currentUser != null) {
              _localLogin(model, context: context);
            }
          }
          return Container();
        }
      } else {
        if (model.newUser) {
          _initializeUser(model, context: context);
          return Scaffold(
              key: _key,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              backgroundColor: primaryColor,
              body: model.state == ViewState.Busy
                  ? Center(
                      heightFactor: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SpinKitChasingDots(
                            size: 30,
                            duration: new Duration(milliseconds: 800),
                            color: Color(0xfffd5f00),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Text(model.errorMessage,
                              style:
                                  GoogleFonts.openSansCondensed(fontSize: 20.0))
                        ],
                      ),
                    )
                  : null);
        } else {
          if (model.currentUser != null) {
            _localLogin(model, context: context);
          } else {
            if (model.localUser != null) {
              redirectUser(context);
            }
            return Scaffold(
                key: _key,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                backgroundColor: Colors.white70,
                body: Center(
                  heightFactor: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SpinKitChasingDots(
                        size: 30,
                        duration: new Duration(milliseconds: 800),
                        color: Color(0xfffd5f00),
                      ),
                    ],
                  ),
                ));
          }
        }
        return Container();
      }
    });
  }

  redirectUser(context) {
    var _duration = new Duration(seconds: 3);
    return new Timer(
        _duration,
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen())));
  }

  _localLogin(LoginModel model, {BuildContext context}) async {
    if (model.currentUser != null) {
      User user = model.currentUser;
      var data = {'email': user.email, 'passwd': user.uid};
      var res = await _network.post('/auth', body: data);
      if (res['success']) {
        // model.errorMessage =
        //     "Getting required authentication parameters.\nPlease wait ... (Step 3 of 3)";
        var resp = await _network.get('/users/' + res['accessId'],
            apiKey: res['accessToken']);
        if (resp['success']) {
          // model.errorMessage =
          //     "Finalizing user setup.\nPlease wait ... (Step 3 of 3)";
          var loginData = {
            'accessId': res['accessId'],
            'displayName': user.displayName,
            'email': user.email,
            'permissionLevel': resp['data']['permissionLevel'],
            'otherPermissionLevel': resp['data']['otherPermissionLevel'],
            'photoUrl': user.photoURL,
            'accessToken': res['accessToken']
          };

          UserData userData = new UserData.fromJson(loginData);
          model.storage.user = userData;
          Route route = MaterialPageRoute(builder: (context) => HomeScreen());
          Timer(Duration(seconds: 1),
              () => {Navigator.pushReplacement(context, route)});
        }
      } else {
        print(res);
      }
    } else {
      print(model.localUser);
      redirectUser(context);
    }
  }

  _buildFooterLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          FontAwesomeIcons.copyright,
          color: Colors.white,
        ),
        SizedBox(
          width: 10,
        ),
        Text('Jarvaang Enterprises, 2020',
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  _buildTextField(
      TextEditingController controller, IconData icon, String labelText,
      {bool enc = false}) {
    bool visible = false;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: secondaryColor,
          border: Border.all(color: Colors.blue),
        ),
        child: TextField(
          autocorrect: false,
          obscureText: !visible ? enc : false,
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.white),
            icon: Icon(
              icon,
              color: Colors.white,
            ),
            border: InputBorder.none,
            // suffixIcon: GestureDetector(
            //   onTap: () => setState!visible,
            //   child: Icon(enc
            //       ? !visible ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash
            //       : null),
            // ),
          ),
        ));
  }

  _initializeUser(LoginModel model, {BuildContext context}) async {
    User user = model.currentUser;
    model.errorMessage =
        "Setting up user for first time use.\nPlease wait ... (Step 1 of 3)";
    var d = (user.displayName.split(' ').length / 2) + .5;
    var fN, lN;
    if (d >= 2) {
      fN = user.displayName.trim().split(' ')[0] +
          ' ' +
          user.displayName.trim().split(' ')[1];
      lN = user.displayName.trim().split(' ').sublist(2).join(' ');
    } else {
      fN = user.displayName.trim().split(' ')[0];
      lN = user.displayName.trim().split(' ')[1];
    }
    var uData = {
      'email': user.email,
      'passwd': user.uid,
      'firstName': fN,
      'lastName': lN
    };
    var response = await _network.post('/users', body: uData);
    if (response['success']) {
      model.errorMessage =
          "Setting up user for first time use.\nPlease wait ... (Step 2 of 3)";
      var data = {'email': user.email, 'passwd': user.uid};
      var res = await _network.post('/auth', body: data);
      print(res);
      if (res['success']) {
        model.errorMessage =
            "Getting required authentication parameters.\nPlease wait ... (Step 3 of 3)";
        var resp = await _network.get('/users/' + res['accessId'],
            apiKey: res['accessToken'], bearer: 'wearegoingtorockit');
        if (resp['success']) {
          model.errorMessage =
              "Finalizing user setup.\nPlease wait ... (Step 3 of 3)";
          var loginData = {
            'accessId': res["accessId"],
            'displayName': user.displayName,
            'email': user.email,
            'permissionLevel': resp["data"]["permissionLevel"],
            'otherPermissionLevel': resp["data"]["otherPermissionLevel"],
            'photoUrl': user.photoURL,
            'accessToken': res["accessToken"]
          };

          UserData userData = new UserData.fromJson(loginData);
          model.storage.user = userData;
          Route route = MaterialPageRoute(builder: (context) => HomeScreen());
          Navigator.pushReplacement(context, route);
        }
      }
    }
  }
}
