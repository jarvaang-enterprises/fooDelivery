import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:fooddeliveryboiler/core/viewModels/loginModel.dart';
// import 'package:fooddeliveryboiler/locator.dart';
// import 'package:fooddeliveryboiler/ui/views/login.dart';
import 'package:http/http.dart' as http;

class Network {
  // BasicSetupServices _basicSetupServices = locator<BasicSetupServices>();

  final JsonDecoder _decoder = new JsonDecoder();

  // ignore: non_constant_identifier_names
  // static final BASE_URL = "http://192.168.56.1:5500";
  static final BASE_URL = "http://10.0.2.2:5500";
  // ignore: non_constant_identifier_names
  static final API_VERSION = '/api/v1';

  Future<dynamic> get(String url, {String bearer = '', String apiKey = ''}) {
    String completeUrl = BASE_URL + API_VERSION + url;
    if (bearer != '' || apiKey != null) {
      return http.get(completeUrl, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': apiKey,
        'Authorization': 'Bearer $bearer',
      }).then((http.Response response) {
        final String res = response.body;
        final int statusCode = response.statusCode;

        // if (statusCode < 200 || statusCode > 400 || json == null) {
        //   throw new Exception("Error while fetching data");
        // }
        try {
          return _decoder.convert(res);
        } catch (err) {
          return _decoder
              .convert("{\"success\": false, \"emsg\": \"An error occurred\"}");
        }
      });
    } else {
      return http.get(completeUrl).then((http.Response response) {
        final String res = response.body;
        final int statusCode = response.statusCode;

        // if (statusCode < 200 || statusCode > 400 || json == null) {
        //   throw new Exception("Error while fetching data");
        // }
        try {
          return _decoder.convert(res);
        } catch (err) {
          return _decoder
              .convert("{\"success\": false, \"emsg\": \"An error occurred\"}");
        }
      });
    }
  }

  /// Sends a patch request to the endpoint
  Future<dynamic> patch(String url, {String bearer = '', String apiKey = ''}) {
    String completeUrl = BASE_URL + API_VERSION + url;
    if (bearer != '' || apiKey != null) {
      return http.patch(completeUrl, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': apiKey,
        'Authorization': 'Bearer $bearer',
      }).then((http.Response response) {
        final String res = response.body;
        final int statusCode = response.statusCode;

        // if (statusCode < 200 || statusCode > 400 || json == null) {
        //   throw new Exception("Error while fetching data");
        // }
        try {
          return _decoder.convert(res);
        } catch (err) {
          print(err);
          return _decoder.convert("{\"success\": false, \"emsg\": \"$err\"}");
        }
      });
    } else {
      return http.patch(completeUrl).then((http.Response response) {
        final String res = response.body;
        final int statusCode = response.statusCode;

        // if (statusCode < 200 || statusCode > 400 || json == null) {
        //   throw new Exception("Error while fetching data");
        // }
        try {
          return _decoder.convert(res);
        } catch (err) {
          return _decoder
              .convert("{\"success\": false, \"emsg\": \"An error occurred\"}");
        }
      });
    }
  }

  Future<dynamic> post(String url, {Map headers, body, encoding}) {
    String completeUrl = BASE_URL + API_VERSION + url;
    return http
        .post(completeUrl, body: body, headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      // loginModel.loginRequired = true;

      if (statusCode == 401) {
        // Route route = MaterialPageRoute(builder: (context) => LoginPage());
        // _basicSetupServices.navigatorKey.currentState
        // .pushAndRemoveUntil(route, (Route<dynamic> route) => false);
        throw new Exception("Error while fetching data");
      }
      try {
        return _decoder.convert(res);
      } catch (err) {
        return _decoder
            .convert("{\"success\": false, \"emsg\": \"An error occurred\"}");
      }
    });
  }
}
