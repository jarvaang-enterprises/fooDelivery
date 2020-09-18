import 'package:fooddeliveryboiler/core/models/orderModel.dart';
import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/loginModel.dart';
import 'package:fooddeliveryboiler/locator.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';

class OrderModel extends BaseModel {
  Network _network = locator<Network>();
  String modelName = "order_confirm";
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

  OrderData _orderData = OrderData();

  get orderData => _orderData;

  set orderData(OrderData data) {
    _orderData = data;
    notifyListeners();
  }

  dynamic getOrderData(orderId) async {
    setViewState(ViewState.Busy);
    var response = await _network.get(
        "/qeats/${user.uID}/order/$orderId?token=wearegoingtorockit",
        apiKey: user.apiKey);

    if (response['success']) {
      OrderData order = OrderData.fromJson(response['data']);

      orderData = order;
    } else
      print("Error");

    setViewState(ViewState.Idle);

    return true;
  }

  dynamic refreshOrderData(orderId) async {
    var response = await _network.get(
        "/qeats/${user.uID}/order/$orderId?token=wearegoingtorockit",
        apiKey: user.apiKey);

    if (response['success']) {
      var order = OrderData.fromJson(response['data']);
      orderData = order;
    }

    return true;
  }

  dynamic cancelOrder(orderId) async {
    var response = await _network.patch(
        "/qeats/${user.uID}/order/$orderId/cancel-order?token=wearegoingtorockit",
        apiKey: user.apiKey);

    if (response['success']) {
      orderData.status = "CANCELLED";
      notifyListeners();

      return true;
    }
    return false;
  }
}
