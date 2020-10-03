class DeliveryData {
  String uID;
  String dId;
  double long;
  double lat;
  String dist;

  DeliveryData({this.uID, this.dId, this.long, this.lat, this.dist});

  DeliveryData.fromJson(Map<String, dynamic> json) {
    uID = json['userId'];
    dId = json['id'];
    long = json['longitude'];
    lat = json['latitude'];
    dist = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.uID;
    data['id'] = this.dId;
    data['longitude'] = this.long;
    data['latitude'] = this.lat;
    data['distance'] = this.dist;

    return data;
  }
}
