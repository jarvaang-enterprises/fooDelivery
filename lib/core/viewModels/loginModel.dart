// import 'dart:js';

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/locator.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginModel extends BaseModel {
  Network _network = locator<Network>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'email',
    'profile',
  ]);
  User _cUser;
  UserData _lUser;
  StreamSubscription<User> _listener;
  bool newUser = false;

  User get currentUser => _cUser;
  UserData get localUser => _lUser;

  set currentUser(User currentUser) {
    _cUser = currentUser;
  }

  set localUser(UserData currentUser) {
    _lUser = currentUser;
  }

  final LocalStorage storage = locator<LocalStorage>();
  String errorMessage;

  void checkCurrentUser() async {
    setViewState(ViewState.Busy);
    currentUser = _auth.currentUser;
    if (currentUser != null) {
      currentUser?.getIdToken();
      setViewState(ViewState.Idle);

      _listener = _auth.userChanges().listen((User user) {
        currentUser = user;
      });
    } else {
      UserData _userData = storage.user;
      localUser = _userData;
      setViewState(ViewState.Idle);
    }

    notifyListeners();
  }

  void cancelListener() {
    setViewState(ViewState.Busy);
    _listener.cancel();
    setViewState(ViewState.Idle);
  }

  // Future<dynamic> facebookLogin() async {
  //   setViewState(ViewState.Busy);
  //   var response = await _auth.facebookLogin();
  //   setViewState(ViewState.Idle);

  //   Route route;

  //   if (response['success']) {
  //     route = MaterialPageRoute(
  //         builder: (context) => _basicSetupServices.getStartScreen());
  //     return route;
  //   } else {
  //     errorMessage = response['message'];
  //     return route;
  //   }
  // }

  void signInWithGoogle() async {
    setViewState(ViewState.Busy);
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

      final User user = (await _auth.signInWithCredential(credential)).user;
      print(user);
      var iu = await _isUser(user);
      Route route;

      if (user != null && iu['success']) {
        print(iu);
        // Check if the user requires onboarding, Then create route for onboarding and if not then take him to home page
        // route = MaterialPageRoute(
        //     builder: (context) => _basicSetupServices.getStartScreen());
        // return route;
      } else {
        localUser = UserData();
        newUser = true;
      }
    }
    setViewState(ViewState.Idle);
    notifyListeners();
  }

  Future<dynamic> _isUser(User user) async {
    var response = await _network.post('/user/' + user.email);
    print(response);
    return response;
  }

  void signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  void loginUsingEmail(String email, String password) async {
    setViewState(ViewState.Busy);
    var data = {'email': email, 'passwd': password};
    var response = await _network.post('/auth', body: data);

    if (response['success']) {
      // Check if the user requires onboarding, Then create route for onboarding and if not then take him to home page
      var res = await _network.get('/users/' + response['accessId'],
          apiKey: response['accessToken'], bearer: 'wearegoingtorockthis');
      if (res['success']) {
        res['data']['accessToken'] = response['accessToken'];
        res['data']['displayName'] =
            res['data']['firstName'] + ' ' + res['data']['lastName'];
        res['data']['accessId'] = response['accessId'];
        UserData user = UserData.fromJson(res['data']);
        localUser = user;
        storage.user = user;
        newUser = false;
        errorMessage = null;
      }
    } else {
      errorMessage = response['errors'].join(', ');
      print(errorMessage);
    }
    notifyListeners();
  }

  // Future<Route> signupUsingEmail(String name, String email, String password) async{
  //   setViewState(ViewState.Busy);
  //   var response =  await _authenticationService.signupUsingEmail(name, email, password);
  //   setViewState(ViewState.Idle);

  //   Route route;

  //   if (response['success']) {
  //     // Check if the user requires onboarding, Then create route for onboarding and if not then take him to home page
  //     route = MaterialPageRoute(builder: (context) => _basicSetupServices.getStartScreen());
  //     return route;
  //   }else{
  //     errorMessage = response['message'];
  //     // print(errorMessage);
  //     return route;
  //   }

  // }
}
