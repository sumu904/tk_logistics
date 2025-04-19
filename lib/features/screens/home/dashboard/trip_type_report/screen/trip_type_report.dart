import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../../../../../const/const_values.dart';
import '../../../../../../util/app_color.dart';
import '../../../../../../util/dimensions.dart';
import '../../../../../../util/styles.dart';

class TripTypeReport extends StatefulWidget {
  @override
  _TripTypeReportState createState() => _TripTypeReportState();
}

class _TripTypeReportState extends State<TripTypeReport> {
  DateTime selectedDate = DateTime.now();
  List<dynamic> tripData = [];
  double totalIncome = 0.0;

  Future<void> fetchData() async {
    String formattedDate = "${selectedDate.toIso8601String().split('T')[0]} 00:00:00";
    String apiUrl = "${baseUrl}/vmmoveregsumtrip_list?xdate=$formattedDate";
    print(apiUrl);


    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      setState(() {
        tripData = data['results'];
        totalIncome = tripData.fold(0, (sum, item) => sum + double.parse(item['xprime']));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
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
        fetchData(); // Fetch new data based on the selected date
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
          "Trip Type Wise Income",
          style: quicksandBold.copyWith(
              fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeTwenty,vertical: Dimensions.paddingSizeThirty),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: Dimensions.marginSizeTen),
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
                          fontSize: Dimensions.fontSizeFourteen,color: AppColor.neviBlue
                        ), // Prevents long text overflow
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
            SizedBox(height: 30,),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(width: 1,color: AppColor.neviBlue)
                ),
                child: DataTable(
                  columnSpacing: 36,
                  headingRowColor:
                  MaterialStateColor.resolveWith((states) => AppColor.neviBlue),
                  columns: [
                    DataColumn(label: Text("Trip Type",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.white),)),
                    DataColumn(label: Text("Income (BDT)",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.white))),
                  ],
                  rows: [
                    ...tripData.map((trip) => DataRow(cells: [
                      DataCell(Text(trip['xmovetype'].isEmpty ? "Unspecified" : trip['xmovetype'],style: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen))),
                      DataCell(Align(alignment: Alignment.centerRight,
                        child: Text(
                          NumberFormat('#,##,##0', 'en_IN').format(double.parse(trip['xprime'].toString())),style: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                      )),
                    ])),
                    DataRow(cells: [
                      DataCell(Text("Total",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen))),
                      DataCell(Align(alignment: Alignment.centerRight,
                        child: Text(
                        NumberFormat('#,##,##0', 'en_IN').format(totalIncome),textAlign: TextAlign.center,style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                      )),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

