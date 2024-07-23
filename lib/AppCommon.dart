import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:stock_count_app/classes/OfflineBatch.dart';

class AppCommon {
  static generateScannedBarcode(qrResult) async {
    String UPC = qrResult.toString();
    return UPC;
  }
}

showExceptionDialog(BuildContext context1, dynamic msg) {
  hideLoader();
  showDialog(
    context: context1,
    builder: (BuildContext context) => AlertDialog(
      content: Text(msg.toString()),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

showErrorAlertDialog(BuildContext context1, String msg) {
  showDialog(
    context: context1,
    builder: (BuildContext context) => AlertDialog(
      title: Text(
        "Failed",
        style: TextStyle(
            fontSize: MediaQuery.of(context).size.width.toInt() <= 600
                ? MediaQuery.of(context).size.width * 0.05
                : MediaQuery.of(context).size.width * 0.04),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      content: Text(msg),
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

showAlertWithoutTitleDialog(BuildContext context1, String msg) {
  showDialog(
    context: context1,
    builder: (BuildContext context) => AlertDialog(
      content: Text(msg),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

showLoader() {
  EasyLoading.show();
}

hideLoader() {
  EasyLoading.dismiss();
}
