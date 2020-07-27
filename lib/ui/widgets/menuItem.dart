import 'package:flutter/material.dart';
import 'package:fooddeliveryboiler/core/models/menuModel.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
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
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
