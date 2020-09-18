import 'package:fooddeliveryboiler/core/models/orderModel.dart';
import 'package:intl/intl.dart';

class OrderScreenModel {
  List<Items> items;
  String sId;
  String rId;
  String userId;
  int total;
  String date;
  String status;

  OrderScreenModel(
      {this.sId, this.rId, this.userId, this.items, this.total, this.status});

  OrderScreenModel.fromJson(Map<String, dynamic> json) {
    sId = json['id'];
    rId = json['restaurantId'];
    userId = json['userId'];
    if (json['items'] != null) {
      items = new List<Items>();
      json['items'].forEach((v) {
        items.add(new Items.fromJson(v));
      });
    }
    total = json['total'];
    status = json['status'];
    date = json['ordered_on'] == null
        ? DateFormat('EEE, d MM yyyy kk:mm:ss').format(DateTime.now())
        : DateFormat('EEE, d MM yyyy kk:mm:ss').format(DateTime(
            int.parse(json['ordered_on'].toString().split('-')[0]),
            int.parse(json['ordered_on'].toString().split('-')[1]),
            int.parse(
                json['ordered_on'].toString().split('-')[2].substring(0, 1)),
            int.parse(json['ordered_on']
                .toString()
                .split('-')[2]
                .substring(3)
                .split(":")[0]),
            int.parse(json['ordered_on']
                .toString()
                .split('-')[2]
                .substring(3)
                .split(":")[1]),
            int.parse(json['ordered_on']
                .toString()
                .split('-')[2]
                .substring(3)
                .split(":")[2]
                .substring(0, 1)),
          ));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.sId;
    data['userId'] = this.userId;
    data['restaurantId'] = this.rId;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    data['status'] = this.status;
    return data;
  }
}
