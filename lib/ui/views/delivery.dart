import 'package:flutter/cupertino.dart';
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
          appBar: appBar(
            context,
            model: model,
            key: _key,
            backAvailable: true,
          ),
          drawer: AppDrawer(model: model, name: model.modelName),
          drawerEnableOpenDragGesture: true,
          backgroundColor: Color.fromRGBO(255, 255, 255, .95),
          body: model.state == ViewState.Busy
              ? Center(
                  heightFactor: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                        width: double.infinity,
                        // decoration: BoxDecoration(
                        //   color: Colors.white60,
                        // ),
                        child: Center(
                          child: Text(
                            "Delivery Details",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                      ),
                      Column(
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
                    ],
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white60,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 15),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white70,
                            ),
                            child: Center(
                              child: Text(
                                "Delivery Details",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                elevation: 18.0,
                                color: Colors.orangeAccent,
                                shadowColor: Colors.blueAccent,
                                clipBehavior: Clip.antiAlias,
                                child: MaterialButton(
                                  elevation: 0,
                                  // width: double.maxFinite,
                                  height: 30,
                                  onPressed: () {
                                    model.getCurrentLoction();
                                  },
                                  color: Colors.orangeAccent,
                                  child: Text(
                                    'Update delivery details',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  textColor: Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          ClipRect(
                            child: Container(
                              height: MediaQuery.of(context).size.height * .74,
                              width: MediaQuery.of(context).size.width - 5,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(12, 18, 12, 15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Location:',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                    Text(
                                      model.deliveryData != null
                                          ? model.deliveryData
                                              .toJson()['name']
                                              .toString()
                                          : model.currentAddress ?? "",
                                      softWrap: true,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
