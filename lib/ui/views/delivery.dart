import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/delivery.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';
import 'package:fooddeliveryboiler/ui/widgets/drawer.dart';

class DeliveryScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BaseView<DeliveryModel>(
      onModelReady: (model) {
        model.getCurrentUser();
      },
      builder: (context, model, child) {
        if (model.user != null) {
          if (model.deliveryData == null) {
            Fluttertoast.showToast(
                msg: "No delivery data!", toastLength: Toast.LENGTH_LONG);
          }
        }
        return Scaffold(
          key: _key,
          appBar: appBar(context, model: model, key: _key, backAvailable: true),
          drawer: AppDrawer(model: model, name: model.modelName),
          drawerEnableOpenDragGesture: true,
          backgroundColor: Colors.white60,
          body: model.state == ViewState.Busy
              ? Center(
                  heightFactor: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SpinKitChasingDots(
                        size: 30,
                        duration: new Duration(milliseconds: 800),
                        color: Color(0xfffd5f00),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      model.counter >= 4
                          ? Text(
                              "Taking longer than normal to load ...",
                              style: TextStyle(color: Colors.orange),
                            )
                          : Text(""),
                      model.counter >= 6
                          ? Text(
                              "Please check your internet connection!",
                              style: TextStyle(color: Colors.redAccent),
                            )
                          : Text("")
                    ],
                  ),
                )
              : SafeArea(child: Column()),
        );
      },
    );
  }
}
