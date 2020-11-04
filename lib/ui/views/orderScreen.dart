import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fooddeliveryboiler/core/models/orderScreenModel.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/orderScreen.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';
import 'package:fooddeliveryboiler/ui/widgets/drawer.dart';
import 'package:fooddeliveryboiler/ui/widgets/orderScreenViewItem.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersView extends StatefulWidget {
  final String userId;
  OrdersView({this.userId});

  @override
  _OrdersViewState createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  Timer timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  refreshOrders(model) {
    timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      model.refreshOrders();
      // setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<OrderScreen>(
      onModelReady: (model) {
        model.getCurrentUser();
        model.getOrders(model.user.uID);
        Future.delayed(const Duration(milliseconds: 2000), () {
          refreshOrders(model);
        });
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: appBar(context, backAvailable: true, model: model),
          backgroundColor: Colors.white,
          drawer: AppDrawer(model: model, name: model.modelName),
          body: model.state == ViewState.Busy
              ? Center(
                  child: SpinKitChasingDots(color: Color(0xfffd5f00)),
                )
              : SafeArea(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Divider(
                            height: 5,
                            thickness: 2,
                            color: Colors.orangeAccent,
                          ),
                          // Info
                          Center(
                            heightFactor: 1.2,
                            child: Text(
                              "Your Orders",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.8),
                                  fontSize: 25,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                          Divider(
                            height: 5,
                            thickness: 2,
                            color: Colors.orangeAccent,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            child: Center(
                              child: Text(
                                model.orders != null
                                    ? "We would like to thank you for the continued support"
                                    : "",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.aladin(
                                    fontSize: 20, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                          // Orders Cards
                          model.orders == null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    "You have not yet placed any orders, \nPlease go ahead and place an order!",
                                    style: GoogleFonts.kristi(
                                        fontSize: 20,
                                        fontStyle: FontStyle.italic),
                                  ),
                                )
                              : Expanded(
                                  flex: 1,
                                  child: SafeArea(
                                    child: ListView(
                                      padding: const EdgeInsets.all(8.0),
                                      children: [
                                        for (OrderScreenModel order
                                            in model.orders)
                                          OrdersItem(
                                            data: order,
                                          ),
                                        SizedBox(
                                          height: 80,
                                        )
                                      ],
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
