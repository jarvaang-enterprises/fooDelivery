import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fooddeliveryboiler/core/viewModels/home.dart';
import 'package:fooddeliveryboiler/ui/views/home.dart';
import 'package:fooddeliveryboiler/ui/views/login.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({this.model});
  final model;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _createHeader(context, model),
          _createDrawerItem(context, icon: Icons.contacts, text: 'Home',
              onTap: () {
            Navigator.pop(context);
            Route route = MaterialPageRoute(builder: (context) => HomeScreen());
            Navigator.pushReplacement(context, route);
          }),
          _createDrawerItem(context, icon: Icons.event, text: 'Orders',
              onTap: () {
            Navigator.pop(context);
            Fluttertoast.showToast(
                msg: "Orders page",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Theme.of(context).primaryColorDark,
                timeInSecForIos: 2);
            // Route route = MaterialPageRoute(builder: (context) => HomeScreen());
            // Navigator.pushReplacement(context, route);
          }),
          _createDrawerItem(context, icon: Icons.note, text: 'Notes',
              onTap: () {
            Navigator.pop(context);
            // Route route = MaterialPageRoute(builder: (context) => HomeScreen());
            // Navigator.pushReplacement(context, route);
          }),
          Divider(),
          _createDrawerItem(context,
              icon: Icons.collections_bookmark, text: 'Steps', onTap: () {
            Navigator.pop(context);
          }),
          _createDrawerItem(context, icon: Icons.face, text: 'Authors',
              onTap: () {
            Navigator.pop(context);
          }),
          _createDrawerItem(context,
              icon: Icons.account_box,
              text: 'Flutter Documentation', onTap: () {
            Navigator.pop(context);
          }),
          _createDrawerItem(context,
              icon: Icons.sensor_door,
              text: 'Logout',
              onTap: () => {
                    Navigator.pop(context),
                    if (model != null)
                      {
                        model.signOut(),
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()))
                      },
                  }),
          Divider(),
          _createDrawerItem(context,
              icon: Icons.bug_report, text: 'Report an issue', onTap: () {
            Navigator.pop(context);
          }),
          ListTile(
            title: Text('0.0.1'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _createHeader(BuildContext context, HomeModel model) {
    return UserAccountsDrawerHeader(
      accountName: Text(model.user.displayName),
      accountEmail: Text(model.user.email),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
            ? Colors.blue
            : Colors.white,
        child: model.user.photoUrl == null
            ? Text(
                model.user.displayName
                    .split(' ')[0]
                    .substring(0, 1)
                    .toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              )
            : NetworkImage(model.user.photoUrl, scale: 1.0),
      ),
    );
  }

  Widget _createDrawerItem(BuildContext context,
      {IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
