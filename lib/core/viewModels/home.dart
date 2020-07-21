import 'package:fooddeliveryboiler/core/models/restaurantModel.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';

import '../../locator.dart';

class HomeModel extends BaseModel {
  Network _network = locator<Network>();

  List<RestaurantData> _homeDataJson;

  get homeDataJson => _homeDataJson;

  set homeDataJson(data) => _homeDataJson = data;

  dynamic getRestaurantData() async {
    setViewState(ViewState.Busy);

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
  }
}
