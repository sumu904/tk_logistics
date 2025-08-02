import 'package:barcode/barcode.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

import 'package:pdf/widgets.dart';


// Function to generate a single Delivery Challan section

pw.Widget buildDeliveryChallan(
    Map<String, dynamic>? tripData, Uint8List imageBytes) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      //pw.SizedBox(height: 20),
      pw.Center(
        child: pw.Text("T.K. LOGISTICS",
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      ),
      pw.SizedBox(height: 5),
      pw.Center(
        child: pw.Text("Delivery Challan",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ),
      pw.SizedBox(height: 10),
      pw.Text(
        "Challan No: ${tripData?['xsornum']?.toString() ?? 'N/A'}",
        style: pw.TextStyle(fontSize: 14),
      ),
     pw.Divider(thickness: 1),

      // Vehicle & Driver Info
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Vehicle Code: ${tripData?['xvehicle']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                "Vehicle Regn No: ${tripData?['xvmregno']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                "Driver Name: ${tripData?['xdriver']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                "Driver Mobile: ${tripData?['xmobile']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "From: ${tripData?['xsdestin']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                "Destination: ${tripData?['xdestin']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                "Billing Unit: ${tripData?['xproj']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                "Departure Date: ${tripData?['xouttime'] != null ? DateFormat('dd MMMM yyyy').format(DateTime.parse(tripData?['xouttime'])) : 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Row(
        children: [
          pw.Container(
            width: 70,
            height: 70,
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
            child: pw.Center(
              child: pw.BarcodeWidget(
                barcode: Barcode.qrCode(), // Generate QR Code
                data: "Challan No: ${tripData?['xsornum']}\n"
                    "From: ${tripData?['xsdestin']}\n"
                    "Destination: ${tripData?['xdestin']}\n"
                    "Billing Unit: ${tripData?['xproj']}\n"
                    "Departure Date: ${tripData?['xouttime']}",
                width: 60,
                height: 60,
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Container(
              padding: pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text("Description of Freight",
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Divider(),
                  pw.Text("${tripData?['xtypecat'] ?? 'N/A'}",
                      style: pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Container(
            width: 100,
            padding: pw.EdgeInsets.all(5),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
            child: pw.Column(
              children: [
                pw.Text("Weight",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.Text("${tripData?['xinweight']?.toString() ?? 'N/A'} MT",
                    style: pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),

      // Bangla Text with Image
      pw.Center(
        child: pw.Image(
          pw.MemoryImage(imageBytes),
          width: 200,
        )
      ),

      pw.SizedBox(height: 5),

      // Signature & Time
      pw.Text("Signature: "),
      pw.SizedBox(height: 9),
      pw.Text("Date & Time: "),
      pw.SizedBox(height: 11),

      // Footer Note
      pw.Center(
        child: pw.Text(
          "This is a system-generated challan. No signature is required.",
          style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
        ),
      ),
      pw.SizedBox(height: 28),
    ],
  );
}

/*
pw.Widget buildDeliveryChallan(
    Map<String, dynamic>? tripData, pw.Font banglaFont) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Center(
        child: pw.Text("T.K. LOGISTICS",
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      ),
      pw.SizedBox(height: 5),
      pw.Center(
        child: pw.Text("Delivery Challan",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ),
      pw.SizedBox(height: 10),
      pw.Text(
        "Challan No: ${tripData?['xsornum']?.toString() ?? 'N/A'}",
        style: pw.TextStyle(fontSize: 14),
      ),
      pw.Divider(thickness: 1),

      // Vehicle & Driver Info
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Vehicle Code: ${tripData?['xvehicle']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                "Vehicle Reg No: ${tripData?['xvmregno']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                "Driver Name: ${tripData?['xdriver']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                "Driver Mobile: ${tripData?['xmobile']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "From: ${tripData?['xsdestin']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                "Destination: ${tripData?['xdestin']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                "Billing Unit: ${tripData?['xproj']?.toString() ?? 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                "Departure Date: ${tripData?['xouttime'] != null ? DateFormat('dd MMMM yyyy').format(DateTime.parse(tripData?['xouttime'])) : 'N/A'}",
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 10),

      // QR Code + Freight Table
      pw.Row(
        children: [
          pw.Container(
            width: 70,
            height: 70,
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
            child: pw.Center(
              child: pw.BarcodeWidget(
                barcode: Barcode.qrCode(), // Generate QR Code
                data: "Challan No: ${tripData?['xsornum']}\n"
                    "From: ${tripData?['xsdestin']}\n"
                    "Destination: ${tripData?['xdestin']}\n"
                    "Billing Unit: ${tripData?['xproj']}\n"
                    "Departure Date: ${tripData?['xouttime']}",
                width: 60,
                height: 60,
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Container(
              padding: pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text("Description of Freight",
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Divider(),
                  pw.Text("${tripData?['xtypecat'] ?? 'N/A'}",
                      style: pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Container(
            width: 100,
            padding: pw.EdgeInsets.all(5),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
            child: pw.Column(
              children: [
                pw.Text("Weight",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.Text("${tripData?['xinweight']?.toString() ?? 'N/A'} MT",
                    style: pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 20),

      // Bangla Text
      pw.Center(
        child: pw.Text(
          "চালান এ উল্লিখিত মালামাল যথাযথভাবে বুঝিয়া পাইলাম",
          style: pw.TextStyle(fontSize: 12, font: banglaFont),
        ),
      ),
      pw.SizedBox(height: 20),

      // Signature & Time
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("Signature: ______________________"),
          pw.Text("Time: ______________________"),
        ],
      ),
      pw.SizedBox(height: 15),

      // Footer Note
      pw.Center(
        child: pw.Text(
          "This is a system-generated challan. No signature is required.",
          style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
        ),
      ),
      pw.SizedBox(height: 15),
    ],
  );
}
*/
