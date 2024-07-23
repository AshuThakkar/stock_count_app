class OfflineBatch {
  int batchID = 0;
  String batchName = "";
  List<OfflineBatchItem> batchItems = [];

  OfflineBatch(this.batchID, this.batchName, this.batchItems);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (batchID > 0) {
      map['BATCH_ID'] = batchID;
    }
    map['BATCHNAME'] = batchName;
    return map;
  }

  OfflineBatch.fromMapObject(Map<String, dynamic> map) {
    batchID = map['BATCH_ID'];
    batchName = map['BATCHNAME'];
    batchItems = [];
  }
}

class OfflineBatchItem {
  int? bItemID;
  int? batchID;
  String? upc;
  String? stock;

  OfflineBatchItem(this.bItemID, this.batchID, this.upc, this.stock);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (bItemID != null) {
      map['BITEM_ID'] = bItemID;
    }
    map['BATCH_ID'] = batchID;
    map['UPC'] = upc;
    map['STOCK'] = stock;
    return map;
  }

  OfflineBatchItem.fromMapObject(Map<String, dynamic> map) {
    bItemID = map['BITEM_ID'];
    batchID = map['BATCH_ID'];
    upc = map['UPC'];
    stock = map['STOCK'];
  }

  Map<String, dynamic> toJson() {
    return {
      'BItemID': bItemID,
      'BatchID': batchID,
      'UPC': upc ?? "",
      'StockQty': stock,
    };
  }
}
