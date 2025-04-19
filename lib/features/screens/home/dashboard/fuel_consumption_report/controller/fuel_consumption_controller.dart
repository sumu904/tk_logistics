import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tk_logistics/features/screens/home/dashboard/fuel_consumption_report/model/fuel_consumption_model.dart';

import '../../../../../../const/const_values.dart';

Future<List<FuelConsumptionModel>> fetchReports(String date) async {
  final response = await http.get(Uri.parse('${baseUrl}/vmfuelentrysum_list?xdate=$date 00:00:00'));
  print(response.body);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> results = data['results'];
    return results.map((json) => FuelConsumptionModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load reports');
  }
}
