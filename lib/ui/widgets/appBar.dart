import 'package:flutter/material.dart';

/// Widget that builds our application specific appBar
///
/// It is a custom built widget that enables us to control the appBar separate
///  from all the views
///
/// @Junior Lawrence Kibirige - aanga26@gmail.com
Widget appBar(BuildContext context, {bool backAvailable = false}) {
  return AppBar(
    bottomOpacity: 0,
    elevation: 0,
    backgroundColor: Colors.deepOrangeAccent,
    leading: IconButton(
        iconSize: 25,
        icon:
            Icon(backAvailable ? Icons.arrow_back_ios : Icons.restaurant_menu),
        onPressed: () => {
              if (backAvailable) {Navigator.pop(context)}
            },
        color: Colors.black),
    title: Container(
        alignment: Alignment.center,
        height: 28,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/icons/delivery_logo_trans@100x61.png"),
            ),
            Text(
              "Mars Cafe",
              style: TextStyle(color: Colors.black54),
            )
          ],
        )),
    actions: [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        child: Icon(
          Icons.filter_list,
          size: 30,
          color: Colors.black,
        ),
      )
    ],
  );
}
