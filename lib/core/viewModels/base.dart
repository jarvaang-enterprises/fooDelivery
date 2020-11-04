import 'package:flutter/widgets.dart';
import 'package:fooddeliveryboiler/core/models/menuModel.dart';
import 'package:fooddeliveryboiler/core/services/localStorage.dart';
import 'package:fooddeliveryboiler/locator.dart';

/// Viable states for our application equivalent to true or false
enum ViewState { Idle, Busy }

/// The base class for all Models which represent activities in android
/// programming.
///
/// @holds - The abstract variables required by all models and can be used at will
class BaseModel extends ChangeNotifier {
  /// Is used to keep the current view's
  /// state up-to-date with out breaking anythin
  ViewState _state = ViewState.Idle;

  /// Is used for counting number of retries in any network request
  /// so that relevant messages can be returned to the user
  int _counter = 0;
  String selected = "";
  String _modelName;
  LocalStorage _storage = locator<LocalStorage>();
  String store = "32.499719,0.291852";
  var costPerKm = 2500.00;

  Map<String, MenuData> _orderData = Map<String, MenuData>();

  addOrder(MenuData data) {
    if (_orderData[data.sId] != null) {
      _orderData[data.sId].totalItems++;
    } else {
      _orderData[data.sId] = data;
      _orderData[data.sId].totalItems = 1;
    }

    notifyListeners();
  }

  emptyCart() {
    _orderData = Map<String, MenuData>();
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

  /// @returns ViewState
  ViewState get state => _state;

  void setModelName(String mN) {
    _modelName = mN;
  }

  String get modelName => _modelName;

  void setStorage(LocalStorage store) {
    _storage = store;
  }

  LocalStorage get storage => _storage;

  /// Is used to set the state of a model
  ///
  /// @params - ViewState viewState
  ///
  /// @returns void
  void setViewState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  /// @resturns - counter
  int get counter => _counter;

  /// Is used to increment the retry counter of the current view or android activity
  void incrCounter() {
    _counter += 1;
    notifyListeners();
  }
}
