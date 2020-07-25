import 'package:flutter/material.dart';

/// Widget that builds our application specific appBar
Widget appBar(BuildContext context, {bool backAvailable = false}) {
  return AppBar(
    bottomOpacity: 0,
    elevation: 0,
    backgroundColor: Colors.transparent,
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
      child: Image(
        image: AssetImage("assets/images/logo.png"),
      ),
    ),
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
