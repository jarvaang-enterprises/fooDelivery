import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddeliveryboiler/core/models/restaurantModel.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/home.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/views/delivery.dart';
import 'package:fooddeliveryboiler/ui/views/login.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';
import 'package:fooddeliveryboiler/ui/widgets/drawer.dart';
import 'package:fooddeliveryboiler/ui/widgets/restaurantCard.dart';
import 'package:fooddeliveryboiler/ui/widgets/spinner.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/';
  final FocusNode searchFocus = new FocusNode();
  final FocusNode telcosFocus = new FocusNode();
  final FocusNode codeFocus = new FocusNode();
  final GlobalKey<ScaffoldState> _scafflodKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    TextEditingController search = new TextEditingController();
    TextEditingController telcos = new TextEditingController();
    TextEditingController code = new TextEditingController();
    bool verified = false;
    bool mobileCheckDialog = false;
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);

    void navigationPage() {
      Route route = MaterialPageRoute(builder: (context) => LoginPage());
      Navigator.pushReplacement(context, route);
    }

    _redirect() async {
      return navigationPage;
    }

    redirectUser(context) {
      var _duration = new Duration(seconds: 3);
      return new Timer(
          _duration,
          () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => DeliveryScreen())));
    }

    mobileComplete(HomeModel model, BuildContext context) async {
      model.setViewState(ViewState.Busy);
      Network _network = model.network;
      Map<String, String> reqHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': model.user.apiKey
      };
      var response = await _network.post('/user/${model.user.uID}/tel',
          body: json.encode({'mobile': telcos.text}), headers: reqHeaders);
      if (response['success']) {
        model.user.tel = telcos.text;
        model.storage.user = model.user;
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Fluttertoast.showToast(msg: response['msg']);
      } else {
        Fluttertoast.showToast(msg: response.msg);
      }
      model.setViewState(ViewState.Idle);
    }

    verifyDialog() async {
      return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Icon(
                  Icons.warning_outlined,
                  size: 35.0,
                  color: Colors.red,
                ),
              ),
              Text(
                "Verification Code",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              height: MediaQuery.of(context).size.height / 6.5,
              width: double.infinity,
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Enter verification code",
                        textAlign: TextAlign.center,
                      ),
                      !verified
                          ? TextField(
                              controller: code,
                              focusNode: codeFocus,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                              autofocus: true,
                              minLines: 1,
                              maxLines: 1,
                              maxLength: 6,
                            )
                          : Text("Verification complete"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            !verified
                ? TextButton.icon(
                    onPressed: () {
                      if (code.text != "")
                        Navigator.of(context, rootNavigator: true).pop(true);
                      else
                        Fluttertoast.showToast(
                          msg:
                              "Please input a correct phone number with country code",
                          toastLength: Toast.LENGTH_LONG,
                          timeInSecForIos: 3,
                        );
                    },
                    icon: Icon(Icons.check),
                    label: Text("Verify"),
                  )
                : TextButton.icon(
                    onPressed: () {},
                    icon: Spinner(icon: FontAwesomeIcons.spinner),
                    label: Text("Continue"),
                  ),
          ],
        ),
      );
    }

    mobileCheck(BuildContext context, HomeModel model) async {
      Network _network = model.network;
      mobileCheckDialog = true;
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          // contentPadding: EdgeInsets.symmetric(horizontal: 1.0),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Icon(
                  Icons.warning_outlined,
                  size: 35.0,
                  color: Colors.red,
                ),
              ),
              Text(
                "Mobile Contact Missing",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              height: MediaQuery.of(context).size.height / 6.5,
              width: double.infinity,
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Please add your number to the system?",
                        textAlign: TextAlign.center,
                      ),
                      TextField(
                        controller: telcos,
                        focusNode: telcosFocus,
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                        autofocus: true,
                        minLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                if (telcos.text != "" &&
                    ((telcos.text.length == 13 &&
                        telcos.text.substring(0, 1) == '+')))
                  Navigator.of(context, rootNavigator: true).pop(true);
                else
                  Fluttertoast.showToast(
                    msg:
                        "Please input a correct phone number with country code",
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIos: 3,
                  );
              },
              icon: Icon(Icons.check),
              label: Text("Confirm"),
            ),
          ],
        ),
      ).then((value) async {
        if (value != null) {
          if (value) {
            model.setViewState(ViewState.Busy);
            await FirebaseAuth.instance.verifyPhoneNumber(
              phoneNumber: telcos.text,
              timeout: const Duration(seconds: 60),
              verificationCompleted: (PhoneAuthCredential credential) async {
                await mobileComplete(model, context);
                FirebaseAuth.instance.signOut();
                model.setViewState(ViewState.Idle);
              },
              verificationFailed: (FirebaseAuthException e) {
                model.setViewState(ViewState.Idle);
                if (e.code == 'invalid-phone-number') {
                  Fluttertoast.showToast(
                    msg:
                        "Please input a correct phone number with country code",
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIos: 3,
                  );
                  mobileCheck(context, model);
                }
              },
              codeSent: (String verificationId, int resendToken) async {
                await verifyDialog();
                PhoneAuthCredential phoneAuthCredential =
                    PhoneAuthProvider.credential(
                        verificationId: verificationId, smsCode: code.text);
                UserCredential u = await FirebaseAuth.instance
                    .signInWithCredential(phoneAuthCredential);
                FirebaseAuth.instance.signOut();
                await mobileComplete(model, context);
                model.setViewState(ViewState.Idle);
              },
              codeAutoRetrievalTimeout: (String verificationId) {},
            );
          }
        } else {
          Fluttertoast.showToast(
              msg: "You have to enter a number, \n\t Press confirm");
          mobileCheck(context, model);
        }
      }).catchError((onError) => print(onError));
    }

    return BaseView<HomeModel>(
      onModelReady: (model) {
        model.getCurrentUser();
        model.getRestaurantData();
      },
      builder: (context, model, child) {
        if (model.user != null) {
          if (!model.isSearch) {
            search.clear();
          } else {
            if (model.searchDataJson == null) {
              var snackbar = SnackBar(content: Text('Search return empty'));
              Scaffold.of(context).showSnackBar(snackbar);
            }
          }
          if (model.deliveryData == null) {
            Fluttertoast.showToast(
                msg: "No delivery data!", toastLength: Toast.LENGTH_LONG);
            // redirectUser(context);
          }
          if (model.user.tel == "" && mobileCheckDialog == false) {
            // mobileCheck(context, model);
            var _duration = new Duration(milliseconds: 500);
            Timer(_duration, () => mobileCheck(context, model));
          }
          return Scaffold(
            key: _scafflodKey,
            appBar: appBar(context, model: model, key: _scafflodKey),
            drawer: AppDrawer(
              model: model,
              name: model.modelName,
            ),
            drawerEnableOpenDragGesture: true,
            backgroundColor: Colors.white,
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
                        model.counter >= 4
                            ? Text(
                                "Taking longer than normal to load ...",
                                style: TextStyle(color: Colors.orange),
                              )
                            : Text(""),
                        model.counter >= 6
                            ? Text(
                                "Please check your internet connection!",
                                style: TextStyle(color: Colors.redAccent),
                              )
                            : Text("")
                      ],
                    ),
                  )
                : SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextField(
                            style: TextStyle(fontSize: 18),
                            onSubmitted: (String searchValue) {
                              if (searchValue != '') {
                                model.isSearch = true;
                                model.searchData(searchValue);
                              }
                            },
                            controller: search,
                            focusNode: searchFocus,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(15, 17, 15, 15),
                              suffixIcon: GestureDetector(
                                child: Icon(!model.isSearch
                                    ? FontAwesomeIcons.search
                                    : Icons.cancel),
                                onTap: () => {
                                  !model.isSearch
                                      ? {
                                          model.isSearch = true,
                                          model.searchData(search.text)
                                        }
                                      : {
                                          model.isSearch = false,
                                          model.refresh()
                                        }
                                },
                              ),
                              hintText: "Search for Restaurants, Cuisine",
                              hintStyle: TextStyle(fontSize: 18),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8.0),
                            children: [
                              for (RestaurantData data in !model.isSearch
                                  ? model.homeDataJson
                                  : model.searchDataJson)
                                restaurantCard(context, data, model),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        } else {
          _redirect();
          return Scaffold(
              backgroundColor: Colors.white,
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
      },
    );
  }
}
