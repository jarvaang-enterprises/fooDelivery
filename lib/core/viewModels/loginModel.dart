// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/locator.dart';

class LoginModel extends BaseModel {
  final LocalStorage storage = locator<LocalStorage>();
  String errorMessage;

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

  // Future<Route> googleLogin() async{
  //   setViewState(ViewState.Busy);
  //   var response = await _authenticationService.googleLogin();
  //   setViewState(ViewState.Idle);

  //   Route route;

  //   if (response['success']) {
  //     // Check if the user requires onboarding, Then create route for onboarding and if not then take him to home page
  //     route = MaterialPageRoute(builder: (context) => _basicSetupServices.getStartScreen());
  //     return route;
  //   } else {
  //     errorMessage = response['message'];
  //     // print(errorMessage);
  //     return route;
  //   }

  // }

  // Future<Route> loginUsingEmail(String email, String password) async {
  //   setViewState(ViewState.Busy);
  //   var response =  await _authenticationService.loginUsingEmail(email, password);
  //   setViewState(ViewState.Idle);

  //   Route route;

  //   if (response['success']) {
  //     // Check if the user requires onboarding, Then create route for onboarding and if not then take him to home page
  //     route = MaterialPageRoute(builder: (context) => _basicSetupServices.getStartScreen());
  //     return route;
  //   } else {
  //     errorMessage = response['message'];
  //     // print(errorMessage);
  //     return route;
  //   }
  // }

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
