import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fooddeliveryboiler/core/models/menuModel.dart';

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
      Route route = MaterialPageRoute(builder: (context) => OrderCon)
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
