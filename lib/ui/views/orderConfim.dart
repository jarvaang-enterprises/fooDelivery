import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/order.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';

class OrderConfirm extends StatefulWidget {
  var orderId;
  OrderConfirm({this.orderId});

  @override
  _OrderConfirmState createState() => _OrderConfirmState();
}

class _OrderConfirmState extends State<OrderConfirm> {
  Timer timer, timer_once;
  bool cancelButton = false;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  refreshOrderData(model) {
    timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      model.refreshOrderData(widget.orderId);
    });
  }

  cancelOrder(model) async {
    setState(() {
      cancelButton = true;
    });

    var response = await model.cancelOrder(widget.orderId);

    setState(() {
      cancelButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<OrderModel>(
      onModelReady: (model) {
        model.getOrderData(widget.orderId);
        Future.delayed(const Duration(milliseconds: 2000), () {
          refreshOrderData(model);
        });
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: appBar(context, backAvailable: true),
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
}
