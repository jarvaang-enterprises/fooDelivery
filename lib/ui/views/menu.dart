import 'dart:async';
import 'dart:convert';

import 'package:device_id/device_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fooddeliveryboiler/core/enums/constants.dart';
import 'package:fooddeliveryboiler/core/models/charge_response.dart';
import 'package:fooddeliveryboiler/core/models/menuModel.dart';
import 'package:fooddeliveryboiler/core/models/mobile_money_payload.dart';
import 'package:fooddeliveryboiler/core/models/requery_response.dart';
import 'package:fooddeliveryboiler/core/models/userModel.dart';
import 'package:fooddeliveryboiler/core/services/networking.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/core/viewModels/menu.dart';
import 'package:fooddeliveryboiler/locator.dart';
import 'package:fooddeliveryboiler/ui/views/base.dart';
import 'package:fooddeliveryboiler/ui/views/checkout.dart';
import 'package:fooddeliveryboiler/ui/views/delivery.dart';
import 'package:fooddeliveryboiler/ui/views/login.dart';
import 'package:fooddeliveryboiler/ui/views/orderConfim.dart';
import 'package:fooddeliveryboiler/ui/widgets/appBar.dart';
import 'package:fooddeliveryboiler/ui/widgets/drawer.dart';
import 'package:fooddeliveryboiler/ui/widgets/menuItem.dart';

class Menu extends StatefulWidget {
  final String restaurantId;

  Menu({this.restaurantId});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool orderNowButton = false;
  TextEditingController search = new TextEditingController();
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  final _phoneController = new TextEditingController();
  final _otpController = new TextEditingController();
  Network _network = locator<Network>();
  String _phoneErrorText;
  String _otpErrorText;
  // ignore: non_constant_identifier_names
  bool payment_processed = false;
  var _userDismissedDialog = false,
      _requeryUrl,
      _recaptchaUrl = '',
      verifying = false,
      // ignore: unused_field
      _queryCount = 0,
      _reQueryTxCount = 0,
      totalCost = 0,
      _waitDuration = 0;

  String _validatePhoneNumber(String phone) {
    String pattern = r'(^[0+](?:[0-9] ?){6,14}[0-9]$)';
    RegExp regExp = RegExp(pattern);
    if (phone.length == 0) {
      return "Enter mobile number";
    } else if (!regExp.hasMatch(phone.trim())) {
      return "Enter a valid MTN Mobile Money Number";
    }
    return null;
  }

  String _addCountryCodeSuffixToNumber(String countryCode, String phoneNumber) {
    if (phoneNumber[0] == '0') {
      return countryCode + phoneNumber.substring(1);
    }
    return phoneNumber;
  }

  void _dismissMobileMoneyDialog(bool dismissedByUser) {
    _userDismissedDialog = dismissedByUser;
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }
  }

  _showToast(BuildContext context, String textInput, {Color backgroundColor}) {
    if (mounted) {
      Fluttertoast.showToast(
        msg: textInput,
        backgroundColor: backgroundColor ?? Colors.black87,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<void> _showMobileMoneyProcessingDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mobile Money'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    'A push notification is being sent to your phone, please complete the transaction by entering your pin.'),
                SizedBox(
                  height: 8.0,
                ),
                SpinKitThreeBounce(
                  color: Colors.grey.shade900,
                  size: 20.0,
                )
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: Text(
                'CANCEL',
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () {
                _dismissMobileMoneyDialog(true);
              },
            )
          ],
        );
      },
    );
  }

  void _requeryTx(String txRef) async {
    if (!_userDismissedDialog && _reQueryTxCount < MAX_REQUERY_COUNT) {
      _reQueryTxCount++;
      final requeryRequestBody = {
        "PBFPubKey": PUBLIC_KEY,
        'tx_ref': txRef,
        'SECKEY': SEC_KEY
      };
      var url = LIVE ? ENDPOINT : TEST_ENDPOINT;
      var response = await _network.postToEndpointWithBody(
          url + REQUERY_ENDPOINT, requeryRequestBody);
      if (response == null) {
        _showToast(
            context, 'Payment Processing failed. Please try again later.');
        _dismissMobileMoneyDialog(false);
      } else {
        var requeryResponse = RequeryResponse.fromJson(response);
        if (requeryResponse.data == null) {
          _showToast(
              context, 'Payment Processing failed. Please try again later.');
          _dismissMobileMoneyDialog(false);
        } else if (requeryResponse.data.chargeResponseCode == '02' &&
            requeryResponse.data.status != 'failed') {
          _onPollingComplete(txRef);
        } else if (requeryResponse.data.chargeResponseCode == '00' ||
            requeryResponse.data.status == 'successful') {
          _dismissMobileMoneyDialog(false);
          _onPaymentSuccessfull();
        } else {
          _showToast(
              context, 'Payment Processing failed. Please try again later.');
          _dismissMobileMoneyDialog(false);
        }
      }
    } else if (_reQueryTxCount == MAX_REQUERY_COUNT) {
      _showToast(context, 'Payment Processing failed. Please try again later.');
      _dismissMobileMoneyDialog(false);
    }
  }

  void _chargeAgainAfterDuration(String url) async {
    if (!_userDismissedDialog) {
      _queryCount++;
      // print('Charging Again after $_queryCount Charge calls');
      var response = await _network.getResponseFromEndpoint(url);

      if (response == null) {
        _showToast(
            context, 'Payment Processing failed. Please try again later.');
        _dismissMobileMoneyDialog(false);
      } else
        _continueProcessingAfterCharge(response, false);
    }
  }

  void _onPollingComplete(String flwRef) {
    Timer(Duration(milliseconds: 5000), () {
      _requeryTx(flwRef);
    });
  }

  void _showPaymentSuccessfulDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16.0),
                child: Icon(
                  Icons.done,
                  color: Colors.blue,
                  size: MediaQuery.of(context).size.width / 6,
                ),
              ),
              Text(
                'Payment completed!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24.0),
              ),
              SizedBox(
                height: 12.0,
              ),
              Text(
                'Your order is successfully paid!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(
                height: 12.0,
              ),
              GestureDetector(
                onTap: () {
                  //Proceed to the next action after successful payment
                  _phoneController.text = '';
                  _dismissMobileMoneyDialog(false);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.only(
                      left: 32.0, right: 32.0, top: 8.0, bottom: 16.0),
                  padding:
                      EdgeInsets.symmetric(horizontal: 36.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    'Proceed',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ),
              )
            ],
          );
        });
  }

  void _onPaymentSuccessfull() async {
    setState(() {
      payment_processed = true;
    });
    _showPaymentSuccessfulDialog();
  }

  _verifyOTP() async {
    var completeUrl = _recaptchaUrl + "?solution=" + _otpController.text;
    var response = await _network.postVerifyOTP(completeUrl);
    var chargeResponse = ChargeResponse.fromJson(response, true);
    _dismissMobileMoneyDialog(false);
    _otpController.text = '';
    return chargeResponse;
  }

  void _continueProcessingAfterCharge(
      Map<String, dynamic> response, bool firstQuery) async {
    var chargeResponse = ChargeResponse.fromJson(response, firstQuery);
    if (chargeResponse.data.recaptchaLink != null) {
      _recaptchaUrl = chargeResponse.data.recaptchaLink;
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'OTP Verify',
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('Input received OTP below'),
                    TextField(
                      keyboardType: TextInputType.phone,
                      controller: _otpController,
                      decoration: InputDecoration(
                          errorText: _otpErrorText,
                          hintText: 'OTP',
                          hintStyle: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey.shade500,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            borderSide: BorderSide.none,
                          )),
                      onSubmitted: (value) {
                        print(value);
                      },
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (_otpController.text != null &&
                            _otpController.text.length == 6)
                          chargeResponse = await _verifyOTP();
                        else
                          _showToast(context, "Enter OTP");
                      },
                      child: Container(
                        child: Text(
                          'Verify',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        margin: EdgeInsets.only(
                            left: 32.0, right: 32.0, top: 8.0, bottom: 16.0),
                        padding: EdgeInsets.symmetric(
                            horizontal: 36.0, vertical: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.green.shade900,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
    }
    if (chargeResponse.data != null && chargeResponse.data.flwRef != null) {
      Timer(Duration(milliseconds: 1000),
          () => _requeryTx(chargeResponse.data.txRef));
    } else {
      if (chargeResponse.status == 'success' &&
          chargeResponse.data.ping_url != null) {
        _waitDuration = chargeResponse.data.wait;
        _requeryUrl = chargeResponse.data.ping_url;
        Timer(Duration(microseconds: chargeResponse.data.wait), () {
          _chargeAgainAfterDuration(chargeResponse.data.ping_url);
        });
      } else if (chargeResponse.status == 'success' &&
          chargeResponse.data.status == 'pending') {
        Timer(Duration(milliseconds: _waitDuration), () {
          _chargeAgainAfterDuration(_requeryUrl);
        });
      } else if (chargeResponse.status == 'success' &&
          chargeResponse.data.status == 'completed' &&
          chargeResponse.data.flwRef != null) {
        _requeryTx(chargeResponse.data.txRef);
      } else {
        _showToast(
            context, 'Payment processing failed. Please try again later.');
        _dismissMobileMoneyDialog(false);
      }
    }
  }

  void _initiateMobileMoneyPaymentFlow(String phone, UserData user) async {
    _userDismissedDialog = false;
    String deviceId = await DeviceId.getID;

    MobileMoneyPayload payload = MobileMoneyPayload(
      PBFPubKey: PUBLIC_KEY,
      currency: currency,
      payment_type: paymentType,
      country: receivingCountry,
      amount: '$totalCost',
      email: user.email,
      phonenumber: phone,
      network: network,
      firstname: user.displayName.split(' ')[0],
      lastname: user.displayName.split(' ')[1],
      txRef: "MC-" + DateTime.now().toString(),
      orderRef: "MC-" + DateTime.now().toString(),
      is_mobile_money_ug: '1',
      device_fingerprint: deviceId,
      redirect_url: WEB_HOOK_3DS,
    );
    var requestBody = payload.encryptJsonPayload(ENCRYPTION_KEY, PUBLIC_KEY);
    var url = LIVE ? ENDPOINT : TEST_ENDPOINT;
    var response = await _network.postToEndpointWithBody(
        '$url$CHARGE_ENDPOINT?use_polling=1', requestBody);

    if (response == null) {
      _showToast(context, 'Payment processing failed. Please try again later.');
      _dismissMobileMoneyDialog(false);
    } else {
      _continueProcessingAfterCharge(response, true);
    }
  }

  void _processMtnMM(UserData user) {
    _phoneErrorText = '';
    if (_validatePhoneNumber(_phoneController.text) != null) {
      setState(() {
        _phoneErrorText = _validatePhoneNumber(_phoneController.text);
      });
      return;
    }
    var phone = _addCountryCodeSuffixToNumber('+256', _phoneController.text);
    _showMobileMoneyProcessingDialog();
    _initiateMobileMoneyPaymentFlow(phone, user);
  }

  /// Make order
  /// Responsible for handling new order details
  dynamic sendNewOrder(MenuModel model, context) async {
    setState(() {
      orderNowButton = true;
    });

    Map<String, MenuData> _cart = model.getCart();

    String jsonStr =
        """{"userId": "${model.user.uID}","restaurantId":"${widget.restaurantId}","items": []}""";

    var result = json.decode(jsonStr);
    _cart.forEach((key, value) {
      result['items'].add(value);
    });

    var r;
    var delData = model.storage.delivery;
    if (delData == null) {
      await model.getDelivery();
    }
    Route route;
    var checkout;
    var response;
    var payment;
    new Timer(new Duration(seconds: 3), () async {
      if (delData != null) {
        r = await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            // contentPadding: EdgeInsets.symmetric(horizontal: 1.0),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Delivery Details",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                height: MediaQuery.of(context).size.height / 2.5,
                width: double.infinity,
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Should we use your old delivery details for this order?",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      // height: 270,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "City: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            delData.name.toString(),
                            maxLines: 3,
                            // softWrap: true,
                            overflow: TextOverflow.fade,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                "Distance from Restaurant: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(delData.dist.toString() + " meters")
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () =>
                    {Navigator.of(context, rootNavigator: true).pop(false)},
                icon: Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                ),
                label: Text(
                  "No",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(true),
                icon: Icon(Icons.check),
                label: Text("Yes"),
              ),
            ],
          ),
        );
      }
      if (r != null && r == true) {
        route = MaterialPageRoute(
          builder: (context) => Checkout(
            cart: result,
          ),
        );
        checkout = await Navigator.push(context, route);
        if (checkout != null && checkout['items'].length != 0) {
          totalCost = int.parse(checkout['grandCost'].toString().split('.')[0]);
          payment = await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              // contentPadding: EdgeInsets.symmetric(horizontal: 1.0),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Order Confirmation",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SingleChildScrollView(
                  // height: MediaQuery.of(context).size.height / 2.2,
                  // width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Text(
                        "Initiate payment from MTN Mobile Money to confirm payment of UGX.$totalCost/=?",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextField(
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                        decoration: InputDecoration(
                            errorText: _phoneErrorText,
                            errorStyle: TextStyle(fontSize: 18.0),
                            hintText:
                                'Mobile Wallet Number e.g. 0772534215 or 0789651241',
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey.shade500,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none,
                            )),
                        onSubmitted: (value) {
                          print(value);
                        },
                      ),
                      GestureDetector(
                        onTap: () => _processMtnMM(model.user),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/MTNMMButtonIcon.png',
                                width: (MediaQuery.of(context).size.width / 4) -
                                    46,
                                height: 34,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'PAY',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(
                              left: 32.0, right: 32.0, top: 8.0, bottom: 16.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 26.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "OR",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Continue and await a call to confirm your order?",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop(null);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  label: Text(
                    "Delete Order",
                    textAlign: TextAlign.end,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                TextButton.icon(
                  onPressed: () {
                    _processMtnMM(model.user);
                    // Navigator.of(context, rootNavigator: true).pop(true);
                  },
                  icon: Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                  label: Text(
                    "Continue",
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
          if (payment != null) {
            response = await model.sendNewOrder(json.encode(checkout));
            if (response['success']) {
              _cart.clear();
              _key.currentState.showSnackBar(SnackBar(
                content: Text("Order Placed."),
              ));
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          OrderConfirm(orderId: response['data']['_id'])));
            } else {
              Fluttertoast.showToast(
                  msg: "Could not place order. Please Try again later.");
            }
          } else if (payment_processed == true) {
            checkout['paid'] = true;
            response = await model.sendNewOrder(json.encode(checkout));
            if (response['success']) {
              _cart.clear();
              Fluttertoast.showToast(msg: "Order Placed.");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          OrderConfirm(orderId: response['data']['_id'])));
            } else {
              Fluttertoast.showToast(
                  msg: "Could not place order. Please Try again later.");
            }
          } else {
            model.emptyCart();
            _key.currentState.showSnackBar(SnackBar(
              content: Text("Cart emptied, order not placed."),
            ));
          }
        } else {
          model.emptyCart();
          _key.currentState.showSnackBar(SnackBar(
            content: Text("Cart emptied, order not placed."),
          ));
        }
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeliveryScreen(),
          ),
        );
        if (model.storage.delivery != null) {
          route = MaterialPageRoute(
            builder: (context) => Checkout(
              cart: result,
            ),
          );
          checkout = await Navigator.push(context, route);
          if (checkout != null && checkout['items'].length != 0) {
            totalCost =
                int.parse(checkout['grandCost'].toString().split('.')[0]);
            payment = await showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                // contentPadding: EdgeInsets.symmetric(horizontal: 1.0),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Order Confirmation",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                content: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                    // height: MediaQuery.of(context).size.height / 2.2,
                    // width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Text(
                          "Await a call to confirm your order?",
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "OR",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                        Text(
                          "Initiate payment from MTN Mobile Money to confirm payment of UGX.$totalCost/=?",
                          textAlign: TextAlign.center,
                        ),
                        TextField(
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                          decoration: InputDecoration(
                              errorText: _phoneErrorText,
                              errorStyle: TextStyle(fontSize: 18.0),
                              hintText:
                                  'Mobile Wallet Number e.g. 0772534215 or 0789651241',
                              hintStyle: TextStyle(
                                fontSize: 15.0,
                                color: Colors.grey.shade500,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none,
                              )),
                          onSubmitted: (value) {
                            print(value);
                          },
                        ),
                        GestureDetector(
                          onTap: () => _processMtnMM(model.user),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/icons/MTNMMButtonIcon.png",
                                  width: MediaQuery.of(context).size.width / 4,
                                ),
                                Text(
                                  'PAY',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            margin: EdgeInsets.only(
                                left: 32.0,
                                right: 32.0,
                                top: 8.0,
                                bottom: 16.0),
                            padding: EdgeInsets.symmetric(
                                horizontal: 36.0, vertical: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        Text(
                          "Please continue to process your payment!",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton.icon(
                    onPressed: () {
                      _processMtnMM(model.user);
                      // Navigator.of(context, rootNavigator: true).pop(true);
                    },
                    icon: Icon(Icons.check),
                    label: Text("Yes"),
                  ),
                ],
              ),
            );
            response = await model.sendNewOrder(json.encode(checkout));
            if (response['success']) {
              _cart.clear();
              _key.currentState.showSnackBar(SnackBar(
                content: Text("Order Placed."),
              ));
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          OrderConfirm(orderId: response['data']['_id'])));
            } else {
              _key.currentState.showSnackBar(SnackBar(
                content: Text("Could not place order. Please Try again later."),
              ));
            }
          }
        }
      }
    });

    setState(() {
      orderNowButton = false;
    });

    return true;
  }

  void navigationPage() {
    Route route = MaterialPageRoute(builder: (context) => LoginPage());
    Navigator.pushReplacement(context, route);
  }

  _redirect() async {
    var _duration = new Duration(milliseconds: 500);
    return new Timer(_duration, navigationPage);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
    return BaseView<MenuModel>(
      onModelReady: (model) {
        model.getCurrentUser();
        model.getMenuData(widget.restaurantId);
      },
      builder: (context, model, child) {
        if (model.user == null) {
          _redirect();
          return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                heightFactor: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SpinKitChasingDots(
                      size: 30,
                      duration: new Duration(milliseconds: 800),
                      color: Color(0xfffd5f00),
                    ),
                  ],
                ),
              ));
        } else {
          if (!model.isSearch) {
            search.clear();
          } else {
            if (model.searchDataJson == null) {
              var snackbar = SnackBar(content: Text('Search return empty'));
              Scaffold.of(context).showSnackBar(snackbar);
            }
          }
          return Scaffold(
            appBar: appBar(context, backAvailable: true, model: model),
            key: _key,
            backgroundColor: Colors.white,
            drawerEnableOpenDragGesture: true,
            drawer: AppDrawer(
              model: model,
            ),
            body: model.state == ViewState.Busy
                ? Center(
                    child: SpinKitChasingDots(color: Color(0xfffd5f00)),
                  )
                : SafeArea(
                    child: Stack(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextField(
                              controller: search,
                              style: TextStyle(fontSize: 18),
                              onSubmitted: (String searchValue) {
                                if (searchValue != '') {
                                  model.isSearch = true;
                                  model.searchData(searchValue);
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(15, 17, 15, 15),
                                prefixIcon: Icon(
                                  Icons.search,
                                ),
                                hintText: "Search for dish",
                                hintStyle: TextStyle(fontSize: 18),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.4),
                                      width: 1.5),
                                ),
                              ),
                            ),
                          ),

                          // Menu Cards
                          /// Breakfast
                          Expanded(
                            child: ListView(
                                scrollDirection: Axis.vertical,
                                padding: const EdgeInsets.all(8.0),
                                children: [
                                  for (var data in !model.isSearch
                                      ? model.menuData
                                      : model.searchDataJson)
                                    MenuItemCard(data: data),
                                  SizedBox(height: 80),
                                ]),
                          ),
                        ],
                      ),
                      model.getCart().length == 0
                          ? Container()
                          : Positioned(
                              bottom: 0,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 80,
                                color: Colors.white,
                                child: RaisedButton(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
                                  padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
                                  onPressed: () {
                                    if (!orderNowButton) {
                                      sendNewOrder(model, context);
                                    }
                                  },
                                  color: Color(0xffFD792B),
                                  child: orderNowButton
                                      ? Container(
                                          width: 100,
                                          height: 22,
                                          alignment: Alignment.center,
                                          child: SpinKitDoubleBounce(
                                              color: Colors.white),
                                        )
                                      : Container(
                                          width: 100,
                                          height: 22,
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Order Now",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            )
                    ],
                  )),
          );
        }
      },
    );
  }
}
