import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../util/app_color.dart';

class MaintenanceController extends GetxController {
  // Text controllers
  var transactionNumber = "System Generate".obs;
  var vehicleController = TextEditingController();
  var maintenanceDateController = TextEditingController();
  var notesController = TextEditingController();
  var workshopNameController = TextEditingController();
  var costController = TextEditingController();

  // Dropdown selections
  var latestEntry = Rxn<Map<String, String>>();
  var selectedVehicle = RxnString();
  var selectedMaintenanceType = RxnString();
  var selectedWorkshopType = RxnString();
  var selectedDate = Rxn<DateTime>();
  var isWorkshopNameEnabled = false.obs;

  RxList<String> vehicleNumbers = <String>[].obs;
  RxList<Map<String, dynamic>> vehicleData = <Map<String, dynamic>>[].obs;

  // Dropdown options
  final List<String> maintenanceTypes = [
    "Oil Change",
    "Tire Replacement",
    "Battery Replacement",
    "Brake Service",
    "Other"
  ];
  final List<String> workshopTypes = ["T.K. Central Workshop", "3rd Party Workshop"];

  // Maintenance records
  var records = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVehicleNumbers();
  }
  Future<void> fetchVehicleNumbers() async {
    String apiUrl = "http://103.250.68.75/api/v1/vehicle_list";
    print("Fetching vehicle number from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Check API Response

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print("Decoded JSON: $data"); // Ensure data is properly decoded

          if (data.containsKey('results') && data['results'] is List) {
            vehicleNumbers.value = List<String>.from(
                data['results'].map((item) => item['xvehicle'].toString()));

            print("Fetched Vehicle Number: $vehicleNumbers"); // Check list before UI updates
          } else {
            print("Unexpected API Response Format: 'results' key not found or not a List");
          }
        } catch (jsonError) {
          print("Error decoding JSON: $jsonError");
        }
      } else {
        print("Failed to fetch vehicle numbers: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching locations: $e");
    }
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

  void addRecord() {
    print("Selected Vehicle: ${selectedVehicle.value}");
    print("Maintenance Type: ${selectedMaintenanceType.value}");
    print("Workshop Type: ${selectedWorkshopType.value}");
    print("Workshop Name: ${workshopNameController.text}");
    print("Cost: ${costController.text}");
    print("Date: ${selectedDate.value}");

    if (selectedVehicle.value == null || selectedVehicle.value!.isEmpty ||
        selectedMaintenanceType.value == null || selectedMaintenanceType.value!.isEmpty ||
        selectedWorkshopType.value == null || selectedWorkshopType.value!.isEmpty ||
        costController.text.trim().isEmpty || selectedDate.value == null) {

      Get.snackbar("Error", "Please fill all required fields", snackPosition: SnackPosition.TOP, colorText: AppColor.white,
        backgroundColor: AppColor.primaryRed,);
      return;
    }

    // Validate workshop name if "3rd Party Workshop" is selected
    if (selectedWorkshopType.value == "3rd Party Workshop" && workshopNameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a Workshop Name for 3rd Party Workshop", snackPosition: SnackPosition.TOP,colorText: AppColor.white,
        backgroundColor: AppColor.primaryRed,);
      return;
    }

    // Format date
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value!);

    // Save record
    records.add({
      "transactionNumber": transactionNumber.value,
      "vehicleNumber": selectedVehicle.value!,
      "maintenanceDate": formattedDate,
      "maintenanceType": selectedMaintenanceType.value!,
      "workshopType": selectedWorkshopType.value!,
      "workshopName": selectedWorkshopType.value == "T.K. Central Workshop" ? "N/A" : workshopNameController.text.trim(),
      "cost": costController.text.trim(),
      "notes": notesController.text.trim(),
    });

    latestEntry.value = {
      "maintenanceType": selectedMaintenanceType.value!,
      "workshopType": selectedWorkshopType.value!,
      "workshopName": workshopNameController.text.trim(),
      "cost": costController.text.trim(),
    };

    Get.snackbar("Success", "Record successfully added!", snackPosition: SnackPosition.TOP, colorText: AppColor.white,
      backgroundColor: AppColor.seaGreen,);

    Get.back();
    clearFields();
  }

  void clearFields() {
    vehicleController.clear();
    costController.clear();
    notesController.clear();
    workshopNameController.clear();
    maintenanceDateController.clear();
    selectedVehicle.value = null;
    selectedMaintenanceType.value = null;
   // selectedWorkshopType.value = null;
    selectedDate.value = null;
  }
}