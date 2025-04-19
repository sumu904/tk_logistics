class FuelConsumptionModel {
  final String xtype;
  final String xdepot;
  final double xqtyord;
  final double xamount;

  FuelConsumptionModel({
    required this.xtype,
    required this.xdepot,
    required this.xqtyord,
    required this.xamount,
  });

  factory FuelConsumptionModel.fromJson(Map<String, dynamic> json) {
    return FuelConsumptionModel(
      xtype: json['xtype'],
      xdepot: json['xdepot'],
      xqtyord: double.parse(json['xqtyord']),
      xamount: double.parse(json['xamount']),
    );
  }
}

class FuelReport {
  final String xtype;
  final String xdepot;
  final double xqtyord;
  final double xamount;

  FuelReport({required this.xtype, required this.xdepot, required this.xqtyord, required this.xamount});

  factory FuelReport.fromJson(Map<String, dynamic> json) {
    return FuelReport(
      xtype: json['xtype'],
      xdepot: json['xdepot'],
      xqtyord: double.tryParse(json['xqtyord'].toString()) ?? 0.0,
      xamount: double.tryParse(json['xamount'].toString()) ?? 0.0,
    );
  }
}

