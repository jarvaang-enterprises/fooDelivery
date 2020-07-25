import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fooddeliveryboiler/core/models/restaurantModel.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/home.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseView<HomeModel>(
      onModelReady: (model) {
        model.getRestaurantData();
      },
      builder: (context, model, child) {
        print(model.homeDataJson);
        return Scaffold(
          appBar: appBar(context),
          backgroundColor: Colors.white,
          body: model.state == ViewState.Busy
              ? Center(
                  child: SpinKitChasingDots(
                    color: Color(0xfffd5f00),
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
