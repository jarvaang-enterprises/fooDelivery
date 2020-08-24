import 'package:fooddeliveryboiler/core/models/menuModel.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';

import '../../locator.dart';

class MenuModel extends BaseModel {
  Network _network = locator<Network>();
  LocalStorage localStorage = locator<LocalStorage>();

  Map<String, MenuData> _orderData = Map<String, MenuData>();

  List<MenuData> _menuData;

  String errorMessage;

  get menuData => _menuData;

  set menuData(data) => _menuData = data;

  dynamic newOrder() async {
    setViewState(ViewState.Busy);
    await Future.delayed(Duration(seconds: 2));
    setViewState(ViewState.Idle);
  }

  addOrder(MenuData data) {
    if (_orderData[data.sId] != null) {
      _orderData[data.sId].totalItems++;
    } else {
      _orderData[data.sId] = data;
      _orderData[data.sId].totalItems = 1;
    }

    notifyListeners();
  }

  removeOrder(MenuData data) {
    if (_orderData[data.sId] != null) {
      if (_orderData[data.sId].totalItems == 1) {
        _orderData.remove(data.sId);
      } else {
        _orderData[data.sId].totalItems--;
      }
    } else {
      throw new Exception("No order to remove");
    }

    notifyListeners();
  }

  getItemCount(data) {
    if (_orderData[data.sId] == null) {
      return 0;
    } else {
      return _orderData[data.sId].totalItems;
    }
  }

  getCart() => _orderData;

  dynamic getMenuData(restaurantId) async {
    setViewState(ViewState.Busy);

    var response = await _network.get(
        "/qeats/restaurant/$restaurantId/menu?token=wearegoingtorockit",
        bearer: 'wearegoingtorockit');

    if (response['success']) {
      var menuDataList = List<MenuData>();
      for (var data in response['res']) {
        menuDataList.add(MenuData.fromJson(data));
      }
      menuData = menuDataList;

      setViewState(ViewState.Idle);
      return true;
    }
  }

  Future<dynamic> sendNewOrder(jsonData) async {
    Map<String, String> reqHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'x-api-key':
          '' // TODO: Must implement the User class to also hold the x-api-key/token
    };

    var response = await _network.post("/qeats/orders?token=wearegoingtorockit",
        body: jsonData, headers: reqHeaders);
    print(response);

    return response;
  }
}
