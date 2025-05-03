import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../const/const_values.dart';
import '../../../../../util/app_color.dart';
import '../../../../auth/login/controller/user_controller.dart';

class MainFormController extends GetxController {
  final userController = Get.find<UserController>();
 var transactionNumber = "System Generate".obs;
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverPhoneController = TextEditingController();
  var maintenanceDateController = TextEditingController();
  var workshopNameController = TextEditingController();
  var costController = TextEditingController();

  // Dropdown selections
  var latestEntry = Rxn<Map<String, String>>();
  var selectedVehicle = RxnString();
  var selectedWorkshopType = RxnString();
  var selectedSubType = RxnString();
  var isWorkshopNameEnabled = false.obs;

  RxMap<String, dynamic> modifiedFormData = <String, dynamic>{}.obs;

  void updateFormData(Map<String, dynamic> data) {
    modifiedFormData.assignAll(data);
  }


  var selectedVehicleNumbers = "".obs;
  var selectedDriverName = "".obs;
  var selectedDriverMobile = "".obs;
  RxList<String> vehicleID = <String>[].obs;
  RxList<String> vehicleNumbers = <String>[].obs;
  RxList<Map<String, dynamic>> vehicleData = <Map<String, dynamic>>[].obs;

  var records = <Map<String, String>>[].obs; // Observable list to store records

  var selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).obs;
  void pickDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
  }

  final List<String> workshopTypes = ["T.K. Central Workshop", "3rd Party Workshop"];


  @override
  void onInit() {
    super.onInit();
    fetchVehicleNumbers();
  }
  Future<void> fetchVehicleNumbers() async {
    int page = 1;
    bool hasNextPage = true;

    vehicleData.clear(); // Clear before loading all pages
    vehicleID.clear();

    while (hasNextPage) {
      String apiUrl = "${baseUrl}/vehicle_list?page=$page";
      print("Fetching vehicle numbers from: $apiUrl");

      try {
        final response = await http.get(Uri.parse(apiUrl));
        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print("Decoded JSON (Page $page): $data");

          if (data.containsKey('results') && data['results'] is List) {
            final newVehicles = List<Map<String, dynamic>>.from(data['results']);

            // Add new vehicles to vehicleData
            vehicleData.addAll(newVehicles);

            // Add vehicle numbers to vehicleID, ensuring no duplicates
            for (var vehicle in newVehicles) {
              String vehicleNumber = vehicle['xvehicle'].toString();
              if (!vehicleID.contains(vehicleNumber)) {
                vehicleID.add(vehicleNumber);
              }
            }

            print("Fetched Vehicle Numbers (Page $page): ${newVehicles.map((v) => v['xvehicle'])}");
          } else {
            print("Unexpected API response format at page $page");
            hasNextPage = false;
          }

          if (data['next'] != null) {
            page++; // go to next page
          } else {
            hasNextPage = false; // no more pages
          }
        } else {
          print("Failed to fetch vehicle numbers on page $page");
          hasNextPage = false;
        }
      } catch (e) {
        print("Error fetching vehicle numbers: $e");
        hasNextPage = false;
      }
    }

    print(" All Vehicle Numbers Fetched (${vehicleID.length}): $vehicleID");
  }


  String? lastSelectedVehicle;
  String? lastSelectedVehicleNumbers;
  String? lastSelectedDriverName;
  String? lastSelectedDriverMobile;

  void onVehicleSelected(String selectedVehicle) {
    // Check if the selected vehicle is different from the last selected one

    var emptyValue="Not available";
    lastSelectedVehicle = selectedVehicle; // Update last selected vehicle

    var selectedVehicleData = vehicleData.firstWhere(
          (item) => item['xvehicle'] == selectedVehicle,
      orElse: () => <String, dynamic>{},
    );

    print("Selected Vehicle Data: $selectedVehicleData"); // Debugging line

    if (selectedVehicleData.isNotEmpty) {
      selectedVehicleNumbers.value = selectedVehicleData["xvmregno"]?.toString() ?? emptyValue;
      selectedDriverName.value = selectedVehicleData["xname"]?.toString() ?? emptyValue;
      selectedDriverMobile.value = selectedVehicleData['xmobile']?.toString() ?? emptyValue;
    } else {
      // Reset to default values when no data is found
      selectedVehicleNumbers.value = emptyValue;
      selectedDriverName.value = emptyValue;
      selectedDriverMobile.value = emptyValue;
      print("Selected Vehicle Data is not found");
    }

    // Save the selected values
    if (selectedVehicle == lastSelectedVehicle) {
      print("Same vehicle selected. Retaining previous values.");
      lastSelectedVehicleNumbers = selectedVehicleNumbers.value;
      lastSelectedDriverName = selectedDriverName.value;
      lastSelectedDriverMobile = selectedDriverMobile.value;// Do nothing if the vehicle hasn't changed
    }

    // Update controllers
    vehicleNumberController.text = lastSelectedVehicleNumbers!;
    driverNameController.text = lastSelectedDriverName!;
    driverPhoneController.text = lastSelectedDriverMobile!;

    // Notify the UI to rebuild
    update(); // If using GetX, ensure that this triggers the UI update
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
    //print("Maintenance Type: ${selectedMaintenanceType.value}");
    print("Workshop Type: ${selectedWorkshopType.value}");
    print("Workshop Name: ${workshopNameController.text}");
    print("Cost: ${costController.text}");
    print("Date: ${selectedDate.value}");

    if (selectedVehicle.value == null ||
        selectedVehicle.value!.isEmpty ||
        selectedWorkshopType.value == null ||
        selectedWorkshopType.value!.isEmpty ||
        costController.text.trim().isEmpty ||
        selectedDate.value == null) {
      Get.snackbar("Error", "Please fill all required fields",
        snackPosition: SnackPosition.TOP,
        colorText: AppColor.white,
        backgroundColor: AppColor.primaryRed,
      );
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
    records.assignAll([
      {
        "transactionNumber": transactionNumber.value,
        "vehicleNumber": selectedVehicle.value!,
        "maintenanceDate": formattedDate,
        "workshopType": selectedWorkshopType.value!,
        "workshopName": selectedWorkshopType.value == "T.K. Central Workshop"
            ? ""
            : workshopNameController.text.trim(),
        "cost": costController.text.trim(),
      }
    ]);

    clearFields();

  }
  Future<Map<String, dynamic>> collectMainFormDataLocally() async {
  // Collect the main form data
  final data = {
  "vehicle_code": selectedVehicle.value,
  "vehicle_number": vehicleNumberController.text.trim(),
  "driver_name": driverNameController.text.trim(),
  "driver_phone": driverPhoneController.text.trim(),
  "xdate": DateFormat('yyyy-MM-dd').format(selectedDate.value),
  "workshop_type": selectedWorkshopType.value,
  "workshop_name": selectedWorkshopType.value == "T.K. Central Workshop"
  ? "T.K. Central Workshop"
      : workshopNameController.text.trim(),
  "total_cost": costController.text.trim(),
  "zemail": userController.user.value?.username,
    "zid": 100010,
  "Maintenance_details": [], // Still empty, can be filled on TaskInfo screen
  };

  modifiedFormData.assignAll(data);

  // Remove the 'Maintenance_details' field
  modifiedFormData.remove('Maintenance_details');

  // Print the modified map for debugging
  print("Modified form data: $modifiedFormData");

  return modifiedFormData;
  }


  void clearFields() {
    costController.clear();
    workshopNameController.clear();
    vehicleNumberController.clear();
    driverNameController.clear();
    driverPhoneController.clear();
    maintenanceDateController.clear();
    selectedWorkshopType.value = null;
    selectedVehicle.value = null;
    selectedDriverName.value = "";
    selectedDriverMobile.value = "";
  }
}