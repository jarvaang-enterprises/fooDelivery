class UserData {
  String uID;
  String displayName;
  String email;
  int permissionLevel;
  int otherPermissionLevel;
  String photoUrl;
  String apiKey;
  String tel;
  bool telConf;

  UserData(
      {this.uID,
      this.displayName,
      this.email,
      this.permissionLevel,
      this.otherPermissionLevel,
      this.photoUrl,
      this.apiKey,
      this.tel,
      this.telConf});

  UserData.fromJson(Map<String, dynamic> json) {
    uID = json['accessId'];
    displayName = json['displayName'];
    email = json['email'];
    permissionLevel = json['permissionLevel'];
    otherPermissionLevel = json['otherPermissionLevel'];
    photoUrl = json['photoUrl'];
    apiKey = json['accessToken'];
    tel = json['tel'] == null ? "" : json['tel'];
    telConf =
        json['tel_confirmed'] != 'undefined' ? json['tel_confirmed'] : false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accessId'] = this.uID;
    data['displayName'] = this.displayName;
    data['email'] = this.email;
    data['otherPermissionLevel'] = this.otherPermissionLevel;
    data['permissionLevel'] = this.permissionLevel;
    data['photoUrl'] = this.photoUrl;
    data['accessToken'] = this.apiKey;
    data['tel'] = this.tel;
    data['tel_confirmed'] = this.telConf;

    return data;
  }
}
