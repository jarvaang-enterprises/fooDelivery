import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fooddeliveryboiler/core/models/restaurantModel.dart';

final _random = new Random();

int next(int min, int max) => min + _random.nextInt(max - min);

Widget restaurantCard(context, RestaurantData data) {
  return GestureDetector(
    onTap: () {
      if (data.acceptingOrders) {
        Route route = MaterialPageRoute(
            builder: (context) => Menu(restaurantId: data.sId));
        Navigator.push(context, route);
      }
    },
  );
}
