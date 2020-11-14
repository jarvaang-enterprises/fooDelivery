import 'dart:async';

import 'package:fooddeliveryboiler/core/models/deliveryModel.dart';
import 'package:fooddeliveryboiler/core/models/restaurantModel.dart';
import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/loginModel.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';

import '../../locator.dart';

class HomeModel extends BaseModel {
  Network _network = locator<Network>();
  String modelName = "homeModal";
  LocalStorage _storage = locator<LocalStorage>();
  LoginModel _loginModel = locator<LoginModel>();
  Network get network => _network;

  UserData _user;
  DeliveryData _deliveryData;

  // ignore: unnecessary_getters_setters
  DeliveryData get deliveryData => _deliveryData;

  // ignore: unnecessary_getters_setters
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

  List<RestaurantData> _homeDataJson;
  List<RestaurantData> _searchDataJson;
  List<RestaurantData> _categoryDataJson;

  // ignore: unnecessary_getters_setters
  List<RestaurantData> get searchDataJson => _searchDataJson;
  List<RestaurantData> get categoryDataJson => _categoryDataJson;

  // ignore: unnecessary_getters_setters
  set searchDataJson(List<RestaurantData> searchDataJson) {
    _searchDataJson = searchDataJson;
  }

  set categoryDataJson(List<RestaurantData> categoryData) {
    _categoryDataJson = categoryData;
  }

  get homeDataJson => _homeDataJson;

  bool _isSearch = false;
  bool isCat = false;

  // ignore: unnecessary_getters_setters
  bool get isSearch => _isSearch;

  // ignore: unnecessary_getters_setters
  set isSearch(bool isSearch) {
    _isSearch = isSearch;
  }

  set homeDataJson(data) => _homeDataJson = data;

  void categoryChange(Choice _select) {
    setViewState(ViewState.Busy);
    print(_select.title);
    var num = 0;

    var _category = List<RestaurantData>();
    for (RestaurantData data in this.homeDataJson) {
      if (data.category == _select.title) {
        _category.add(data);
        num++;
      }
      if (num == 10) break;
    }
    if (_category.length != 0) {
      categoryDataJson = _category;
    } else
      isCat = false;
    Timer(Duration(seconds: 2), () => setViewState(ViewState.Idle));
  }

  startTime() async {
    var _duration = new Duration(seconds: 5);
    incrCounter();
    return new Timer(_duration, getRestaurantData);
  }

  dynamic getRestaurantData() async {
    setViewState(ViewState.Busy);
    try {
      var response = await _network.get(
          "/qeats/restaurants?latitude=28.50&longitude=70.50&token=wearegoingtorockit");

      if (response['success']) {
        var restaurantData = List<RestaurantData>();
        for (var data in response['data']) {
          restaurantData.add(RestaurantData.fromJson(data));
        }
        homeDataJson = restaurantData;
      }

      setViewState(ViewState.Idle);
      return true;
    } catch (err) {
      print(err);
      startTime();
    }
  }

  void refresh() {
    setViewState(ViewState.Busy);
    setViewState(ViewState.Idle);
  }

  void searchData(String searchValue) {
    setViewState(ViewState.Busy);
    var _searchDataJ = List<RestaurantData>();
    for (RestaurantData data in this.homeDataJson) {
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

  void signOut() {
    _loginModel.signOut();
  }
}
