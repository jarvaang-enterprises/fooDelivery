import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fooddeliveryboiler/core/models/orderModel.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/order.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/views/home.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';

class OrderConfirm extends StatefulWidget {
  final orderId;
  OrderConfirm({this.orderId});

  @override
  _OrderConfirmState createState() => _OrderConfirmState();
}

class _OrderConfirmState extends State<OrderConfirm> {
  Timer timer;
  bool cancelButton = false;
  OrderModel modelKey;
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    timer?.cancel();
    timer?.cancel();
    super.dispose();
  }

  refreshOrderData(model) {
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      model.refreshOrderData(widget.orderId);
    });
  }

  cancelOrder(OrderModel model) async {
    setState(() {
      cancelButton = true;
    });

    var response = await model.cancelOrder(widget.orderId);

    if (response) {
    } else {
      var snackbar = SnackBar(
        content: Text(
          "An error occured, Sorry for the inconvinience!",
        ),
      );
      _key.currentState.showSnackBar(snackbar);
    }

    setState(() {
      cancelButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    return BaseView<OrderModel>(
      onModelReady: (model) {
        model.getCurrentUser();
        model.getOrderData(widget.orderId);
        modelKey = model;
        Future.delayed(const Duration(milliseconds: 2000), () {
          refreshOrderData(model);
        });
      },
      builder: (context, model, child) {
        return Scaffold(
          key: _key,
          appBar: appBar(context, backAvailable: true, model: model),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: model.state == ViewState.Busy
                ? Center(
                    child: SpinKitChasingDots(
                      color: Color(0xfffd5f00),
                    ),
                  )
                : orderStatusScreen(model.orderData, model),
          ),
        );
      },
    );
  }

  Widget orderStatusScreen(OrderData data, OrderModel model) {
    switch (data.status) {
      case "PENDING":
        {
          return pendingOrder(model);
        }
        break;
      case "ACCEPTED":
        {
          return acceptedOrder(model);
        }
        break;
      case "REJECTED":
        {
          return rejectedOrder(model);
        }
        break;
      case "CANCELLED":
        {
          return cancelledOrder(model);
        }
        break;
      case "PREPARING":
        {
          return preparingOrder(model);
        }
        break;
      case "READY":
        {
          return readyOrder(model);
        }
        break;
      case "DISPATCHED":
        {
          return dispatchedOrder(model);
        }
        break;
      default:
        {
          return pendingOrder(model);
        }
        break;
    }
  }

  Widget pendingOrder(OrderModel model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Spacer(
          flex: 5,
        ),
        Center(
          child: Text(
            "Order Status",
            style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontSize: 25,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800),
          ),
        ),
        Center(
            child: Text(
          model.orderData.orderedOn,
          style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 18,
              fontWeight: FontWeight.w700),
        )),
        Spacer(
          flex: 8,
        ),
        Center(
          child: Image(
            width: 100,
            fit: BoxFit.cover,
            image: AssetImage("assets/images/1.png"),
          ),
        ),
        Spacer(
          flex: 8,
        ),
        Center(
          child: Text(
            "Confirming with Restaurant",
            style: TextStyle(
              color: Colors.blue.withOpacity(0.9),
              fontSize: MediaQuery.of(context).size.width / 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Spacer(
          flex: 8,
        ),
        Center(
          child: Container(
            width: 250,
            child: Text(
              "Please kindly wait, while we are processing your order!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.4),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Spacer(
          flex: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.watch_later,
              size: 25,
              color: Colors.green,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              model.orderData.preparationTime.toString() + " min.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.4),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        ),
        Spacer(
          flex: 6,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Material(
            color: Colors.red.withOpacity(0.85),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                cancelOrder(model);
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Center(
                        child: cancelButton
                            ? Container(
                                width: 40,
                                child: SpinKitDoubleBounce(color: Colors.white),
                              )
                            : Text(
                                'CANCEL ORDER',
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Spacer(
          flex: 3,
        )
      ],
    );
  }

  Widget dispatchedOrder(model) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Spacer(flex: 8),
          Center(
            child: Text(
              "Order Status",
              style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 25,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800),
            ),
          ),

          Center(
            child: Text(
              model.orderData.orderedOn,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Spacer(
            flex: 8,
          ),

          Center(
            child: Image(
              width: 150,
              //height: 300,
              fit: BoxFit.cover,
              image: AssetImage("assets/images/3.png"),
              // image: AssetImage("assets/images/food-img-1.jpg"),
            ),
          ),

          // SizedBox(
          //   height: 80,
          // ),

          Spacer(
            flex: 8,
          ),

          Center(
            child: Text(
              "Order has been Dispatched",
              style: TextStyle(
                  color: Colors.blue.withOpacity(0.9),
                  fontSize: MediaQuery.of(context).size.width / 18,
                  fontWeight: FontWeight.w800),
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Center(
            child: Container(
              width: 250,
              child: Text(
                "Your order has been dispatched. It will reach you soon.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),

          SizedBox(
            height: 5,
          ),

          // SizedBox(
          //   height: 30,
          // ),

          Spacer(
            flex: 3,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.watch_later,
                size: 25,
                color: Colors.green,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                model.orderData.preparationTime.toString() + "min.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),

          // SizedBox(
          //   height: 120,
          // ),

          Spacer(
            flex: 9,
          ),

          Spacer(
            flex: 3,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Route route =
                      MaterialPageRoute(builder: (context) => HomeScreen());
                  Navigator.push(context, route);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: new Border.all(
                        color: Color(0xfffd5f00),
                        style: BorderStyle.solid,
                        width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Center(
                          child: new Text(
                            'Go back to Home',
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Spacer(
            flex: 5,
          ),
        ],
      ),
    );
  }

  Widget readyOrder(model) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // SizedBox(
          //   height: 50,
          // ),

          Spacer(
            flex: 5,
          ),

          Center(
            child: Text(
              "Order Status",
              style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 25,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800),
            ),
          ),

          Center(
            child: Text(
              model.orderData.orderedOn,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),

          Spacer(
            flex: 8,
          ),

          Center(
            child: Image(
              width: 150,
              //height: 300,
              fit: BoxFit.cover,
              image: AssetImage("assets/images/3.png"),
              // image: AssetImage("assets/images/food-img-1.jpg"),
            ),
          ),

          Spacer(
            flex: 8,
          ),

          Center(
            child: Text(
              "Order is Ready",
              style: TextStyle(
                  color: Colors.blue.withOpacity(0.9),
                  fontSize: MediaQuery.of(context).size.width / 18,
                  fontWeight: FontWeight.w800),
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Center(
            child: Container(
              width: 250,
              child: Text(
                "Your order is ready and will be dispatched soon.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Spacer(
            flex: 3,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.watch_later,
                size: 25,
                color: Colors.green,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                model.orderData.preparationTime.toString() + "min.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),

          Spacer(
            flex: 12,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Route route =
                      MaterialPageRoute(builder: (context) => HomeScreen());
                  Navigator.push(context, route);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: new Border.all(
                        color: Color(0xfffd5f00),
                        style: BorderStyle.solid,
                        width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Center(
                          child: new Text(
                            'Go back to Home',
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Spacer(
            flex: 5,
          ),
        ],
      ),
    );
  }

  Widget preparingOrder(model) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Spacer(
            flex: 5,
          ),
          Center(
            child: Text(
              "Order Status",
              style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 25,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800),
            ),
          ),
          Center(
            child: Text(
              model.orderData.orderedOn,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Spacer(
            flex: 8,
          ),
          Center(
            child: Image(
              width: 150,
              //height: 300,
              fit: BoxFit.cover,
              image: AssetImage("assets/images/2.png"),
              // image: AssetImage("assets/images/food-img-1.jpg"),
            ),
          ),
          Spacer(
            flex: 8,
          ),
          Center(
            child: Text(
              "Preparing your Order",
              style: TextStyle(
                  color: Colors.green.withOpacity(0.9),
                  fontSize: MediaQuery.of(context).size.width / 18,
                  fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Center(
            child: Container(
              width: 250,
              child: Text(
                "Your order is being placed. Don't forget to order Desserts?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Spacer(
            flex: 3,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.watch_later,
                size: 25,
                color: Colors.green,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                model.orderData.preparationTime.toString() + "min.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Spacer(
            flex: 9,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Material(
              color: Colors.red.withOpacity(0.85),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  cancelOrder(model);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Center(
                          child: cancelButton
                              ? Container(
                                  width: 40,
                                  child:
                                      SpinKitDoubleBounce(color: Colors.white),
                                )
                              : Text(
                                  'CANCEL ORDER',
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Spacer(
            flex: 3,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Route route =
                      MaterialPageRoute(builder: (context) => HomeScreen());
                  Navigator.push(context, route);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: new Border.all(
                        color: Color(0xfffd5f00),
                        style: BorderStyle.solid,
                        width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Center(
                          child: new Text(
                            'Go back to Home',
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Spacer(
            flex: 5,
          ),
        ],
      ),
    );
  }

  Widget cancelledOrder(model) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // SizedBox(
          //   height: 50,
          // ),

          Spacer(
            flex: 5,
          ),

          Center(
            child: Text(
              "Order Status",
              style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 25,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800),
            ),
          ),

          Center(
            child: Text(
              model.orderData.orderedOn,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),

          Spacer(
            flex: 8,
          ),

          Center(
            child: Image(
              width: 100,
              //height: 300,
              fit: BoxFit.cover,
              image: AssetImage("assets/images/1.png"),
              // image: AssetImage("assets/images/food-img-1.jpg"),
            ),
          ),

          Spacer(
            flex: 8,
          ),

          Center(
            child: Text(
              "Order Cancelled",
              style: TextStyle(
                  color: Colors.red.withOpacity(0.9),
                  fontSize: MediaQuery.of(context).size.width / 18,
                  fontWeight: FontWeight.w800),
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Center(
            child: Container(
              width: 250,
              child: Text(
                "As per your request we have cancelled your order.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),

          Spacer(
            flex: 20,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Route route =
                      MaterialPageRoute(builder: (context) => HomeScreen());
                  Navigator.push(context, route);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: new Border.all(
                        color: Color(0xfffd5f00),
                        style: BorderStyle.solid,
                        width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Center(
                          child: new Text(
                            'Go back to Home',
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Spacer(
            flex: 5,
          ),
        ],
      ),
    );
  }

  Widget rejectedOrder(model) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Spacer(
            flex: 5,
          ),
          Center(
            child: Text(
              "Order Status",
              style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 25,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800),
            ),
          ),
          Center(
            child: Text(
              model.orderData.orderedOn,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Spacer(
            flex: 8,
          ),
          Center(
            child: Image(
              width: 100,
              //height: 300,
              fit: BoxFit.cover,
              image: AssetImage("assets/images/1.png"),
            ),
          ),
          Spacer(
            flex: 8,
          ),
          Center(
            child: Text(
              "Order Rejected",
              style: TextStyle(
                  color: Colors.red.withOpacity(0.9),
                  fontSize: MediaQuery.of(context).size.width / 18,
                  fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Center(
            child: Container(
              width: 350,
              child: Text(
                "Restaurant has rejected the order. We apologise for the inconvenience caused.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Spacer(
            flex: 3,
          ),
          Spacer(
            flex: 12,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Route route =
                      MaterialPageRoute(builder: (context) => HomeScreen());
                  Navigator.push(context, route);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: new Border.all(
                        color: Color(0xfffd5f00),
                        style: BorderStyle.solid,
                        width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Center(
                          child: new Text(
                            'Go back to Home',
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Spacer(
            flex: 5,
          ),
        ],
      ),
    );
  }

  Widget acceptedOrder(model) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Spacer(
            flex: 5,
          ),
          Center(
            child: Text(
              "Order Status",
              style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 25,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800),
            ),
          ),
          Center(
            child: Text(
              model.orderData.orderedOn,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Spacer(
            flex: 8,
          ),
          Center(
            child: Image(
              width: 120,
              fit: BoxFit.cover,
              image: AssetImage("assets/images/4.png"),
            ),
          ),
          Spacer(
            flex: 8,
          ),
          Center(
            child: Text(
              "Order Confirmed",
              style: TextStyle(
                  color: Colors.green.withOpacity(0.9),
                  fontSize: MediaQuery.of(context).size.width / 18,
                  fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Center(
            child: Container(
              width: 250,
              child: Text(
                "Your order has been confirmed.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Spacer(
            flex: 3,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.watch_later,
                size: 25,
                color: Colors.green,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                model.orderData.preparationTime.toString() + "min.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Spacer(
            flex: 9,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Material(
              color: Colors.red.withOpacity(0.85),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  cancelOrder(model);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Center(
                          child: cancelButton
                              ? Container(
                                  width: 40,
                                  child:
                                      SpinKitDoubleBounce(color: Colors.white),
                                )
                              : Text(
                                  'CANCEL ORDER',
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Spacer(
            flex: 3,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Route route =
                      MaterialPageRoute(builder: (context) => HomeScreen());
                  Navigator.push(context, route);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: new Border.all(
                        color: Color(0xfffd5f00),
                        style: BorderStyle.solid,
                        width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Center(
                          child: new Text(
                            'Go back to Home',
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Spacer(
            flex: 5,
          ),
        ],
      ),
    );
  }
}
