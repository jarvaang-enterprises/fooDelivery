import 'package:flutter/material.dart';
import 'package:fooddeliveryboiler/core/models/orderModel.dart';
import 'package:fooddeliveryboiler/core/viewModels/order.dart';

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
      )
    ],
  );
}
