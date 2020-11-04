import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fooddeliveryboiler/core/models/menuModel.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/checkout.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';
import 'package:fooddeliveryboiler/ui/widgets/checkoutItem.dart';

class Checkout extends StatefulWidget {
  final cart;

  const Checkout({Key key, this.cart}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _Checkout();
}

class _Checkout extends State<Checkout> {
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  var totalCost = 0.00, deliveryCost = 0.00;
  @override
  void initState() {
    for (MenuData item in widget.cart['items']) {
      totalCost += item.price * item.totalItems;
    }
    super.initState();
  }

  void _calculateTotal(Map<String, MenuData> c) {
    totalCost = 0.00;
    for (MenuData item in c.values) {
      totalCost += item.price * item.totalItems;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return BaseView<CheckoutModel>(
      onModelReady: (model) {
        model.getCurrentUser();
        model.setCart(widget.cart['items']);
        if (model.cart.toString().compareTo(widget.cart['items'].toString()) !=
            0) _calculateTotal(model.cart);
        deliveryCost = (double.parse(model.storage.delivery.dist) / 1000) *
            model.costPerKm;
      },
      builder: (context, model, child) {
        if (model.cart.toString().compareTo(widget.cart['items'].toString()) !=
            0) {
          _calculateTotal(model.cart);
        }
        return Scaffold(
          appBar: appBar(context,
              backAvailable: true, model: model, data: widget.cart),
          key: _key,
          backgroundColor: Colors.blueGrey.withRed(12),
          body: model.state == ViewState.Busy
              ? Center(
                  child: SpinKitChasingDots(color: Color(0xfffd5f00)),
                )
              : SafeArea(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox.fromSize(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .6,
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text(
                                      "Checkout Order",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .3,
                                    padding: EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      totalCost.toString() + "/=",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                  ),
                                ],
                              ),
                              size: Size(
                                MediaQuery.of(context).size.width - 20,
                                MediaQuery.of(context).size.width * 0.18,
                              ),
                            ),
                            Divider(
                              color: Colors.white70,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 8,
                                ),
                                width: double.infinity,
                                decoration:
                                    BoxDecoration(color: Colors.black87),
                                child: Text(
                                  "Please confirm all details are in order before you"
                                  " decide to process your payment",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white60,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 8.0,
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.black87),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var data in model.cart.values)
                                    CheckoutItemCard(
                                      data: data,
                                    ),
//                              Text(widget.cart['items']),
                                  SizedBox(height: 80),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      model.cart.length == 0
                          ? Container()
                          : Positioned(
                              bottom: 0,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 80,
                                color: Colors.white,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
                                  color: Color(0xffFD792B).withOpacity(.7),
                                  width: 100,
                                  height: 22,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Sub-Total:",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "UGX. " + totalCost.toString(),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                "Delivery Fee: ",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                "(" +
                                                    model.storage.delivery.name
                                                        .split(',')
                                                        .sublist(0, 2)
                                                        .join(',') +
                                                    ")",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "UGX. " + deliveryCost.toString(),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Grand Total:",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 19.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "UGX. " +
                                                (deliveryCost + totalCost)
                                                    .toString(),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 19.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                    ],
                  ),
                ),
        );
      },
    );
  }
}
