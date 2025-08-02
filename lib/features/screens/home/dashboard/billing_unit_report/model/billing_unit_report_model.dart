class BillingUnitReportModel {
  int? zid;
  String? xtype;
  String? xdate;
  String? xproj;
  int? xqty;         // Used for quantity and trip count
  String? xinweight; // Raw string from API
  String? trkm;
  String? xprime;    // Raw string from API

  // Derived display fields
  String? billingUnit;
  int? noOfTrip;
  double? cargoWt;
  double? bill;
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
    xqty = json['xqty']; // integer
    xinweight = json['xinweight'];
    trkm = json['trkm'];
    xprime = json['xprime'];

    // Derived mappings
    billingUnit = xproj;
    noOfTrip = xqty;
    cargoWt = xinweight != null ? double.tryParse(xinweight.toString()) ?? 0.0 : 0.0;
    bill = xprime != null ? double.tryParse(xprime.toString()) ?? 0.0 : 0.0;

    total = _calculateTotalBasedOnXType();
  }

  double _calculateTotalBasedOnXType() {
    if (xtype == 'TMS') {
      return (xqty ?? 0) * (bill ?? 0.0);
    } else if (xtype == '3MS') {
      return (xqty ?? 0) * (cargoWt ?? 0.0);
    } else if (xtype == 'RENTAL') {
      return (xqty ?? 0) * ((bill ?? 0.0) + (cargoWt ?? 0.0)); // Just an example
    } else {
      return 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'zid': zid,
      'xtype': xtype,
      'xdate': xdate,
      'xproj': xproj,
      'xqty': xqty,
      'xinweight': xinweight,
      'trkm': trkm,
      'xprime': xprime,
      'billingUnit': billingUnit,
      'noOfTrip': noOfTrip,
      'cargoWt': cargoWt,
      'bill': bill,
      'total': total,
    };
  }
}
