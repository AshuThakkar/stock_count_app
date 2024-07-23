import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_count_app/AppCommon.dart';
import 'package:stock_count_app/classes/OfflineBatch.dart';
import 'package:stock_count_app/views/ProcessOffline/SCProcessOffline.dart';
import 'dart:async';

import 'package:stock_count_app/utils/database_helper.dart';

class SCProcessOfflineFinalSave extends StatefulWidget {
  final OfflineBatch currentbatch;
  SCProcessOfflineFinalSave(this.currentbatch);

  @override
  SCProcessOfflineFinalSaveState createState() =>
      SCProcessOfflineFinalSaveState(currentbatch);
}

class SCProcessOfflineFinalSaveState extends State<SCProcessOfflineFinalSave> {
  OfflineBatch currentbatch;
  DatabaseHelper databasehelper = DatabaseHelper();
  String batchName = "";
  List<OfflineBatchItem> batchItems = [];
  TextEditingController upcController = TextEditingController();
  TextEditingController newStockcontroller = TextEditingController();

  SCProcessOfflineFinalSaveState(this.currentbatch);

  @override
  void initState() {
    super.initState();
    databasehelper.initializeDatabase();

    if (currentbatch.batchID > 0) {
      setState(() {
        batchName = currentbatch.batchName;
        batchItems = currentbatch.batchItems;
      });
    }
  }

  addItemInBatch() {
    String offlineUPC = upcController.text.trim();
    if (offlineUPC == "") {
      showAlertWithoutTitleDialog(context, "Please enter UPC.");
      return false;
    }

    String offlineQty = "";
    double offlineQty0;

    offlineQty = newStockcontroller.text.trim();
    if (offlineQty == '') {
      showAlertWithoutTitleDialog(context, "Please enter Stock.");
      return false;
    } else {
      offlineQty0 = double.parse(offlineQty);
    }

    int isExistIndex =
        batchItems.indexWhere((element) => element.upc == offlineUPC);

    if (isExistIndex != -1) {
      showAlertWithoutTitleDialog(
          context, "Item : $offlineUPC already added in Current Batch.");
      return false;
    }
    List<OfflineBatchItem> lstItems = batchItems;

    lstItems.add(OfflineBatchItem(null, null, offlineUPC, offlineQty));

    resetFormAfterAddingItem(lstItems);

    // var item = {
    //     'BItemID': 1,
    //     'BatchID': global.CurrentBatch.BatchID,
    //     'UPC': OfflineUPC,
    //     'Price': OfflinePrice,
    //     'Cost': OfflineCost,
    //     'StockQty': OfflineQty,
    //     'Note': OfflineNote,
    //     'IsCaseOrUnit': isCaseOrUnit,
    //     'RestockType': RestockRadio
    // }

    // if (this.state.lastBatchItemID === null) {
    //     db.transaction((tx) => {
    //         tx.executeSql(
    //             'SELECT MAX(BItemID) AS BItemID FROM BatchItem',
    //             [], (tx, results) => {
    //                 if (results.rows.length > 0)
    //                     item.BItemID = results.rows.item(0).BItemID + 1;

    //                 this.addItemInBatchFinal(item);
    //             });
    //     });
    // }
    // else {
    //     item.BItemID = parseInt(this.state.lastBatchItemID) + 1;
    //     this.addItemInBatchFinal(item);
    // }
  }

  resetFormAfterAddingItem(lstItems) {
    setState(() {
      upcController.text = "";
      newStockcontroller.text = ""; //-> Enter Stock
      batchItems = lstItems;
    });
  }

  deleteBatchItem(int index, bool bConfirm) {
    if (bConfirm) {
      Widget continueButton = TextButton(
        child: const Text("Yes"),
        onPressed: () {
          Navigator.pop(context);
          deleteBatchItem(index, false);
        },
      );
      Widget cancelButton = TextButton(
        child: const Text(
          "No",
          style: TextStyle(color: Colors.red),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text(
          "Confirm",
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width.toInt() <= 600
                  ? MediaQuery.of(context).size.width * 0.05
                  : MediaQuery.of(context).size.width * 0.04),
        ),
        content:
            Text("Do you want to remove Item : '${batchItems[index].upc}' ?"),
        actions: [
          continueButton,
          cancelButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
      batchItems.removeAt(index);

      setState(() {
        batchItems = batchItems;
      });
    }
  }

  saveOfflineBatch() async {
    if (currentbatch.batchID <= 0) {
      showAlertWithoutTitleDialog(context, "You don't have Current Batch.");
      return false;
    }

    if (batchItems.isEmpty) {
      showAlertWithoutTitleDialog(
          context, "Add atleast one item to create offline Batch.");
      return false;
    }

    currentbatch.batchItems = batchItems;

    int result = await databasehelper.insertUpdateBatch(currentbatch);

    if (result != 0) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SCProcessOffline()),
      );
    } else {
      showAlertWithoutTitleDialog(context, "Error occured while saving Batch.");
      return false;
    }

    // db.transaction((tx) => {
    //     if (global.IsBatchAdd == false) { //----------Edit Mode
    //         for (var g = 0; g < CurrentBatchItems.length; g++) {
    //             var item_update_sql = "DELETE FROM BatchItem WHERE BatchID = " + myCurrentBatch.BatchID + ";";
    //             tx.executeSql(item_update_sql);
    //         }
    //     }
    //     else { //-----------Add Mode
    //         var sql = "INSERT INTO Batch (BatchID, BatchType, BatchName, IsUpdateOrReplace, lblType, invoiceNo, invoiceDate,STOREID) VALUES (" + myCurrentBatch.BatchID + ", " + myCurrentBatch.BatchType + ",'" + myCurrentBatch.BatchName + "'," + myCurrentBatch.IsUpdateOrReplace + "," + myCurrentBatch.lblType + ",'" + myCurrentBatch.invoiceNo + "','" + myCurrentBatch.invoiceDate + "','" + global.StoreID + "');";
    //         tx.executeSql(sql);
    //     }

    //     for (var g = 0; g < CurrentBatchItems.length; g++) {
    //         var item_sql = "INSERT INTO BatchItem (BItemID, BatchID, UPC, Price, Cost, StockQty, Note, IsCaseOrUnit, RestockType) VALUES (" + CurrentBatchItems[g].BItemID + ", " + CurrentBatchItems[g].BatchID + ",'" + CurrentBatchItems[g].UPC + "'," + CurrentBatchItems[g].Price + "," + CurrentBatchItems[g].Cost + "," + CurrentBatchItems[g].StockQty + ",'" + CurrentBatchItems[g].Note + "'," + CurrentBatchItems[g].IsCaseOrUnit + "," + CurrentBatchItems[g].RestockType + ");";
    //         tx.executeSql(item_sql);
    //     }

    //     global.CurrentBatch = null;

    //     this.props.navigation.navigate("header");
    // });
  }

  Future scanOflItemUPC() async {
    try {
      ScanResult qrResult0 = await BarcodeScanner.scan();
      String qrResult = qrResult0.rawContent;
      String resQR = await AppCommon.generateScannedBarcode(qrResult);
      setState(() {
        upcController.text = resQR;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          leading: IconButton(
            iconSize: 30,
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SCProcessOffline()),
              );
            },
          ),
          title: Text(
            batchName,
          ),
          actions: <Widget>[
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.save),
              onPressed: () {
                // Navigator.pop(context);
                saveOfflineBatch();
              },
            ),
          ],
        ),
        body: Form(
            child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: Text(
                      'UPC : ',
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: upcController,
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(30),
                      ],
                      decoration: const InputDecoration(
                        isDense: true,
                      ),
                    ),
                  ),
                  Container(width: 12),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0.0),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        scanOflItemUPC();
                      },
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 15, right: 15),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 6.0,
                  ),
                  onPressed: () {
                    addItemInBatch();
                  },
                  child: const Text("ADD ITEM")),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                "Total Item${batchItems.length > 1 ? "s" : ""} : ",
                            style: const TextStyle(
                              fontSize: 17,
                              // fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: batchItems.length.toString(),
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlue[900]),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: batchItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                        margin: EdgeInsets.zero,
                        color: Colors.lightBlue[50],
                        child: ListTile(
                          title: Text(
                            batchItems[index].upc!,
                            style: const TextStyle(fontWeight: FontWeight.w400),
                          ),
                          trailing: GestureDetector(
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 30.0,
                            ),
                            onTap: () {
                              deleteBatchItem(index, true);
                            },
                          ),
                        ));
                  }),
            ),
          ],
        )));
  }
}
