class MenuData {
  String sId;
  String restaurantId;
  String name;
  String imageUrl;
  int price;
  String description;
  bool isAvailable;
  int preprationTime;
  List<String> attributes;
  int totalItems;
  int inInventory;

  MenuData(
      {this.sId,
      this.restaurantId,
      this.name,
      this.imageUrl,
      this.price,
      this.description,
      this.isAvailable,
      this.preprationTime,
      this.attributes,
      this.totalItems,
      this.inInventory});

  MenuData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    restaurantId = json['restaurantId'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    price = json['price'];
    description = json['description'];
    isAvailable = json['is_available'];
    preprationTime = json['prepration_time'];
    attributes = json['attributes'].cast<String>();
    totalItems = json['total_items'] ?? 0;
    inInventory = json['in_inventory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['restaurantId'] = this.restaurantId;
    data['name'] = this.name;
    data['imageUrl'] = this.imageUrl;
    data['price'] = this.price;
    data['description'] = this.description;
    data['is_available'] = this.isAvailable;
    data['prepration_time'] = this.preprationTime;
    data['attributes'] = this.attributes;
    data['total_items'] = this.totalItems;
    data['in_inventory'] = this.inInventory;
    return data;
  }
}
