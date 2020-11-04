import 'package:flutter/material.dart';
import 'package:fooddeliveryboiler/core/models/menuModel.dart';
import 'package:fooddeliveryboiler/core/viewModels/menu.dart';
import 'package:provider/provider.dart';

class MenuItemCard extends StatefulWidget {
  final MenuData data;
  MenuItemCard({this.data});

  @override
  _MenuItemCardState createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> {
  addItemCount(model) {
    setState(() {
      model.addOrder(widget.data);
    });
  }

  reduceItemCount(model) {
    setState(() {
      model.removeOrder(widget.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MenuModel>(context);
    return GestureDetector(
      onTap: () {
        // if (model.state == ViewState.Idle) {
        //   model.newOrder();
        // }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        foregroundDecoration: widget.data.isAvailable
            ? BoxDecoration()
            : BoxDecoration(
                color: Colors.grey, backgroundBlendMode: BlendMode.saturation),
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
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: "assets/images/food-load-7.gif",
                    image: widget.data.imageUrl),
              ),
              Container(
                // Menu item details
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                width: MediaQuery.of(context).size.width * 0.5,
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacer(
                      flex: 1,
                    ),
                    Text(
                      widget.data.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.data.description == null
                          ? ''
                          : widget.data.description,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        for (var attr in widget.data.attributes)
                          Container(
                            padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Text(
                              attr,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                      ],
                    ),
                    Spacer(
                      flex: 2,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.watch_later_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                          child: Text(
                            widget.data.preprationTime == null
                                ? '0' + 'min.'
                                : widget.data.preprationTime.toString() +
                                    'min.',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        )
                      ],
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$ ' + widget.data.price.toString(),
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
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
                                  if (widget.data.isAvailable) {
                                    reduceItemCount(model);
                                  }
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
                              model.getItemCount(widget.data) == 0
                                  ? Text(
                                      "ADD",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : Text(
                                      model
                                          .getItemCount(widget.data)
                                          .toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                              GestureDetector(
                                onTap: () {
                                  if (widget.data.isAvailable) {
                                    addItemCount(model);
                                  }
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
