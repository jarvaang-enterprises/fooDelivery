import 'package:fooddeliveryboiler/core/models/orderScreenModel.dart';
import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/loginModel.dart';
import 'package:fooddeliveryboiler/locator.dart';

class OrderScreen extends BaseModel {
  Network _network = locator<Network>();
  String modelName = "orderScreen";
  LocalStorage _storage = locator<LocalStorage>();
  LoginModel _loginModel = locator<LoginModel>();

  UserData _user;

  UserData get user => _user;

  void getCurrentUser() {
    setModelName(this.modelName);
    setStorage(_storage);
    _user = _storage.user;
  }

  LocalStorage get storage => _storage;

  List<OrderScreenModel> _orders;

  get orders => _orders;

  set orders(List<OrderScreenModel> orders) {
    _orders = orders;
    notifyListeners();
  }

  dynamic getOrders(userId) async {
    setViewState(ViewState.Busy);

    var response =
        await _network.get("/qeats/orders/$userId", apiKey: user.apiKey);

    if (response['success']) {
      _orders = new List<OrderScreenModel>();
      for (var i = 0; i < response['data'].length; i++) {
        var data = response['data'][i];
        OrderScreenModel orderScreen = OrderScreenModel.fromJson(data);
        _orders.add(orderScreen);
      }
    } else {
      print("Error");
    }

    setViewState(ViewState.Idle);
    return true;
  }

  dynamic refreshOrders() async {
    var response = await _network.get("/qeats/orders/" + user.uID,
        apiKey: user.apiKey ?? "");

    if (response['success']) {
      var data = response['data'];
      List<OrderScreenModel> d = new List<OrderScreenModel>();
      for (var i = 0; i < data.length; i++) {
        var dataO = response['data'][i];
        OrderScreenModel orderScreen = OrderScreenModel.fromJson(dataO);
        d.add(orderScreen);
      }
      orders = d;
    }

    return true;
  }

  dynamic cancelOrder(orderId) async {
    var response = await _network.patch(
        "/qeats/${user.uID}/order/$orderId/cancel-order?token=wearegoingtorockit",
        apiKey: user.apiKey);

    if (response['success']) {
      print(response);
      for (OrderScreenModel item in _orders) {
        print(item);
        if (item.sId == orderId) {
          item.status = "CANCELLED";
          notifyListeners();
        }
      }
    }

    return true;
  }
}
