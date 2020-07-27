import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fooddeliveryboiler/core/models/restaurantModel.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/home.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';
import 'package:fooddeliveryboiler/ui/widgets/restaurantCard.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseView<HomeModel>(
      onModelReady: (model) {
        model.getRestaurantData();
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: appBar(context),
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
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(15, 17, 15, 15),
                            prefixIcon: Icon(Icons.search),
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
                            for (RestaurantData data in model.homeDataJson)
                              restaurantCard(context, data),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
