class DeliveryData {
  String uID;
  String dId;
  double long;
  double lat;
  String dist;
  String name;

  DeliveryData({this.uID, this.dId, this.long, this.lat, this.dist, this.name});

  DeliveryData.fromJson(Map<String, dynamic> json) {
    uID = json['userId'];
    dId = json['id'];
    long = json['longitude'];
    lat = json['latitude'];
    dist = json['distance'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.uID;
    data['id'] = this.dId;
    data['longitude'] = this.long;
    data['latitude'] = this.lat;
    data['distance'] = this.dist;
    data['name'] = this.name;

    return data;
  }
}
