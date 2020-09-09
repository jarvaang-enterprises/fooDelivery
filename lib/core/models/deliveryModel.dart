class DeliveryData {
  String uID;

  DeliveryData({this.uID});

  DeliveryData.fromJson(Map<String, dynamic> json) {
    uID = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.uID;

    return data;
  }
}
