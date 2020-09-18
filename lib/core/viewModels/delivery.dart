import 'package:fooddeliveryboiler/core/models/deliveryModel.dart';
import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/loginModel.dart';
import 'package:fooddeliveryboiler/locator.dart';

class DeliveryModel extends BaseModel {
  Network _network = locator<Network>();
  String modelName = "deliveryModel";
  LocalStorage _storage = locator<LocalStorage>();
  LoginModel _loginModel = locator<LoginModel>();

  UserData _user;
  DeliveryData _deliveryData;

  DeliveryData get deliveryData => _deliveryData;

  set deliveryData(DeliveryData deliveryData) {
    _deliveryData = deliveryData;
  }

  UserData get user => _user;

  void getCurrentUser() {
    setModelName(this.modelName);
    setStorage(_storage);
    _user = _storage.user;
    deliveryData = _storage.delivery;
  }

  LocalStorage get storage => _storage;

  void signOut() {
    _loginModel.signOut();
  }
}
