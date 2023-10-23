// ignore_for_file: non_constant_identifier_names

import 'package:http_auth/http_auth.dart';
import 'package:kivicare_flutter/model/doctor_dashboard_model.dart';
import 'package:kivicare_flutter/model/doctor_list_model.dart';
import 'package:kivicare_flutter/screens/patient/models/news_model.dart';
import 'package:http/http.dart ' as http;
import 'dart:convert' as convert;

class PatientDashboardModel {
  List<DoctorList>? doctor;
  List<NewsData>? news;
  List<Service>? serviceList;
  int? total_appointment;
  List<UpcomingAppointment>? upcoming_appointment;
  int? upcoming_appointment_total;

  PatientDashboardModel(
      {this.doctor,
      this.news,
      this.serviceList,
      this.total_appointment,
      this.upcoming_appointment,
      this.upcoming_appointment_total});

  factory PatientDashboardModel.fromJson(Map<String, dynamic> json) {
    return PatientDashboardModel(
      doctor: json['doctor'] != null
          ? (json['doctor'] as List).map((i) => DoctorList.fromJson(i)).toList()
          : null,
      news: json['news'] != null
          ? (json['news'] as List).map((i) => NewsData.fromJson(i)).toList()
          : null,
      serviceList: json['service'] != null
          ? (json['service'] as List).map((i) => Service.fromJson(i)).toList()
          : null,
      total_appointment: json['total_appointment'],
      upcoming_appointment: json['upcoming_appointment'] != null
          ? (json['upcoming_appointment'] as List)
              .map((i) => UpcomingAppointment.fromJson(i))
              .toList()
          : null,
      upcoming_appointment_total: json['upcoming_appointment_total'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_appointment'] = this.total_appointment;
    data['upcoming_appointment_total'] = this.upcoming_appointment_total;
    if (this.doctor != null) {
      data['doctor'] = this.doctor!.map((v) => v.toJson()).toList();
    }
    if (this.news != null) {
      data['news'] = this.news!.map((v) => v.toJson()).toList();
    }
    if (this.serviceList != null) {
      data['service'] = this.serviceList!.map((v) => v.toJson()).toList();
    }
    if (this.upcoming_appointment != null) {
      data['upcoming_appointment'] =
          this.upcoming_appointment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Service {
  String? charges;
  String? doctor_id;
  String? id;
  String? mapping_table_id;
  String? name;
  String? service_id;
  String? status;
  String? type;
  String domain = "https://sandbox.paypal.com";
  String clientId =
      "AWChuU9YDAso20AwXyfZRdfvoo9ylPlX8g1U4Q3MbHcysvd-rINaY94VQm1tYs2FtvABTwFEUEr3ZwTa";
  String secretId =
      "EIhXgC0GR4QE_dGUNFa4K8EPcYIZqOSjH6xIAXK5OP4GxUaqZHBH8FJssNlgBwGRPXAJuOFBoX_jSd6B";

  Service(
      {this.charges,
      this.doctor_id,
      this.id,
      this.mapping_table_id,
      this.name,
      this.service_id,
      this.status,
      this.type});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      charges: json['charges'],
      doctor_id: json['doctor_id'],
      id: json['id'],
      mapping_table_id: json['mapping_table_id'],
      name: json['name'],
      service_id: json['service_id'],
      status: json['status'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['charges'] = this.charges;
    data['doctor_id'] = this.doctor_id;
    data['id'] = this.id;
    data['mapping_table_id'] = this.mapping_table_id;
    data['name'] = this.name;
    data['service_id'] = this.service_id;
    data['status'] = this.status;
    data['type'] = this.type;
    return data;
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
}
