import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fooddeliveryboiler/core/models/menuModel.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/menu.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/views/orderConfim.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';
import 'package:fooddeliveryboiler/ui/widgets/menuItem.dart';

class Menu extends StatefulWidget {
  final String restaurantId;
  Menu({this.restaurantId});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool orderNowButton = false;

  /**
   * Responsible for handling new order details
   */
  dynamic sendNewOrder(model, context) async {
    setState(() {
      orderNowButton = true;
    });

    Map<String, MenuData> _cart = model.getCart();

    String jsonStr = """{
      "userId":"dummy",
      "restaurantId":"${widget.restaurantId}",
      "items": []
    }""";

    var result = json.decode(jsonStr);
    _cart.forEach((key, value) {
      result['items'].add({"_id": value.sId, "quantity": value.totalItems});
    });

    var response = await model.sendNewOrder(json.encode(result));
    print(response);

    if (response['success']) {
      print("yes");
      Route route = MaterialPageRoute(
          builder: (context) => OrderConfirm(orderId: response['data']['_id']));
      Navigator.push(context, route);
    } else {
      print("no");
      final snackBar = SnackBar(
        content: Text("Could not place order. Please Try again later."),
      );
      Scaffold.of(context).showSnackBar(snackBar);
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
        model.getMenuData(widget.restaurantId);
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: appBar(context, backAvailable: true),
          backgroundColor: Colors.white,
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
                            style: TextStyle(fontSize: 18),
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
                                for (var data in model.menuData)
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
