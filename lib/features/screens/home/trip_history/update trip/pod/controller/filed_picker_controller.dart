import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:tk_logistics/features/screens/home/trip_history/update%20trip/3ms/controller/update_3ms_controller.dart';

import 'package:tk_logistics/features/screens/home/trip_history/update%20trip/tms/controller/update_tms_controller.dart';
import '../../../../../../../const/const_values.dart';
import '../screen/proof_of_delivery_screen_tms.dart';

class FilePickerController extends GetxController {
  var selectedFileName = "No file selected".obs;
  Rx<File?> selectedFile = Rx<File?>(null);
  var isUploading = false.obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      selectedFile.value = file;
      selectedFileName.value = pickedFile.name;
    } else {
      selectedFileName.value = "No image selected";
    }
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      selectedFile.value = file;
      selectedFileName.value = result.files.single.name;
    } else {
      selectedFileName.value = "No file selected";
    }
  }

  Future<void> uploadFile({
    required String tripId,
    required Future<void> Function(String tripId) fetchTripDetails,
    required RxBool isDataLoading,
  }) async {
    if (tripId.isEmpty) {
      print("Error: Trip ID is not available.");
      return;
    }

    if (selectedFile.value == null) {
      print("Error: No file selected.");
      return;
    }

    File fileToUpload = selectedFile.value!;
    String fileExtension = fileToUpload.path.split('.').last.toLowerCase();

    String? mimeType;
    if (fileExtension == 'pdf') {
      mimeType = 'application/pdf';
    } else if (['jpg', 'jpeg'].contains(fileExtension)) {
      mimeType = 'image/jpeg';
    } else if (fileExtension == 'png') {
      mimeType = 'image/png';
    } else {
      print("Error: Unsupported file type: $fileExtension");
      return;
    }

    try {
      isUploading.value = true;

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse("${baseUrl}/trip/uploadtripdocs/$tripId/"),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'xlink',
        fileToUpload.path,
        filename: "$tripId.$fileExtension",
        contentType: MediaType.parse(mimeType),
      ));

      request.fields['tripId'] = tripId;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      Get.back(); // Close the loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("File uploaded successfully for Trip ID: $tripId");

        try {
          var responseData = jsonDecode(responseBody);
          if (responseData.containsKey('xlink')) {
            print("File link: ${responseData['xlink']}");
          } else {
            print("File uploaded, but 'xlink' not found.");
          }
        } catch (e) {
          print("Failed to parse response JSON: $e");
        }

        // Reload trip details for the given controller
        isDataLoading.value = true;
        await fetchTripDetails(tripId);
        isDataLoading.value = false;

        Get.snackbar("Success", "Proof of Delivery uploaded successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);

      } else {
        print("Failed to upload file: ${response.statusCode}");
        print("Error response: $responseBody");
      }
    } catch (e) {
      print("Error uploading file: $e");
    } finally {
      isUploading.value = false;
    }
  }


  String _parseError(String respStr) {
    try {
      final errorData = jsonDecode(respStr);
      return errorData['detail'] ?? errorData.toString();
    } catch (_) {
      return respStr;
    }
  }
}
