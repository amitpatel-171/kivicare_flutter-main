// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/payment/payment_service.dart';
import 'package:kivicare_flutter/utils/widgets/spining_lines.dart';

class CompletePayment extends StatefulWidget {
  final Function onSuccess, onCancel, onError;
  // final Service servicess;
  final PayPalServices serve;
  final String url, executeUrl, accesstoken;
  const CompletePayment({
    super.key,
    required this.onSuccess,
    required this.onCancel,
    required this.onError,
    required this.serve,
    // required this.servicess,
    required this.url,
    required this.executeUrl,
    required this.accesstoken,
  });

  @override
  State<CompletePayment> createState() => _CompletePaymentState();
}

class _CompletePaymentState extends State<CompletePayment> {
  bool loading = true;
  bool loadingError = false;

  complete() async {
    final uri = Uri.parse(widget.url);
    final payerId = uri.queryParameters["PayerId"];
    if (payerId != null) {
      Map params = {
        "payerID": payerId,
        "paymentId": uri.queryParameters['paymentId'],
        "token": uri.queryParameters['token'],
      };
      setState(() {
        loading = true;
        loadingError = false;
      });

      Map resp = await widget.serve
          .executePayment(widget.executeUrl, payerId, widget.accesstoken);
      if (resp['error'] == false) {
        params['status'] = ['success'];
        params['data'] = resp['success'];
        await widget.onSuccess(params);
        setState(() {
          loading = false;
          loadingError = false;
        });
        Navigator.pop(context);
      } else {
        if (resp['exception'] != null && resp['exception'] == true) {
          widget.onError({'message': resp['message']});
          setState(() {
            loading = false;
            loadingError = true;
          });
        } else {
          await widget.onError(resp['data']);
          Navigator.of(context).pop();
        }
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: loading
              ? Column(
                  children: [
                    Expanded(
                        child: Center(
                      child: SpinKitSpinningLines(
                        color: const Color.fromARGB(255, 10, 107, 185),
                      ),
                    ))
                  ],
                )
              : loadingError
                  ? Column(
                      children: [
                        Expanded(
                            child: Center(
                          child: Text(
                            "Something went Wrong",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ))
                      ],
                    )
                  : const Center(
                      child: Text("Payment Completed"),
                    )),
    );
  }
}
