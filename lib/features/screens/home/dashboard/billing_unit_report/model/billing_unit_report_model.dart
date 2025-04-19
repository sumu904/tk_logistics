class BillingUnitReportModel {
  int? zid;
  String? xtype;
  String? xdate;
  String? xproj;
  int? xqty;
  String? xinweight;
  String? trkm;
  String? xprime;

  // Derived fields for table display
  String? billingUnit;
  int? noOfTrip;
  double? cargoWt;
  double? bill;

  // Total field that will be calculated based on xtype
  double? total;

  BillingUnitReportModel({
    this.zid,
    this.xtype,
    this.xdate,
    this.xproj,
    this.xqty,
    this.xinweight,
    this.trkm,
    this.xprime,
    this.billingUnit,
    this.noOfTrip,
    this.cargoWt,
    this.bill,
    this.total,
  });

  BillingUnitReportModel.fromJson(Map<String, dynamic> json) {
    zid = json['zid'];
    xtype = json['xtype'];
    xdate = json['xdate'];
    xproj = json['xproj'];
    xqty = json['xqty'];
    xinweight = json['xinweight'];
    trkm = json['trkm'];
    xprime = json['xprime'];

    // Mapping API fields to match table requirements
    billingUnit = json['xproj']; // Assuming xproj represents Billing Unit
    noOfTrip = json['xqty']; // Assuming xqty represents No of Trip
    cargoWt = json['xinweight'] != null ? double.tryParse(json['xinweight'].toString()) : 0.0;
    bill = json['xprime'] != null ? double.tryParse(json['xprime'].toString()) : 0.0;

    // Calculate the total field based on xtype
    total = _calculateTotalBasedOnXType();
  }

  // Calculate the total based on xtype
  double _calculateTotalBasedOnXType() {
    if (xtype == 'TMS') {
      // Example: If xtype is TMS, calculate total as quantity * bill
      return (xqty ?? 0) * (bill ?? 0.0);
    } else if (xtype == '3MS') {
      // Example: If xtype is 3MS, calculate total as quantity * cargoWt
      return (xqty ?? 0) * (cargoWt ?? 0.0);
    } else {
      // Default case: You can add any other logic or return 0
      return 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['zid'] = zid;
    data['xtype'] = xtype;
    data['xdate'] = xdate;
    data['xproj'] = xproj;
    data['xqty'] = xqty;
    data['xinweight'] = xinweight;
    data['trkm'] = trkm;
    data['xprime'] = xprime;

    // Adding mapped fields
    data['billingUnit'] = billingUnit;
    data['noOfTrip'] = noOfTrip;
    data['cargoWt'] = cargoWt;
    data['bill'] = bill;

    // Adding total field to JSON
    data['total'] = total;

    return data;
  }
}
