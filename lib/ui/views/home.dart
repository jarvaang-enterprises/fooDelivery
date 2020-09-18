import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddeliveryboiler/core/models/restaurantModel.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/home.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/views/delivery.dart';
import 'package:fooddeliveryboiler/ui/views/login.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';
import 'package:fooddeliveryboiler/ui/widgets/drawer.dart';
import 'package:fooddeliveryboiler/ui/widgets/restaurantCard.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/';
  final FocusNode searchFocus = new FocusNode();
  final GlobalKey<ScaffoldState> _scafflodKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    TextEditingController search = new TextEditingController();

    void navigationPage() {
      Route route = MaterialPageRoute(builder: (context) => LoginPage());
      Navigator.pushReplacement(context, route);
    }

    _redirect() async {
      var _duration = new Duration(milliseconds: 500);
      return new Timer(_duration, navigationPage);
    }

    redirectUser(context) {
      var _duration = new Duration(seconds: 3);
      return new Timer(
          _duration,
          () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => DeliveryScreen())));
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
