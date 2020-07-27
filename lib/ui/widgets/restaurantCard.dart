import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fooddeliveryboiler/core/models/restaurantModel.dart';
import 'package:fooddeliveryboiler/ui/views/menu.dart';

final _random = new Random();

int next(int min, int max) => min + _random.nextInt(max - min);

// Responsible for displaying the individual Dish Cards to the user
Widget restaurantCard(context, RestaurantData data) {
  return GestureDetector(
    onTap: () {
      if (data.acceptingOrders) {
        Route route = MaterialPageRoute(
            builder: (context) => Menu(restaurantId: data.sId));
        Navigator.push(context, route);
      }
    },
    child: Container(
      foregroundDecoration: data.acceptingOrders
          ? BoxDecoration()
          : BoxDecoration(
              color: Colors.grey,
              backgroundBlendMode: BlendMode.saturation,
            ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              child: FadeInImage.assetNetwork(
                width: double.infinity,
                height: 200,
                placeholder: "assets/images/food-load-7.gif",
                image: data.imageUrl,
              ),
            ),
            // Dish Name
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 20, 20),
              child: Text(
                data.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            // Dish Details
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Color(0xffFFD700),
                        size: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                        child: Text(
                          // TODO: @Godana Emiru - Create a function for the rating system and implement a star-based system of rating instead of a one star representing all rates
                          (next(21, 47) / 10).toString(),
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withOpacity(0.5)),
                        ),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.watch_later,
                        color: Colors.blue,
                        size: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                        child: Text(
                          data.opensAt + " - " + data.closesAt,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withOpacity(0.5)),
                        ),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (var i = 0; i <= next(0, 3); i++)
                        Icon(
                          Icons.monetization_on,
                          color: Colors.green,
                          size: 20,
                        )
                    ],
                  ),

                  // Component for showing location of restaurant on scaling
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: <Widget>[
                  //     Icon(
                  //       Icons.location_on,
                  //       color: Colors.blue,
                  //       size: 20,
                  //     ),
                  //     Padding(
                  //       padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                  //       child: Text(
                  //         "Potheri",
                  //         style: TextStyle(
                  //             fontSize: 17,
                  //             fontWeight: FontWeight.w700,
                  //             color: Colors.black.withOpacity(0.5)),
                  //       ),
                  //     )
                  //   ],
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}
