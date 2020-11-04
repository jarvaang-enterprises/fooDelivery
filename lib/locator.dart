import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/viewModels/checkout.dart';
import 'package:fooddeliveryboiler/core/viewModels/delivery.dart';
import 'package:fooddeliveryboiler/core/viewModels/home.dart';
import 'package:fooddeliveryboiler/core/viewModels/order.dart';
import 'package:fooddeliveryboiler/core/viewModels/orderScreen.dart';
import 'package:fooddeliveryboiler/core/viewModels/profile.dart';
import 'package:get_it/get_it.dart';

import 'core/services/networking.dart';
import 'core/viewModels/loginModel.dart';
import 'core/viewModels/menu.dart';

GetIt locator = GetIt();

Future setupLocator() async {
  locator.registerFactory(() => LoginModel());

  var instance = await LocalStorage.getInstance();
  locator.registerSingleton<LocalStorage>(instance);

  locator.registerLazySingleton(() => Network());

  locator.registerFactory(() => HomeModel());

  locator.registerFactory(() => MenuModel());

  locator.registerFactory(() => OrderModel());

  locator.registerFactory(() => OrderScreen());

  locator.registerFactory(() => DeliveryModel());

  locator.registerFactory(() => ProfileModel());

  locator.registerFactory(() => CheckoutModel());
}
