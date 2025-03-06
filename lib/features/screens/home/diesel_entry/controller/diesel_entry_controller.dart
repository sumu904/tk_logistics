
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../util/app_color.dart';

class DieselEntryController extends GetxController {
  var vehicleController = TextEditingController();
  var driverController = TextEditingController();
  var dieselAmountController = TextEditingController();
  var pumpNameController = TextEditingController();
  var vehicleNumberController = TextEditingController();
  var driverNameController = TextEditingController();
  var selectedDate = Rxn<DateTime>();
  var latestEntry = Rxn<Map<String, String>>();
  var vehicleNo = RxnString();
  var driverName = RxnString();
  RxList<String> vehicleID = <String>[].obs;
  RxnString selectedVehicle = RxnString();

  RxString selectedVehicleNumbers = "Not Found".obs;
  RxString selectedDriverName = "Not Found".obs;
  RxList<Map<String, dynamic>> vehicleData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVehicleNumbers();
  }

  Future<void> fetchVehicleNumbers() async {
    String apiUrl = "http://103.250.68.75/api/v1/vehicle_list";
    print("Fetching vehicle numbers from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Decoded JSON: $data");

        if (data.containsKey('results') && data['results'] is List) {
          vehicleData.assignAll(List<Map<String, dynamic>>.from(data['results']));
          vehicleID.assignAll(vehicleData.map((item) => item['xvehicle'].toString()).toList());

          print("Fetched Vehicle ID: $vehicleID");
        } else {
          print("Unexpected API Response Format for vehicle numbers");
        }
      } else {
        print("Failed to fetch vehicle numbers: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching vehicle numbers: $e");
    }
  }

  void onVehicleSelected(String selectedVehicle) {
    print("Vehicle Selected: $selectedVehicle");
    void updateTextFieldValue(String newValue) {
      vehicleNumberController.text = newValue;
      update(); // Notify UI to rebuild
    }

    // Find the selected vehicle data from the list
    var selectedVehicleData = vehicleData.firstWhere(
          (item) => item['xvehicle'] == selectedVehicle,
      orElse: () => <String, dynamic>{}, // Returns an empty Map if not found
    );

    if (selectedVehicleData.isNotEmpty) {
      selectedVehicleNumbers.value = (selectedVehicleData["xvmregno"] as String?) ?? "Not Available";
      selectedDriverName.value = (selectedVehicleData["xname"] as String?) ?? "Not Available";


      update(); // Notify UI if using GetX or setState
      print("Driver Data Updated: ${selectedVehicleNumbers.value} - ${selectedDriverName.value}");
    } else {
      selectedVehicleNumbers.value = "Not Found";
      selectedDriverName.value = "Not Found";
    }
    update();
  }


  void selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  void addEntry() {
    if (vehicleID == null ||
        selectedDate.value == null ||
        dieselAmountController.text.isEmpty ||
        pumpNameController.text.isEmpty) { // Added checks for vehicleNo & driverName
      Get.snackbar("Error", "Please fill all fields",
          snackPosition: SnackPosition.TOP,colorText: AppColor.white,backgroundColor: AppColor.primaryRed);
      return;
    }

    if (double.tryParse(dieselAmountController.text) == null) {
      Get.snackbar("Error", "Please enter a valid diesel amount",
          snackPosition: SnackPosition.TOP,colorText: AppColor.white,backgroundColor: AppColor.primaryRed);
      return;
    }

    latestEntry.value = {
      "vehicle": vehicleID.isNotEmpty ? vehicleID.first : "Unknown Vehicle",
      "vehicleNumbers": selectedVehicleNumbers.value ,// Use default if null
      "driver": selectedDriverName.value,  // Use default if null
      "date": selectedDate.value != null
          ? DateFormat('yyyy-MM-dd').format(selectedDate.value!)
          : "Unknown Date",
      "diesel": dieselAmountController.text,
      "pump": pumpNameController.text,
    };

  // Clear inputs
    vehicleNo.value = null;
    driverName.value = null;
    dieselAmountController.clear();
    pumpNameController.clear();
    selectedDate.value = null;
  }
}