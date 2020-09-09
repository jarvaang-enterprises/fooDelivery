import 'package:fooddeliveryboiler/core/models/menuModel.dart';
import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/loginModel.dart';

import '../../locator.dart';

class MenuModel extends BaseModel {
  Network _network = locator<Network>();
  String modelName = "menuModel";
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

  Map<String, MenuData> _orderData = Map<String, MenuData>();

  List<MenuData> _menuData;

  String errorMessage;

  get menuData => _menuData;

  set menuData(data) => _menuData = data;

  bool _isSearch = false;

  bool get isSearch => _isSearch;

  set isSearch(bool isSearch) {
    _isSearch = isSearch;
  }

  List<MenuData> _searchDataJson;

  List<MenuData> get searchDataJson => _searchDataJson;

  set searchDataJson(List<MenuData> searchDataJson) {
    _searchDataJson = searchDataJson;
  }

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
        bearer: 'wearegoingtorockit',
        apiKey: user.apiKey);

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

  void searchData(String searchValue) {
    setViewState(ViewState.Busy);
    var _searchDataJ = List<MenuData>();
    for (MenuData data in this.menuData) {
      if (data.name.toLowerCase().contains(searchValue.toLowerCase())) {
        _searchDataJ.add(data);
      }
    }
    if (_searchDataJ.length != 0) {
      searchDataJson = _searchDataJ;
    } else {
      isSearch = false;
    }
    setViewState(ViewState.Idle);
  }

  Future<dynamic> sendNewOrder(jsonData) async {
    Map<String, String> reqHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'x-api-key': user.apiKey
    };

    var response = await _network.post("/qeats/orders?token=wearegoingtorockit",
        body: jsonData, headers: reqHeaders);
    print(response);

    return response;
  }
}
