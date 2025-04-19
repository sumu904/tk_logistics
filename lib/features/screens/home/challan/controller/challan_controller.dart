import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../../../common/widgets/build_delivery_challan.dart';
import '../../../../../const/const_values.dart';
import '../../../../../util/app_color.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';

class ChallanController extends GetxController {
  final String tripNo;
  Map<String, dynamic>? tripData;

  Uint8List? imageBytes; // Store image bytes here
  Uint8List? shareFileBytes;

  ChallanController(this.tripNo);

  @override
  void onInit() {
    super.onInit();
    loadImage(); // Load image when controller initializes
    fetchTripData();
  }

  Future<pw.Font> loadFont(String fontPath) async {
    final fontData = await rootBundle.load(fontPath);
    return pw.Font.ttf(fontData.buffer.asByteData());
  }

  Future<void> loadImage() async {
    final ByteData data =
    await rootBundle.load('assets/images/challan_delivery.png');
    imageBytes = data.buffer.asUint8List();
    update(); // Notify UI about the update
  }

  Future<void> fetchTripData() async {
    final url = Uri.parse(
        "${baseUrl}/Trip_list?xsornum=$tripNo");
    print("Fetching Data from: $url");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['results'] != null &&
            responseData['results'].isNotEmpty) {
          tripData = responseData['results'][0];
          update();
          print("Data Retrieved: $tripData");
        } else {
          print("No results found for tripNo: $tripNo");
        }
      } else {
        print("Error fetching data: ${response.statusCode}");
      }
    } catch (e) {
      print("API Error: $e");
    }
  }

  Future<void> generatePdf() async {
    if (tripData == null || imageBytes == null) return;

    final pdf = pw.Document();
    final banglaFont = await loadFont('assets/fonts/SolaimanLipi.ttf');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              buildDeliveryChallan(tripData, banglaFont, imageBytes!),
              pw.Divider(thickness: 1),
              buildDeliveryChallan(tripData, banglaFont, imageBytes!),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    String fileName = "Challan_${tripData?['xsornum'] ?? 'Unknown'}.pdf";

    shareFileBytes = pdfBytes;

    openPdf(pdfBytes, fileName);
  }

  void openPdf(Uint8List pdfBytes, String fileName) {
    Get.to(() => Scaffold(
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
        title: Text(fileName,
            style: quicksandBold.copyWith(
                fontSize: Dimensions.fontSizeEighteen,
                color: AppColor.white)),
      ),
      body: PdfPreview(
        build: (format) => pdfBytes,
        pdfFileName: fileName,
      ),
    ));
  }
}