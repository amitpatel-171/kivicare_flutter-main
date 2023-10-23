// ignore_for_file: unused_local_variable, unnecessary_brace_in_string_interps, deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:kivicare_flutter/config.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/network/auth_repository.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

Map<String, String> buildHeaderTokens() {
  Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.cacheControlHeader: 'no-cache',
    HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
  };

  if (appStore.isLoggedIn) {
    header.putIfAbsent(HttpHeaders.authorizationHeader,
        () => 'Bearer ${getStringAsync(TOKEN)}');
  }
  log(jsonEncode(header));
  return header;
}

Uri buildBaseUrl(String endPoint) {
  Uri url = Uri.parse(endPoint);

  // Prefix the endPoint parameter with the BASE_URL constant
  if (!endPoint.startsWith('http')) {
    url = Uri.parse('${BASE_URL}$endPoint');
  }

  log('URL: ${url.toString()}');

  return url;
}

Future<Response> buildHttpResponse(String endPoint,
    {HttpMethod method = HttpMethod.GET, Map? request}) async {
  ///edited now

  if (await isNetworkAvailable()) {
    print("entered");
    var headers = buildHeaderTokens();
    Uri url = buildBaseUrl(endPoint);

    Response response;

    if (method == HttpMethod.POST) {
      print("ssed");
      log('Request: $request');
      // Response response = await buildHttpResponse(endPoint,
      //     method: HttpMethod.POST, request: request);

      ///url may be causing an error to login 05-10-2023
      /// error is mentioned below
      ///ArgumentError (Invalid argument(s): No host specified in URI /wp-json/jwt-auth/v1/token)
      ///please add the url into the config file's domain_url of the network folder
      response =
          await http.post(url, body: jsonEncode(request), headers: headers);
    } else if (method == HttpMethod.DELETE) {
      response = await delete(url, headers: headers);
    } else if (method == HttpMethod.PUT) {
      response = await put(url, body: jsonEncode(request), headers: headers);
    } else {
      response = await get(url, headers: headers);
    }

    log('Response ($method): ${response.statusCode} ${response.body}');

    return response;
  } else {
    throw errorInternetNotAvailable;
  }
}

Future handleResponse(Response response) async {
  if (!await isNetworkAvailable()) {
    throw errorInternetNotAvailable;
  }
  if (response.statusCode == 401) {
    LiveStream().emit(tokenStream, true);
    throw TokenException('Token Expired');
  }

  if (response.statusCode == 500 || response.statusCode == 404) {
    if (appStore.isLoggedIn) {
      if (appStore.tempBaseUrl != BASE_URL) {
        appStore.setBaseUrl(BASE_URL, initiliaze: true);
        appStore.setDemoDoctor("", initiliaze: true);
        appStore.setDemoPatient("", initiliaze: true);
        appStore.setDemoReceptionist("", initiliaze: true);
        logout(getContext).catchError(onError);
      }
    } else {
      appStore.setBaseUrl(BASE_URL, initiliaze: true);
    }
  }

  if (response.statusCode.isSuccessful()) {
    return jsonDecode(response.body);
  } else {
    try {
      var body = jsonDecode(response.body);
      if (body['message'].toString().isNotEmpty) {
        // showDialog(context: Buildcontext, builder: (context) {
        // }, );
        SimpleDialog(
          title: Text("Please Enter a Valid Email Address"),
        );
      } else {
        throw errorSomethingWentWrong;
      }
    } on Exception catch (e) {
      log(e);
      throw errorSomethingWentWrong;
    }
  }
}

//region Common
enum HttpMethod { GET, POST, DELETE, PUT }

class TokenException implements Exception {
  final String message;

  const TokenException([this.message = ""]);

  String toString() => "FormatException: $message";
}
//endregion

Future<MultipartRequest> getMultiPartRequest(String endPoint) async {
  log('Url $BASE_URL$endPoint');
  return MultipartRequest('POST', Uri.parse('$BASE_URL$endPoint'));
}
