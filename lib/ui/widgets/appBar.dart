import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widget that builds our application specific appBar
///
/// It is a custom built widget that enables us to control the appBar separate
///  from all the views
///
/// @Junior Lawrence Kibirige - aanga26@gmail.com
Widget appBar(BuildContext context,
    {bool backAvailable = false, dynamic model, GlobalKey<ScaffoldState> key}) {
  Choice _selectedChoice = choices[0];

  void _select(Choice choice) {
    _selectedChoice = choice;
  }

  return AppBar(
    bottomOpacity: 0,
    elevation: 0,
    backgroundColor: Colors.deepOrangeAccent,
    leading: IconButton(
        iconSize: 25,
        icon:
            Icon(backAvailable ? Icons.arrow_back_ios : Icons.restaurant_menu),
        onPressed: () {
          if (backAvailable) {
            String prev = model.storage.getPrevScreen();
            if (model.storage.getCurrentScreen() == 'deliveryModel') {
              model.storage.saveCurrentScreen(prev);
              Navigator.pop(context, "returned");
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
      !['orderScreen', 'order_confirm', 'deliveryModel']
              .contains(model.storage.getCurrentScreen())
          ? PopupMenuButton<Choice>(
              icon: Icon(
                Icons.filter_list,
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
              icon: Icon(Icons.warning_amber_sharp),
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
  const Choice(title: '', icon: FontAwesomeIcons.caretDown),
  const Choice(title: 'By Rating Asc', icon: FontAwesomeIcons.sortUp),
  const Choice(title: 'By Rating Desc', icon: FontAwesomeIcons.sortDown),
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
