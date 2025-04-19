import 'package:http/http.dart' as http;
import 'package:tk_logistics/features/screens/home/dashboard/billing_unit_report/model/billing_unit_report_model.dart';
import 'dart:convert';

import '../../../../../../const/const_values.dart';

Future<List<BillingUnitReportModel>> fetchReport(String date, String xtype) async {
  final url = "${baseUrl}/vmmoveregsum_list?xdate=$date&xtype=$xtype";
  print(url);
  final response = await http.get(Uri.parse(url));
  print(response.body);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData = json.decode(response.body); // Decode as Map

    if (jsonData.containsKey("results")) {
      List<dynamic> reportList = jsonData["results"]; // Extract the "results" list

      return reportList.map((item) => BillingUnitReportModel.fromJson(item)).toList();
    } else {
      throw Exception("Missing 'results' key in response");
    }
  } else {
    throw Exception("Failed to load reports");
  }
}
