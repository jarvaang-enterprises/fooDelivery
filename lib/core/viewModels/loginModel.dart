import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fooddeliveryboiler/core/models/deliveryModel.dart';
import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/locator.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginModel extends BaseModel {
  Network _network = locator<Network>();
  String modelName = "loginModel";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalStorage storage = locator<LocalStorage>();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'email',
    'profile',
  ]);
  User _cUser;
  UserData _lUser;
  StreamSubscription<User> _listener;
  bool logout = false;

  /// Holds true if user doesn't exist in localDatabase
  bool newUser = false;

  /// Holds true if user has delivery details?
  bool delDetails = false;

  User get currentUser {
    setModelName(this.modelName);
    setStorage(storage);
    return _cUser;
  }

  UserData get localUser {
    UserData l = storage.user ?? null;
    return l;
  }

  set currentUser(User currentUser) {
    _cUser = currentUser;
  }

  set localUser(UserData currentUser) {
    _lUser = currentUser;
  }

  String _errorMessage;

  String get errorMessage => _errorMessage;

  set errorMessage(String errorMessage) {
    setViewState(ViewState.Busy);
    _errorMessage = errorMessage;
    setViewState(ViewState.Idle);
  }

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
      if (!logout) {
        UserData _userData = storage.user;
        localUser = _userData;
      }
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
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

        final User user = (await _auth.signInWithCredential(credential)).user;

        currentUser = user;
        setViewState(ViewState.Idle);
        var iu = await _isUser(user);
        // currentUser = user;
        // setViewState(ViewState.Idle);

        if (user != null && iu['success']) {
          print(iu);
          currentUser = user;
          // Check if the user requires onboarding, Then create route for onboarding and if not then take him to home page
          // route = MaterialPageRoute(
          //     builder: (context) => _basicSetupServices.getStartScreen());
          // return route;
          setViewState(ViewState.Idle);
        } else {
          localUser = UserData();
          // currentUser = user;
          newUser = true;
        }
      }
    } catch (exc) {
      if (exc is PlatformException) {
        this.errorMessage = "Check your internet Connection";
      } else {
        this.errorMessage = exc.toString();
      }
    }
    setViewState(ViewState.Idle);
    notifyListeners();
  }

  Future<dynamic> _isUser(User user) async {
    Map<String, String> reqHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'x-app-key': utf8.fuse(base64).encode("pleasedon'tcopyortranspose(c)(r)")
    };
    var response =
        await _network.post('/user/' + user.email, headers: reqHeaders);
    return response;
  }

  void signOut() async {
    // setViewState(ViewState.Busy);
    logout = true;
    await _googleSignIn.signOut();
    await _auth.signOut();
    storage.saveStringToDisk('user', null);
    storage.saveStringToDisk('DeliveryData', null);
    storage.saveGetStartedToDisk('notFirstTime', false);
    logout = false;
    setViewState(ViewState.Idle);
  }

  void loginUsingEmail(String email, String password) async {
    setViewState(ViewState.Busy);
    var data = {'email': email, 'passwd': password};
    var response = await _network.post('/auth', body: data);

    if (response['errors'] == null && response['success']) {
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

        /// Check whether user has delivery details setup
        var delDet = await _network.get('/user/' + user.uID + '/delDetails',
            apiKey: user.apiKey);
        if (delDet['success']) {
          delDetails = true;
          DeliveryData dData = DeliveryData.fromJson(delDet['data']);
          storage.delivery = dData;
        }
        errorMessage = null;
      }
    } else {
      errorMessage = response['errors'].join(', ');
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
