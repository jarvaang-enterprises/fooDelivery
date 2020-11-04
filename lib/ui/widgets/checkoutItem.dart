import 'package:flutter/material.dart';
import 'package:fooddeliveryboiler/core/models/menuModel.dart';
import 'package:fooddeliveryboiler/core/viewModels/checkout.dart';
import 'package:provider/provider.dart';

class CheckoutItemCard extends StatefulWidget {
  final MenuData data;
  CheckoutItemCard({this.data});

  @override
  _CheckoutItemCardState createState() => _CheckoutItemCardState();
}

class _CheckoutItemCardState extends State<CheckoutItemCard> {
  addItemCount(model) {
    setState(() {
      model.incOrder(widget.data);
    });
  }

  reduceItemCount(model) {
    setState(() {
      model.decOrder(widget.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<CheckoutModel>(context);
    return GestureDetector(
      onTap: () {
        // if (model.state == ViewState.Idle) {
        //   model.newOrder();
        // }
      },
      child: Container(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              ClipRRect(
                // Menu Item Image
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: FadeInImage.assetNetwork(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: "assets/images/food-load-7.gif",
                  image: widget.data.imageUrl,
                ),
              ),
              Container(
                // Menu item details
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                width: MediaQuery.of(context).size.width * 0.5,
                height: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.data.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Cost: UGX ' + (widget.data.price).toString() + '/=',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.red.withOpacity(0.8),
                          ),
                          width: 130,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  reduceItemCount(model);
                                },
                                child: Container(
                                  width: 40,
                                  padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                                  child: Icon(
                                    Icons.remove,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                widget.data.totalItems.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  addItemCount(model);
                                },
                                child: Container(
                                  width: 40,
                                  padding: EdgeInsets.fromLTRB(0, 5, 10, 5),
                                  child: Icon(
                                    Icons.add,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Spacer(
                      flex: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
