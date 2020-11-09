import 'package:fooddeliveryboiler/core/models/menuModel.dart';
import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/loginModel.dart';

import '../../locator.dart';

class CheckoutModel extends BaseModel {
  Network _network = locator<Network>();
  String modelName = "checkoutModel";
  LocalStorage _storage = locator<LocalStorage>();
  LoginModel _loginModel = locator<LoginModel>();

  Map<String, MenuData> _cart = new Map<String, MenuData>();

  UserData _user;
  var grandCost = 0.0;

  UserData get user => _user;

  void getCurrentUser() {
    setModelName(this.modelName);
    setStorage(_storage);
    _user = _storage.user;
  }

  LocalStorage get storage => _storage;

  void setCart(List<dynamic> data) {
    data.forEach((element) {
      _cart[element.sId] = element;
    });
  }

  Map<String, dynamic> get cart => _cart;

  void incOrder(MenuData data) {
    if (_cart[data.sId] != null) {
      _cart[data.sId].totalItems++;
    } else {
      _cart[data.sId] = data;
      _cart[data.sId].totalItems = 1;
    }

    notifyListeners();
  }

  void decOrder(MenuData data) {
    if (_cart[data.sId] != null) {
      if (_cart[data.sId].totalItems == 1) {
        _cart.remove(data.sId);
      } else {
        _cart[data.sId].totalItems--;
      }
    } else {
      throw new Exception("No order to remove");
    }

    notifyListeners();
  }
}
