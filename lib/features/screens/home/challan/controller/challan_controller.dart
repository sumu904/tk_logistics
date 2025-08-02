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

  Future<pw.ImageProvider> loadScissorsImage() async {
    final imageData = await rootBundle.load('assets/images/scissors.png');
    return pw.MemoryImage(imageData.buffer.asUint8List());
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
    final scissorsIcon = await loadScissorsImage();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              buildDeliveryChallan(tripData, imageBytes!),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Image(scissorsIcon, width: 12, height: 12),
                  pw.SizedBox(width: 4),
                  pw.Expanded(
                    child: pw.LayoutBuilder(
                      builder: (context, constraints) {
                        const dashWidth = 4.0;
                        const dashSpace = 2.0;
                        final dashCount = ((constraints?.maxWidth ?? 0) / (dashWidth + dashSpace)).floor();

                        return pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: List.generate(dashCount, (_) {
                            return pw.Container(
                              width: dashWidth,
                              height: 1,
                              color: PdfColors.black,
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 28),
              buildDeliveryChallan(tripData, imageBytes!),
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