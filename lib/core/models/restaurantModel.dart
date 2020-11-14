var cat = 0;

class RestaurantData {
  String sId;
  String name;
  String imageUrl;
  String latitude;
  String longitude;
  List<String> attributes;
  String opensAt;
  String closesAt;
  bool acceptingOrders;
  String category;

  RestaurantData({
    this.sId,
    this.name,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.attributes,
    this.opensAt,
    this.closesAt,
    this.acceptingOrders,
    this.category,
  });

  RestaurantData.fromJson(Map<String, dynamic> json) {
    sId = json['restaurantId'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    latitude = json['latitude'].toString();
    longitude = json['longitude'].toString();
    attributes = json['attributes'].cast<String>();
    opensAt = json['opensAt'];
    closesAt = json['closesAt'];
    acceptingOrders =
        json['accepting_orders'] == null ? true : json['accepting_orders'];
    category = categories[1];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['restaurantId'] = this.sId;
    data['name'] = this.name;
    data['imageUrl'] = this.imageUrl;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['attributes'] = this.attributes;
    data['opensAt'] = this.opensAt;
    data['closesAt'] = this.closesAt;
    data['accepting_orders'] = this.acceptingOrders;

    return data;
  }
}

var categories = [
  'Breakfast',
  'Lunch',
  'Supper',
  'Snacks',
];
