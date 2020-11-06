import 'dart:convert';

import 'package:fooddeliveryboiler/core/models/deliveryModel.dart';
import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/loginModel.dart';
import 'package:fooddeliveryboiler/locator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';

class DeliveryModel extends BaseModel {
  Network _network = locator<Network>();
  String modelName = "deliveryModel";
  LocalStorage _storage = locator<LocalStorage>();
  LoginModel _loginModel = locator<LoginModel>();
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final Permission _permission = Permission.locationWhenInUse;

  UserData _user;
  DeliveryData _deliveryData;
  Position _currentPosition;
  String _currentAddress;

  String get currentAddress => _currentAddress;

  DeliveryData get deliveryData => _deliveryData;

  set deliveryData(DeliveryData deliveryData) {
    _deliveryData = deliveryData;
  }

  UserData get user => _user;

  void getCurrentUser() {
    setModelName(this.modelName);
    setStorage(_storage);
    _user = _storage.user;
    deliveryData = _storage.delivery;
    if (deliveryData == null) {
      _getCurrentLocation(geolocator);
    }
  }

  void getCurrentLoction() => _getCurrentLocation(geolocator);

  _getCurrentLocation(Geolocator geolocator) async {
    var status = await geolocator.checkGeolocationPermissionStatus();
    if (await geolocator.isLocationServiceEnabled()) {
      if (status == GeolocationStatus.granted) {
        geolocator
            .getCurrentPosition(
                desiredAccuracy: LocationAccuracy.bestForNavigation)
            .then((position) async {
          _currentPosition = position;
          await _getAddressFromLatLng(geolocator);
          _saveDeliveryDetails();
        }).catchError((onError) => {print(onError)});
      } else if (status == GeolocationStatus.denied) {
        // Take user to permission settings
        final status = await _permission.request();
        if (status.isGranted) {
          geolocator
              .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
              .then((position) async {
            _currentPosition = position;
            await _getAddressFromLatLng(geolocator);
            _saveDeliveryDetails();
          }).catchError((onError) => {print(onError)});
        }
      } else if (status == GeolocationStatus.disabled) {
        // Take user to location page
        setViewState(ViewState.Busy);
        await AppSettings.openLocationSettings();
        setViewState(ViewState.Idle);
      } else if (status == GeolocationStatus.restricted) {
      } else if (status == GeolocationStatus.unknown) {
        // Unknown {}
      }
    } else {
      setViewState(ViewState.Busy);
      await AppSettings.openLocationSettings();
      setViewState(ViewState.Idle);
    }
  }

  _saveDeliveryDetails() {
    Map<String, String> reqHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'x-api-key': _user.apiKey
    };
    var lat = _currentPosition.latitude;
    var long = _currentPosition.longitude;
    var name = _currentAddress;
    var dir_url = "https://us1.locationiq.com/v1/directions/driving";
    var api = "pk.29d2a47cd8841917da1e1c047156d34a";
    var cUrl = dir_url + '/$long,$lat;$store?key=' + api + '&overview=full';
    var resDist = http.get(cUrl);
    resDist.then((value) async {
      var data = jsonDecode(value.body);
      if (data['code'] == "Ok") {
        var ajaxData = {
          'longitude': long,
          'latitude': lat,
          'distance': data['routes'][0]['distance'],
          'name': _currentAddress
        };
        // setViewState(ViewState.Busy);
        var res = await _network.post('/user/' + _user.uID + '/delDetails',
            headers: reqHeaders, body: jsonEncode(ajaxData));
        deliveryData = DeliveryData.fromJson(res['data']);
        storage.delivery = deliveryData;
      }
    }).catchError((onError) {
      print(onError);
    }).whenComplete(() => setViewState(ViewState.Idle));
  }

  _getAddressFromLatLng(Geolocator g) async {
    var lat = _currentPosition.latitude;
    var long = _currentPosition.longitude;
    setViewState(ViewState.Busy);
    try {
      var rev_url = "https://us1.locationiq.com/v1/reverse.php";
      var api = "pk.29d2a47cd8841917da1e1c047156d34a";
      var completeUrl = rev_url +
          '?key=' +
          api +
          '&lat=' +
          lat.toString() +
          '&lon=' +
          long.toString() +
          '&format=json';
      try {
        var response = await http.get(completeUrl);
        var data = jsonDecode(response.body);
        var name = data['display_name'].split(',');
        _currentAddress = name[0] +
            ',' +
            name[1] +
            ',' +
            name[2] +
            ',' +
            name[3] +
            ',' +
            name[4] +
            ',' +
            name[6];
        // setViewState(ViewState.Idle);
      } catch (exc) {
        print(exc);
      }
      // List<Placemark> p = await g.placemarkFromCoordinates(
      //     _currentPosition.latitude, _currentPosition.longitude);
      // Placemark place = p[0];
      // _currentAddress =
      //     "${_currentPosition.latitude}, ${_currentPosition.longitude}, ${name}";
    } catch (e) {
      print(e);
    }
  }

  LocalStorage get storage => _storage;

  void signOut() {
    _loginModel.signOut();
  }
}
