import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../../util/app_color.dart';
import '../../../../../../util/dimensions.dart';
import '../../../../../../util/styles.dart';
import '../controller/billing_unit_report_controller.dart';
import '../model/billing_unit_report_model.dart';

class BillingUnitReport extends StatefulWidget {
  const BillingUnitReport({super.key});

  @override
  State<BillingUnitReport> createState() => _BillingUnitReportState();
}

class _BillingUnitReportState extends State<BillingUnitReport> {
  DateTime selectedDate = DateTime.now();
  List<BillingUnitReportModel> tmsData = [];
  List<BillingUnitReportModel> tms3Data = [];

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    var date = "${selectedDate.toIso8601String().split('T')[0]} 00:00:00";
    print("Fetching reports for date: $date");
    List<BillingUnitReportModel> tms = await fetchReport(date, "TMS");
    List<BillingUnitReportModel> tms3 = await fetchReport(date, "3MS");

    setState(() {
      tmsData = tms;
      tms3Data = tms3;
    });
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
        fetchReports(); // Fetch new data based on the selected date
      });
    }
  }

  // Function to calculate the total quantity
  int getTotalQty() {
    return tmsData.fold(0, (sum, item) => sum + (item.xqty ?? 0)) +
        tms3Data.fold(0, (sum, item) => sum + (item.xqty ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total quantity only after the data is fetched
    int totalQty = getTotalQty();

    // Calculate percentages
    double tmsPercentage = totalQty > 0
        ? (tmsData.fold(0, (sum, item) => sum + (item.xqty ?? 0)) / totalQty) *
            100
        : 0;
    double tms3Percentage = totalQty > 0
        ? (tms3Data.fold(0, (sum, item) => sum + (item.xqty ?? 0)) / totalQty) *
            100
        : 0;
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
          "Unit Wise Bill Summary",
          style: quicksandBold.copyWith(
              fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeFive,
            vertical: Dimensions.paddingSizeTwenty),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: Container(
                margin:
                    EdgeInsets.symmetric(horizontal: Dimensions.marginSizeTen),
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
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (totalQty > 0)
                      _buildTable(
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'TMS ',
                                style: quicksandBold.copyWith(
                                    fontSize: Dimensions.fontSizeTwenty,
                                    color: AppColor.lightYellow,fontWeight: FontWeight.w900),
                              ),
                              TextSpan(
                                text: '${tmsPercentage.toStringAsFixed(1)}%',
                                style: quicksandSemibold.copyWith(
                                    fontSize: Dimensions.fontSizeTwelve,
                                    color: AppColor
                                        .white), // Use smaller font size here
                              ),
                            ],
                          ),
                        ),
                        tmsData,
                      ),
                    SizedBox(height: 5),
                    if (totalQty > 0)
                      _buildTable(
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '3MS ',
                                style: quicksandBold.copyWith(
                                    fontSize: Dimensions.fontSizeTwenty,
                                    color: AppColor.lightYellow,fontWeight: FontWeight.w900),
                              ),
                              TextSpan(
                                text: '${tms3Percentage.toStringAsFixed(1)}%',
                                style: quicksandSemibold.copyWith(
                                    fontSize: Dimensions.fontSizeTwelve,
                                    color: AppColor
                                        .white), // Use smaller font size here
                              ),
                            ],
                          ),
                        ),
                        tms3Data,
                      ),
                    if (totalQty == 0)
                      Text('No data available for selected date.',
                          style: quicksandBold.copyWith(
                              fontSize: Dimensions.fontSizeSixteen,
                              color: AppColor.neviBlue)),
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

Widget _buildTable(Widget title, List<BillingUnitReportModel> data) {
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
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeEight,vertical: Dimensions.paddingSizeTen),
          child: Center(child: title),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate totals
            double totalCargoWt =
                data.fold(0.0, (sum, item) => sum + (item.cargoWt ?? 0.0));
            double totalBill =
                data.fold(0.0, (sum, item) => sum + (item.bill ?? 0.0));
            int totalNoOfTrips =
                data.fold(0, (sum, item) => sum + (item.noOfTrip ?? 0));

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth, // Restrict to available space
              ),
              child: DataTable(
                columnSpacing: 18, // Reduce spacing between columns

                columns: [
                  DataColumn(
                      label: Expanded(
                        child: Text(
                          'Billing Unit',
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: quicksandBold.copyWith(
                              fontSize: Dimensions.fontSizeFourteen,
                              color: AppColor.neviBlue),
                        ),
                      )),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'No. of\nTrip',
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: quicksandBold.copyWith(
                          fontSize: Dimensions.fontSizeThirteen, // Reduce the font size
                          color: AppColor.neviBlue,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                      label: Expanded(
                        child: Text('Cargo Wt(MT)',
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: quicksandBold.copyWith(
                                fontSize: Dimensions.fontSizeFourteen,
                                color: AppColor.neviBlue)),
                      )),
                  DataColumn(
                      label: Expanded(
                        child: Text('Bill (BDT)',
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: quicksandBold.copyWith(
                                fontSize: Dimensions.fontSizeFourteen,
                                color: AppColor.neviBlue)),
                      )),
                ],
                rows: [
                  // Add your data rows
                  ...data.map((item) {
                    return DataRow(cells: [
                      DataCell(Text(
                        item.billingUnit ?? 'N/A',
                        style: quicksandRegular.copyWith(
                            fontSize: Dimensions.fontSizeFourteen),
                      )),
                      // Default left-aligned
                      DataCell(
                        Align(
                          alignment: Alignment.center, // Center align
                          child: Text(item.noOfTrip?.toString() ?? '0',
                              style: quicksandRegular.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen)),
                        ),
                      ),
                      DataCell(
                        Align(
                          alignment: Alignment.center, // Center align
                          child: Text(item.cargoWt?.toString() ?? '0.0',
                              style: quicksandRegular.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen)),
                        ),
                      ),
                      DataCell(
                        Align(
                          alignment: Alignment.centerRight, // Right align
                          child: Text(NumberFormat('#,##,##0', 'en_IN').format(item.bill),
                              style: quicksandRegular.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen)),
                        ),
                      ),
                    ]);
                  }).toList(),

                  // Add the total row at the bottom
                  DataRow(cells: [
                    DataCell(Text('Total',
                        style: quicksandBold.copyWith(
                            fontSize: Dimensions.fontSizeFourteen))),
                    DataCell(
                      Align(
                        alignment: Alignment.center,
                        child: Text(totalNoOfTrips.toString(),
                            style: quicksandBold.copyWith(
                                fontSize: Dimensions.fontSizeFourteen)),
                      ),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.center,
                        child: Text(totalCargoWt.toStringAsFixed(2),
                            style: quicksandBold.copyWith(
                                fontSize: Dimensions.fontSizeFourteen)),
                      ),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(NumberFormat('#,##,##0', 'en_IN').format(totalBill),
                            style: quicksandBold.copyWith(
                                fontSize: Dimensions.fontSizeFourteen)),
                      ),
                    ),
                  ]),
                ],
              ),
            );
          },
        ),
      ],
    ),
  );
}
