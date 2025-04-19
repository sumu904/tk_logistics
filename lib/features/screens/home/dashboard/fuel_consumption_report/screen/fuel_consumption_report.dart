import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../../util/app_color.dart';
import '../../../../../../util/dimensions.dart';
import '../../../../../../util/styles.dart';
import '../model/fuel_consumption_model.dart';

class FuelConsumptionReport extends StatefulWidget {
  @override
  _FuelConsumptionReportState createState() => _FuelConsumptionReportState();
}

class _FuelConsumptionReportState extends State<FuelConsumptionReport> {
  DateTime selectedDate = DateTime.now();
  Map<String, List<FuelReport>> groupedReports = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    setState(() {
      isLoading = true;
    });
    String date = DateFormat('yyyy-MM-dd 00:00:00').format(selectedDate);
    try {
      final response = await http.get(Uri.parse(
          'http://103.250.68.75/api/v1/vmfuelentrysum_list?xdate=$date'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<FuelReport> reports = (data['results'] as List)
            .map((json) => FuelReport.fromJson(json))
            .toList();
        setState(() {
          groupedReports = {};
          for (var report in reports) {
            groupedReports.putIfAbsent(report.xtype, () => []).add(report);
          }
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        fetchReports();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.neviBlue,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 22,
            color: AppColor.white,
          ),
        ),
        title: Text(
          "Depot Wise Fuel Consumption",
          style: quicksandBold.copyWith(
              fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeTwenty,
            vertical: Dimensions.paddingSizeTwenty),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: Container(
                margin:
                    EdgeInsets.symmetric(horizontal: Dimensions.marginSizeFive),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeTwenty,
                  vertical: Dimensions.paddingSizeTwelve,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.neviBlue, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Wrapped in Flexible to prevent overflow
                    Flexible(
                      child: Text(
                        "${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                        style: quicksandBold.copyWith(
                            fontSize: Dimensions.fontSizeFourteen,
                            color: AppColor
                                .neviBlue), // Prevents long text overflow
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      color: AppColor.neviBlue,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: groupedReports.isNotEmpty
                        ? ListView(
                            children: groupedReports.entries.map((entry) {
                              return _buildTable(entry.key, entry.value);
                            }).toList(),
                          )
                        : Text(
                            'No data available for selected date.',
                            style: quicksandBold.copyWith(
                                fontSize: Dimensions.fontSizeSixteen,
                                color: AppColor.neviBlue),
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(String title, List<FuelReport> data) {
    double totalQty = data.fold(0, (sum, item) => sum + item.xqtyord);
    double totalAmount = data.fold(0, (sum, item) => sum + item.xamount);

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: AppColor.neviBlue)),
      margin: EdgeInsets.symmetric(
          horizontal: Dimensions.marginSizeFive,
          vertical: Dimensions.marginSizeTen),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: AppColor.neviBlue,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8))),
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeEight,
                vertical: Dimensions.paddingSizeTen),
            child: Center(
              child: Text(title,
                  style: quicksandBold.copyWith(
                      fontSize: Dimensions.fontSizeSixteen,
                      color: AppColor.white,
                      fontWeight: FontWeight.w900)),
            ),
          ),
          DataTable(
            columnSpacing: 18,
            columns: [
              DataColumn(
                  label: Expanded(
                    child: Text('Depot',
                        textAlign: TextAlign.left,
                        style: quicksandBold.copyWith(
                            fontSize: Dimensions.fontSizeFourteen,
                            color: AppColor.neviBlue)),
                  )),
              DataColumn(
                  label: Expanded(
                    child: Text('Qty',
                        textAlign: TextAlign.center,
                        style: quicksandBold.copyWith(
                            fontSize: Dimensions.fontSizeFourteen,
                            color: AppColor.neviBlue)),
                  )),
              DataColumn(
                  label: Expanded(
                    child: Text("Amount (BDT)",
                        textAlign: TextAlign.right,
                        style: quicksandBold.copyWith(
                            fontSize: Dimensions.fontSizeFourteen,
                            color: AppColor.neviBlue)),
                  )),
            ],
            rows: [
              ...data
                  .map((item) => DataRow(cells: [
                        DataCell(Text(
                          item.xdepot,
                          style: quicksandRegular.copyWith(
                              fontSize: Dimensions.fontSizeFourteen),
                        )),
                        DataCell(Align(
                            alignment: Alignment.center,
                            child: Text(
                              item.xqtyord.toStringAsFixed(1),
                              textAlign: TextAlign.center,
                              style: quicksandRegular.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen),
                            ))),
                        DataCell(Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              NumberFormat('#,##,##0', 'en_IN')
                                  .format(item.xamount),
                              textAlign: TextAlign.right,
                              style: quicksandRegular.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen),
                            ))),
                      ]))
                  .toList(),
              DataRow(cells: [
                DataCell(Text(
                  'Total',
                  style: quicksandBold.copyWith(
                      fontSize: Dimensions.fontSizeFourteen),
                )),
                DataCell(Align(
                    alignment: Alignment.center,
                    child: Text(totalQty.toStringAsFixed(1),
                        style: quicksandBold.copyWith(
                            fontSize: Dimensions.fontSizeFourteen)))),
                DataCell(Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                        NumberFormat('#,##,##0', 'en_IN').format(totalAmount),
                        style: quicksandBold.copyWith(
                            fontSize: Dimensions.fontSizeFourteen)))),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
