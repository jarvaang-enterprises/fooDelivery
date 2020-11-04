import 'package:flutter/material.dart';
import 'package:fooddeliveryboiler/core/models/orderScreenModel.dart';
import 'package:fooddeliveryboiler/ui/views/orderConfim.dart';

class OrdersItem extends StatefulWidget {
  final OrderScreenModel data;
  OrdersItem({this.data});

  @override
  _OrdersItemState createState() => _OrdersItemState();
}

class _OrdersItemState extends State<OrdersItem> {
  @override
  Widget build(BuildContext context) {
    // final model = Provider.of<OrderScreenModel>(context);
    return GestureDetector(
      onTap: () {
        var route = MaterialPageRoute(
            builder: (context) => OrderConfirm(orderId: widget.data.sId));
        Navigator.push(context, route);
      },
      child: Container(
        width: double.infinity,
        foregroundDecoration: widget.data.status == "CANCELLED"
            ? BoxDecoration(
                color: Colors.grey, backgroundBlendMode: BlendMode.saturation)
            : BoxDecoration(),
        child: Card(
          color: Colors.blueGrey.shade50,
          elevation: 2,
          borderOnForeground: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          shadowColor: Colors.black,
          child: Row(
            children: [
              ClipRRect(
                // Menu Item Image
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: Image(
                  height: (MediaQuery.of(context).size.width * 0.2) + 10,
                  width: MediaQuery.of(context).size.width * 0.2,
                  image: AssetImage('assets/images/1.png'),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                width: (MediaQuery.of(context).size.width * 0.7),
                height: (MediaQuery.of(context).size.width * 0.2) + 35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacer(
                      flex: 1,
                    ),
                    Text(
                      "Order " + widget.data.sId.substring(0, 8),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "Total Items: " +
                          (widget.data.items.length == 0
                              ? ''
                              : widget.data.items.length.toString()),
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.data.date,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Wrap(
                      direction: Axis.vertical,
                      spacing: 3,
                      runSpacing: 5,
                      children: [
                        widget.data.status == "PENDING"
                            ? pendingOrder()
                            : widget.data.status == "ACCEPTED"
                                ? acceptedOrder()
                                : widget.data.status == "REJECTED"
                                    ? rejectedOrder()
                                    : widget.data.status == "CANCELLED"
                                        ? cancelledOrder()
                                        : widget.data.status == "PREPARING"
                                            ? preparingOrder()
                                            : widget.data.status == "READY"
                                                ? readyOrder()
                                                : widget.data.status ==
                                                        "DISPATCHED"
                                                    ? dispatchedOrder()
                                                    : pendingOrder(),
                        Text("Total Cost: " + widget.data.total.toString())
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pendingOrder() {
    return Container(
      width: (MediaQuery.of(context).size.width * 0.7),
      height: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Order Status:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          Text(
            " Confirming with Restaurant",
            style: TextStyle(
              color: Colors.blue.withOpacity(0.9),
              fontSize: (MediaQuery.of(context).size.width * 0.7) / 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget acceptedOrder() {
    return Container(
      width: (MediaQuery.of(context).size.width * 0.7),
      height: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Order Status:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          Text(
            " Order Confirmed",
            style: TextStyle(
              color: Colors.orange.withOpacity(0.9),
              fontSize: (MediaQuery.of(context).size.width * 0.7) / 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget rejectedOrder() {
    return Container(
      height: 20,
      width: (MediaQuery.of(context).size.width * 0.7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Order Status:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          Text(
            " Order Rejected",
            style: TextStyle(
              color: Colors.red.withOpacity(0.9),
              fontSize: (MediaQuery.of(context).size.width * 0.7) / 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget cancelledOrder() {
    return Container(
      width: (MediaQuery.of(context).size.width * 0.7),
      height: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Order Status:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          Text(
            " Order Cancelled",
            style: TextStyle(
              color: Colors.red.withOpacity(0.9),
              fontSize: (MediaQuery.of(context).size.width * 0.7) / 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget preparingOrder() {
    return Container(
      height: 20,
      width: (MediaQuery.of(context).size.width * 0.7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Order Status:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          Text(
            " Preparing your Order",
            style: TextStyle(
                color: Colors.yellow.shade600,
                fontSize: (MediaQuery.of(context).size.width * 0.7) / 20,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget readyOrder() {
    return Container(
      height: 20,
      width: (MediaQuery.of(context).size.width * 0.7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Order Status:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          Text(
            " Order Ready",
            style: TextStyle(
                color: Colors.blue.withOpacity(0.9),
                fontSize: (MediaQuery.of(context).size.width * 0.7) / 20,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget dispatchedOrder() {
    return Container(
      height: 20,
      width: (MediaQuery.of(context).size.width * 0.7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Order Status:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          Text(
            " Order Dispatched",
            style: TextStyle(
                color: Colors.green.withOpacity(0.9),
                fontSize: (MediaQuery.of(context).size.width * 0.7) / 20,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
