import 'dart:async';

import 'package:fooddeliveryboiler/core/models/restaurantModel.dart';
import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/loginModel.dart';

import '../../locator.dart';

class HomeModel extends BaseModel {
  Network _network = locator<Network>();
  LocalStorage _storage = locator<LocalStorage>();
  LoginModel _loginModel = locator<LoginModel>();

  UserData _user;

  UserData get user => _user;

  void getCurrentUser() {
    _user = _storage.user;
  }

  List<RestaurantData> _homeDataJson;
  List<RestaurantData> _searchDataJson;

  List<RestaurantData> get searchDataJson => _searchDataJson;

  set searchDataJson(List<RestaurantData> searchDataJson) {
    _searchDataJson = searchDataJson;
  }

  get homeDataJson => _homeDataJson;

  bool _isSearch = false;

  bool get isSearch => _isSearch;

  set isSearch(bool isSearch) {
    _isSearch = isSearch;
  }

  set homeDataJson(data) => _homeDataJson = data;

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
