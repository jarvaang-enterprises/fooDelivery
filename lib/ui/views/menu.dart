import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fooddeliveryboiler/core/models/menuModel.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/menu.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/views/delivery.dart';
import 'package:fooddeliveryboiler/ui/views/orderConfim.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';
import 'package:fooddeliveryboiler/ui/widgets/drawer.dart';
import 'package:fooddeliveryboiler/ui/widgets/menuItem.dart';

class Menu extends StatefulWidget {
  final String restaurantId;
  Menu({this.restaurantId});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool orderNowButton = false;
  TextEditingController search = new TextEditingController();
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  /// Responsible for handling new order details
  dynamic sendNewOrder(MenuModel model, context) async {
    setState(() {
      orderNowButton = true;
    });

    Map<String, MenuData> _cart = model.getCart();

    String jsonStr =
        """{"userId": "${model.user.uID}","restaurantId":"${widget.restaurantId}","items": []}""";

    var result = json.decode(jsonStr);
    _cart.forEach((key, value) {
      result['items'].add(value);
    });

    var r;
    var delData = model.storage.delivery;
    if (delData != null) {
      r = await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          // contentPadding: EdgeInsets.symmetric(horizontal: 1.0),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Delivery Details",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              height: 240.0,
              width: double.infinity,
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Should we use your old delivery details for this order?",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: 200.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Latitude on Map: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          delData.lat.toString(),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Longitude on Map: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          delData.long.toString(),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "City: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Not Yet Implemented",
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Distance from Restaurant: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          delData.dist.toString(),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () =>
                  {Navigator.of(context, rootNavigator: true).pop(false)},
              icon: Icon(
                Icons.cancel_outlined,
                color: Colors.red,
              ),
              label: Text(
                "No",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(true),
              icon: Icon(Icons.check),
              label: Text("Yes"),
            ),
          ],
        ),
      );
    }
    if (r != null && r == true) {
      var response = await model.sendNewOrder(json.encode(result));

      if (response['success']) {
        _cart.clear();
        final snackBar = SnackBar(
          content: Text("Could not place order. Please Try again later."),
        );
        _key.currentState.showSnackBar(snackBar);
        Route route = MaterialPageRoute(
            builder: (context) =>
                OrderConfirm(orderId: response['data']['_id']));
        Navigator.push(context, route);
      } else {
        final snackBar = SnackBar(
          content: Text("Could not place order. Please Try again later."),
        );
        _key.currentState.showSnackBar(snackBar);
      }
    } else {
      Route route = MaterialPageRoute(builder: (context) => DeliveryScreen());
      var d = await Navigator.push(context, route);
      print(d);
    }

    setState(() {
      orderNowButton = false;
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<MenuModel>(
      onModelReady: (model) {
        model.getCurrentUser();
        model.getMenuData(widget.restaurantId);
      },
      builder: (context, model, child) {
        if (!model.isSearch) {
          search.clear();
        } else {
          if (model.searchDataJson == null) {
            var snackbar = SnackBar(content: Text('Search return empty'));
            Scaffold.of(context).showSnackBar(snackbar);
          }
        }
        return Scaffold(
          appBar: appBar(context, backAvailable: true, model: model),
          key: _key,
          backgroundColor: Colors.white,
          drawerEnableOpenDragGesture: true,
          drawer: AppDrawer(
            model: model,
          ),
          body: model.state == ViewState.Busy
              ? Center(
                  child: SpinKitChasingDots(color: Color(0xfffd5f00)),
                )
              : SafeArea(
                  child: Stack(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextField(
                            controller: search,
                            style: TextStyle(fontSize: 18),
                            onSubmitted: (String searchValue) {
                              if (searchValue != '') {
                                model.isSearch = true;
                                model.searchData(searchValue);
                              }
                            },
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(15, 17, 15, 15),
                              prefixIcon: Icon(
                                Icons.search,
                              ),
                              hintText: "Search for dish",
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
                                    width: 1.5),
                              ),
                            ),
                          ),
                        ),

                        // Menu Cards
                        Expanded(
                          child: ListView(
                              padding: const EdgeInsets.all(8.0),
                              children: [
                                for (var data in !model.isSearch
                                    ? model.menuData
                                    : model.searchDataJson)
                                  MenuItemCard(data: data),
                                SizedBox(height: 80),
                              ]),
                        )
                      ],
                    ),
                    model.getCart().length == 0
                        ? Container()
                        : Positioned(
                            bottom: 0,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 80,
                              color: Colors.white,
                              child: RaisedButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0)),
                                padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
                                onPressed: () async {
                                  if (!orderNowButton) {
                                    await sendNewOrder(model, context);
                                  }
                                },
                                color: Color(0xffFD792B),
                                child: orderNowButton
                                    ? Container(
                                        width: 100,
                                        height: 22,
                                        alignment: Alignment.center,
                                        child: SpinKitDoubleBounce(
                                            color: Colors.white),
                                      )
                                    : Container(
                                        width: 100,
                                        height: 22,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Order Now",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          )
                  ],
                )),
        );
      },
    );
  }
}
