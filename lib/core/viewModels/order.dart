import 'package:fooddeliveryboiler/core/models/orderModel.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/locator.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';

class OrderModel extends BaseModel {
  Network _network = locator<Network>();

  OrderData _orderData = OrderData();

  get orderData => _orderData;

  set orderData(OrderData data) {
    _orderData = data;
    notifyListeners();
  }

  dynamic getOrderData(orderId) async {
    setViewState(ViewState.Busy);

    var response =
        await _network.get("/qeats/order/$orderId?token=wearegoingtorockit");

    if (response['success']) {
      print(response);
      OrderData order = OrderData.fromJson(response['data']);

      orderData = order;
    } else
      print("Error");

    setViewState(ViewState.Idle);

    return true;
  }

  dynamic refreshOrderData(orderId) async {
    print("refreshing");
    var response =
        await _network.get("/qeats/order/$orderId?token=wearegoingtorockit");

    if (response['success']) {
      print(response);
      var order = OrderData.fromJson(response['data']);

      orderData = order;
    }

    return true;
  }

  dynamic cancelOrder(orderId) async {
    var response = await _network
        .get("/qeats/order/$orderId/cancel-order?token=wearegoingtorockit");

    if (response['success']) {
      print(response);
      orderData.status = "CANCELLED";
      notifyListeners();
    }

    return true;
  }
}
