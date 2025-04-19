import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/util/app_color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../../../const/const_values.dart';

class QuotationController extends GetxController {
  TextEditingController vehicleNumberController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController offeredPriceController = TextEditingController();

  var pickSupplier = RxnString();
  var vehicleType = RxnString();
  var vehicleNo = RxnString();
  var selectedVehicle =  RxnString();

  RxList<String> pickSuppliers = <String>[].obs;

  final List<String> vehicleTypes = ["Covered Truck", "Open Truck", "Bulk Carrier"];
  final List<String> vehicleNumbers = ["Single vehicle", "Multiple vehicle"];
  final List<String> vehicleNumber = ["ABC-1234", "XYZ-5678", "LMN-9101"];
  Rx<DateTime?> pickupDate = Rx<DateTime?>(null);
  Rx<DateTime?> dropOffDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchSuppliers();
  }

  Future<void> fetchSuppliers() async {
    String apiUrl = "${baseUrl}/dropdown_list?xtype=Supplier";
    print("Fetching locations from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Check API Response

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print("Decoded JSON: $data"); // Ensure data is properly decoded

          if (data.containsKey('results') && data['results'] is List) {
            pickSuppliers.assignAll(List<String>.from(
                data['results'].map((item) => item['xcode'].toString())));
            print("Fetched Suppliers: $pickSuppliers"); // Check list before UI updates
          } else {
            print("Unexpected API Response Format: 'results' key not found or not a List");
          }
        } catch (jsonError) {
          print("Error decoding JSON: $jsonError");
        }
      } else {
        print("Failed to fetch suppliers: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching suppliers: $e");
    }
  }

  /// Function to pick date & time
  Future<void> pickDateTime(Rx<DateTime?> selectedDate) async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      TimeOfDay? time = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        selectedDate.value = DateTime(
            picked.year, picked.month, picked.day, time.hour, time.minute);
      }
    }
  }

  /// Form Submission
  void submitForm() {
    if (pickSuppliers.value.isEmpty ||
        vehicleType.value!.isEmpty ||
        capacityController.text.isEmpty ||
        pickupDate.value == null ||
        dropOffDate.value == null ||
        offeredPriceController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields!", backgroundColor:AppColor.primaryRed,colorText: AppColor.white);
    } else {
      Get.snackbar("Success", "Quotation Submitted", backgroundColor: AppColor.seaGreen,colorText: AppColor.white);
    }
  }
}

