import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddeliveryboiler/core/models/menuModel.dart';

/// Widget that builds our application specific appBar
///
/// It is a custom built widget that enables us to control the appBar separate
///  from all the views
///
/// @Junior Lawrence Kibirige - aanga26@gmail.com
Widget appBar(BuildContext context,
    {bool backAvailable = false,
    dynamic data,
    dynamic model,
    GlobalKey<ScaffoldState> key}) {
  Choice _selectedChoice = choices[0];

  void _select(Choice choice) {
    _selectedChoice = choice;
    if (model != null) {
      model.isCat = true;
      model.categoryChange(choice);
    }
  }

  void saveOrder(Choice c) {
    Map<String, MenuData> order = model.cart;
    model.storage.saveCart(order);
  }

  return AppBar(
    bottomOpacity: 0,
    elevation: 0,
    backgroundColor: Colors.deepOrangeAccent,
    leading: IconButton(
        iconSize: 25,
        icon: (model != null &&
                model.storage.getCurrentScreen() == 'checkoutModel')
            ? Icon(
                Icons.check,
                size: 40.0,
                color: Colors.greenAccent,
              )
            : Icon(
                backAvailable ? Icons.arrow_back_ios : Icons.restaurant_menu),
        onPressed: () {
          if (backAvailable) {
            String prev = model.storage.getPrevScreen();
            if (model.storage.getCurrentScreen() == 'deliveryModel') {
              model.storage.saveCurrentScreen(prev);
              Navigator.pop(context, "returned");
            } else if (model.storage.getCurrentScreen() == 'checkoutModel') {
              model.storage.saveCurrentScreen(prev);
              data['items'] = [];
              model.cart.forEach((key, item) {
                data['items'].add(item);
              });
              data['grandCost'] = model.grandCost;
              Navigator.pop(context, data);
            } else {
              model.storage.saveCurrentScreen(prev);
              Navigator.pop(context);
            }
          } else {
            if (model != null) {
              if (model.isSearch) {
                model.isSearch = false;
                model.refresh();
              } else {
                if (key.currentState.hasDrawer) {
                  if (!key.currentState.isDrawerOpen) {
                    key.currentState.openDrawer();
                  }
                }
              }
            }
          }
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
      ![
        'orderScreen',
        'order_confirm',
        'deliveryModel',
        'profile_model',
        'checkoutModel',
        'splashScreen',
        'menuModel'
      ].contains(
              model != null ? model.storage.getCurrentScreen() : 'splashScreen')
          ? PopupMenuButton<Choice>(
              icon: Icon(
                model.storage.getCurrentScreen() == 'homeModal' && model.isCat
                    ? Icons.lunch_dining
                    : Icons.filter_list,
                color: Colors.black,
              ),
              onSelected: _select,
              itemBuilder: (BuildContext context) {
                return choices.map((Choice e) {
                  return PopupMenuItem<Choice>(
                    value: e,
                    child: Text(e.title),
                  );
                }).toList();
              },
            )
          : PopupMenuButton<Choice>(
              icon:
                  // (model.storage.getCurrentScreen() != 'checkoutModel')?
                  Icon(Icons.warning_amber_sharp,
                      color: Colors.deepOrangeAccent),
              // : Icon(Icons.save),
              // onSelected: (model.storage.getCurrentScreen() != 'checkoutModel')
              //     ? () => {}
              //     : saveOrder,
              itemBuilder: (BuildContext context) {
                return [].toList();
              },
            )
    ],
  );
}

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Select Category', icon: FontAwesomeIcons.caretDown),
  const Choice(title: 'Breakfast', icon: FontAwesomeIcons.sortUp),
  const Choice(title: 'Lunch', icon: FontAwesomeIcons.sortDown),
  const Choice(title: 'Snacks', icon: FontAwesomeIcons.sortDown),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);
  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle tS = Theme.of(context).textTheme.headline4;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(choice.icon, size: 128.0, color: Colors.black),
            Text(choice.title, style: tS)
          ],
        ),
      ),
    );
  }
}
