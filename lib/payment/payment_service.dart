import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart';

class PayPalServices {
  late final bool sandboxMode;
  final String clientId, secretId;

  String domain = "https://sandbox.paypal.com";
  // String clientId =
  //     "AWChuU9YDAso20AwXyfZRdfvoo9ylPlX8g1U4Q3MbHcysvd-rINaY94VQm1tYs2FtvABTwFEUEr3ZwTa";
  // String secretId =
  //     "EIhXgC0GR4QE_dGUNFa4K8EPcYIZqOSjH6xIAXK5OP4GxUaqZHBH8FJssNlgBwGRPXAJuOFBoX_jSd6B";

  PayPalServices({
    required this.sandboxMode,
    required this.clientId,
    required this.secretId,
  });

  getAccessToken() async {
    try {
      var client = BasicAuthClient(clientId, secretId);
      var response = await client.post(
          Uri.parse("$domain/v1/oauth2/token?grant_type=client_credentials"));

      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);
        return {
          'error': false,
          'message': "Success",
          'token': body["access_token"]
        };
      } else {
        return {
          'error': true,
          'message': "Your PayPal credentials seems incorrect"
        };
      }
    } catch (e) {
      return {
        'error': true,
        'message': "Unable to proceed, check your internet connection."
      };
    }
  }

  Future<Map> createPayPalPayment(transactions, accesstoken) async {
    try {
      var response = await http.post(Uri.parse("$domain/v1/payments/payment"),
          body: convert.jsonEncode(transactions),
          headers: {
            "content-type": "application/json",
            "Authorizatioon": "Bearer" + accesstoken
          });
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (body["links"] != null && body["links"].length > 0) {
          List links = body["links"];
          String executeUrl = "";
          String approvalUrl = "";
          final item = links.firstWhere((o) => o["rel"] == "approval_url",
              orElse: () => null);
          if (item != null) {
            approvalUrl = item["href"];
          }
          final item1 = links.firstWhere((o) => o["rel"] == "execute",
              orElse: () => null);
          if (item1 != null) {
            executeUrl = item1["href"];
          }
          return {"executeUrl": executeUrl, "approvalUrl": approvalUrl};
        }
        return {};
      } else {
        throw Exception(body["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> executePayment(url, payerId, accesstoken) async {
    try {
      var response = await http.post(Uri.parse(url),
          body: convert.jsonEncode({"player_id": payerId}),
          headers: {
            "content-type": "application/json",
            "Authorizatioon": "Bearer" + accesstoken
          });
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'error': false, 'message': "Success", 'data': body};
      } else {
        return {
          'error': true,
          'message': "Payment inconclusive.",
          'data': body
        };
      }
    } catch (e) {
      return {'error': true, 'message': e, 'exception': true, 'data': null};
    }
  }
}
