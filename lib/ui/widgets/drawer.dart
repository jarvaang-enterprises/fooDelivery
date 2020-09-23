import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fooddeliveryboiler/ui/views/home.dart';
import 'package:fooddeliveryboiler/ui/views/login.dart';
import 'package:fooddeliveryboiler/ui/views/orderScreen.dart';
import 'package:fooddeliveryboiler/ui/views/profile.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({this.model, this.name});
  final model;
  final name;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _createHeader(context, model),
          _createDrawerItem(context, icon: Icons.contacts, text: 'Home',
              onTap: () {
            if (model.storage.getCurrentScreen() != "homeModal") {
              Navigator.pop(context);
              Route route =
                  MaterialPageRoute(builder: (context) => HomeScreen());
              Navigator.pushReplacement(context, route);
            } else {
              Navigator.pop(context);
            }
          }),
          _createDrawerItem(context, icon: Icons.event, text: 'Orders',
              onTap: () {
            if (model.storage.getCurrentScreen() != "orderScreen") {
              // model.storage.saveCurrentScreen("orderScreen");
              Navigator.pop(context);
              Route route =
                  MaterialPageRoute(builder: (context) => OrdersView());
              Navigator.push(context, route);
            } else {
              Navigator.pop(context);
            }
          }),
          _createDrawerItem(context,
              icon: Icons.account_circle, text: 'Profile', onTap: () {
            Fluttertoast.showToast(
                msg: "Profile page coming in future releases!",
                toastLength: Toast.LENGTH_LONG);
            if (model.storage.getCurrentScreen() != "profile_model") {
              Navigator.pop(context);
              Route route =
                  MaterialPageRoute(builder: (context) => ProfileScreen());
              Navigator.push(context, route);
            } else {
              Navigator.pop(context);
            }
          }),
          Divider(),
          // _createDrawerItem(context,
          //     icon: Icons.collections_bookmark, text: 'Steps', onTap: () {
          //   Navigator.pop(context);
          // }),
          // _createDrawerItem(context, icon: Icons.face, text: 'Authors',
          //     onTap: () {
          //   Navigator.pop(context);
          // }),
          // _createDrawerItem(context,
          //     icon: Icons.account_box,
          //     text: 'Flutter Documentation', onTap: () {
          //   Navigator.pop(context);
          // }),
          _createDrawerItem(context,
              icon: Icons.sensor_door,
              text: 'Logout',
              onTap: () => {
                    Navigator.pop(context),
                    if (model != null)
                      {
                        model.storage.saveStringToDisk('user', null),
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
            Fluttertoast.showToast(
                msg: "Issues coming in next release!",
                toastLength: Toast.LENGTH_LONG);
            Navigator.pop(context);
          }),
          ListTile(
            title: Text('1.0.1'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _createHeader(BuildContext context, dynamic model) {
    return UserAccountsDrawerHeader(
      accountName: Text(model.user.displayName),
      accountEmail: Text(model.user.email),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
            ? Colors.blue
            : Colors.white,
        child: model.user.photoUrl == null
            ? Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  model.user.displayName
                      .split(' ')[0]
                      .substring(0, 1)
                      .toUpperCase(),
                  style: TextStyle(fontSize: 40.0),
                ),
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
