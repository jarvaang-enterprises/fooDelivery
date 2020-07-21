import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/viewModels/home.dart';
import 'package:fooddeliveryboiler/core/viewModels/order.dart';
import 'package:get_it/get_it.dart';

import 'core/services/networking.dart';
import 'core/viewModels/loginModel.dart';
import 'core/viewModels/menu.dart';

GetIt locator = GetIt();

// TODO: Finish setupLocator

Future setupLocator() async {
  locator.registerFactory(() => LoginModel());

  var instance = await LocalStorage.getInstance();
  locator.registerSingleton<LocalStorage>(instance);

  locator.registerLazySingleton(() => Network());

  locator.registerFactory(() => HomeModel());

  locator.registerFactory(() => MenuModel());

  locator.registerFactory(() => OrderModel());
}
