import 'dart:convert';
import 'package:stock_count_app/AppCommon.dart';
import 'package:stock_count_app/classes/OfflineBatch.dart';
import 'package:stock_count_app/views/ProcessOffline/SCProcessOfflineFinalSave.dart';
import 'package:stock_count_app/utils/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class SCProcessOffline extends StatefulWidget {
  const SCProcessOffline({super.key});

  @override
  SCProcessOfflineState createState() => SCProcessOfflineState();
}

class SCProcessOfflineState extends State<SCProcessOffline> {
  DatabaseHelper databasehelper = DatabaseHelper();
  TextEditingController batchNameController = TextEditingController();
  List<OfflineBatch> lstBatches = [];

  @override
  void initState() {
    super.initState();
    loadAllOfflineBatches();
  }

  loadAllOfflineBatches() {
    final Future<Database> dbFuture = databasehelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<OfflineBatch>> batchListFuture =
          databasehelper.getBatchList();
      batchListFuture.then((batchList) {
        setState(() {
          lstBatches = batchList;
        });
      });
    });
  }

  goToNextStep() {
    String batchName = batchNameController.text.trim();
    String popiNumber = "";
    DateTime? popiDate;

    if (batchName == "") {
      showAlertWithoutTitleDialog(context, "Please enter Batch Name.");
      return false;
    }

    OfflineBatch objBatch = OfflineBatch(0, batchName, []);

    setState(() {
      batchNameController.text = "";
    });

    navigateToOfflinePageContent(objBatch);
  }

  navigateToOfflinePageContent(objBatch) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SCProcessOfflineFinalSave(objBatch)),
    );
  }

  deleteBatch(int index, bool bConfirm) async {
    if (bConfirm) {
      Widget continueButton = TextButton(
        child: const Text("Yes"),
        onPressed: () {
          Navigator.pop(context);
          deleteBatch(index, false);
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
        content: Text(
            "Do you want to delete Batch : '${lstBatches[index].batchName}' ?"),
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
      int result = await databasehelper.deleteBatch(lstBatches[index].batchID!);
      if (result != 0) {
        // _showSnackBar(context, 'Employee Deleted Successfully.');
        loadAllOfflineBatches();
      }
    }
  }

  // void _showSnackBar(BuildContext context, String message) {
  //   Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  // }

  uploadBatch(OfflineBatch objBatch, int index, bool allowDrpSelection) async {
    // try {
    //   if ((objBatch.batchType == 1 ||
    //           objBatch.batchType == 5 ||
    //           objBatch.batchType == 6) &&
    //       allowDrpSelection == true) {
    //     String onlineModalLabel = "";
    //     String encodedURl = "";

    //     if (objBatch.batchType == 1) {
    //       onlineModalLabel = "Select Facility";
    //       encodedURl =
    //           "${AppCommon.hostName}/Item/GetFacilityList?SessionID=${AppCommon.sessionID}&DBID=${AppCommon.dbID}";
    //     } else if (objBatch.batchType == 5 || objBatch.batchType == 6) {
    //       onlineModalLabel = "Select Vendor";
    //       encodedURl =
    //           "${AppCommon.hostName}/Invoice/GetVendorList?SessionID=${AppCommon.sessionID}&DBID=${AppCommon.dbID}";
    //     }

    //     showLoader();
    //     http.Response response_1 = await http.get(Uri.parse(encodedURl),
    //         headers: {"Accept": "application/json"});
    //     hideLoader();

    //     var data = json.decode(response_1.body);

    //     if (data["StatusVal"] == false) {
    //       showErrorAlertDialog(context, data["StatusMsg"]);
    //       return false;
    //     } else {
    //       var parsed = data["Data"].cast<Map<String, dynamic>>();
    //       List<DropDown1> drp = parsed
    //           .map<DropDown1>((json) => DropDown1.fromJson(json))
    //           .toList();

    //       List<DropdownMenuItem<int>> lstDrp = [];

    //       lstDrp.add(DropdownMenuItem<int>(
    //           value: 0, child: Text("--- $onlineModalLabel ---")));

    //       for (int g = 0; g < drp.length; g++) {
    //         lstDrp.add(DropdownMenuItem<int>(
    //             value: drp[g].id, child: Text(drp[g].name!)));
    //       }
    //       if (objBatch.batchType == 5 || objBatch.batchType == 6) {
    //         setState(() {
    //           onlOptions = lstDrp;
    //         });
    //       }

    //       showDialog(
    //           barrierDismissible: false,
    //           context: context,
    //           builder: (BuildContext context) {
    //             return StatefulBuilder(builder: (context, setState) {
    //               return AlertDialog(
    //                 content: SingleChildScrollView(
    //                     child: Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   // shrinkWrap: true,
    //                   children: <Widget>[
    //                     DropdownButton(
    //                       isExpanded: true,
    //                       items: lstDrp,
    //                       style: const TextStyle(
    //                           color: Colors.black, fontSize: 18),
    //                       value: selectedOnlOp,
    //                       onChanged: (newValue) {
    //                         setState(() {
    //                           selectedOnlOp = newValue;
    //                         });
    //                       },
    //                     ),
    //                     Padding(
    //                       padding: const EdgeInsets.only(
    //                           left: 0, right: 0, top: 10.0),
    //                       child: Row(
    //                         children: [
    //                           Expanded(
    //                             child: ElevatedButton(
    //                               child: const Text('OK'),
    //                               onPressed: () {
    //                                 if (selectedOnlOp == 0) {
    //                                   showAlertWithoutTitleDialog(
    //                                       context, "Please $onlineModalLabel.");
    //                                   // return false;
    //                                 } else {
    //                                   Navigator.pop(context);
    //                                   uploadBatch(objBatch, index, false);
    //                                   // return true;
    //                                 }
    //                               },
    //                             ),
    //                           ),
    //                           Container(width: 10.0),
    //                           Expanded(
    //                             child: ElevatedButton(
    //                               style: ElevatedButton.styleFrom(
    //                                   backgroundColor: Colors.red),
    //                               onPressed: () {
    //                                 Navigator.pop(context);
    //                                 this.setState(() {
    //                                   selectedOnlOp = 0;
    //                                 });
    //                               },
    //                               child: const Text('CLOSE'),
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 )),
    //               );
    //             });
    //           });
    //     }
    //   } else {
    //     String? facilityID;
    //     int? vendorID;
    //     String? companyName = "";

    //     if (objBatch.batchType == 1 && AppCommon.permItemChangeQty!) {
    //       if (selectedOnlOp == 0) {
    //         showAlertWithoutTitleDialog(context, "Please select Facility.");
    //         return false;
    //       } else {
    //         facilityID = selectedOnlOp.toString();
    //       }
    //     } else if (objBatch.batchType == 5 || objBatch.batchType == 6) {
    //       if (selectedOnlOp == 0) {
    //         showAlertWithoutTitleDialog(context, "Please select Vendor.");
    //         return false;
    //       } else {
    //         vendorID = selectedOnlOp!;

    //         List<DropdownMenuItem<int>> lstSale = onlOptions
    //             .where((element) => element.value == vendorID)
    //             .toList();
    //         if (lstSale.isNotEmpty) {
    //           Text txtElement = lstSale[0].child as Text;
    //           companyName = txtElement.data.toString();
    //         }
    //       }
    //     }

    //     Map<String, dynamic> objFinalBatch = {
    //       'BatchID': objBatch.batchID,
    //       'BatchType': objBatch.batchType,
    //       'BatchName': objBatch.batchName ?? "",
    //       'UserID': AppCommon.mobIDForLog,
    //       'IsUpdateOrReplace': objBatch.isUpdateOrReplace,
    //       'invoiceNo': objBatch.invoiceNo ?? "",
    //       'invoiceDate': objBatch.invoiceDate ?? "",
    //       'BatchItems': objBatch.batchItems.isNotEmpty
    //           ? objBatch.batchItems.map((k) => k.toJson()).toList()
    //           : null,
    //       'FacilityID': facilityID,
    //       'VendorID': vendorID,
    //       'CompanyName': companyName
    //     };

    //     var body = json.encode(objFinalBatch);

    //     String encodedURl =
    //         "${AppCommon.hostName}/OfflineProcess/UploadOfflineData?DBID=${AppCommon.dbID}&SessionID=${AppCommon.sessionID}";

    //     showLoader();
    //     http.Response response = await http.post(Uri.parse(encodedURl),
    //         headers: {
    //           "Accept": "application/json",
    //           "Content-Type": "application/json"
    //         },
    //         body: body);
    //     hideLoader();

    //     var data = json.decode(response.body);

    //     if (data["StatusVal"] == false) {
    //       showErrorAlertDialog(context, data["StatusMsg"]);
    //       return false;
    //     } else {
    //       deleteBatch(index, false);
    //       showAlertWithoutTitleDialog(context, data["StatusMsg"]);
    //       return true;
    //     }
    //   }
    // } catch (e) {
    //   showExceptionDialog(context, e);
    //   return false;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          "Batch Type",
        ),
        actions: <Widget>[
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () {
              goToNextStep();
            },
          ),
        ],
      ),
      body: Form(
          child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Text(
                    'Batch Name : ',
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: batchNameController,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(30),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        const TextSpan(
                          text: "Current Batches : ",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: lstBatches.length.toString(),
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
                itemCount: lstBatches.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      color:
                          index % 2 == 0 ? Colors.lightBlue[100] : Colors.white,
                      child: ListTile(
                        title: Text(
                            "${lstBatches[index].batchName} (${lstBatches[index].batchItems != null ? lstBatches[index].batchItems.length.toString() : "0"})",
                            style:
                                const TextStyle(fontWeight: FontWeight.w400)),
                        // subtitle: Text(lstBatches[index].batchTypeName!),
                        onTap: () {
                          Widget editBtn = TextButton(
                            child: const Text("Edit"),
                            onPressed: () {
                              Navigator.pop(context);
                              navigateToOfflinePageContent(lstBatches[index]);
                            },
                          );
                          Widget uploadBtn = TextButton(
                            child: const Text("Upload"),
                            onPressed: () {
                              Navigator.pop(context);
                              uploadBatch(lstBatches[index], index, true);
                            },
                          );
                          Widget closeBtn = TextButton(
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          );

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: const Text("What do you want to do ?"),
                                actions: [editBtn, uploadBtn, closeBtn],
                              );
                            },
                          );
                        },
                        trailing: GestureDetector(
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 30.0,
                          ),
                          onTap: () {
                            deleteBatch(index, true);
                          },
                        ),
                      ));
                }),
          ),
        ],
      )),
    );
  }
}
