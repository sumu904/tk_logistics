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
    String apiUrl = "${baseUrl}/vehicle_list";
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

          print("Fetched Vehicle Numbers: $vehicleID");
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
    final data = {
      "vehicle_code": selectedVehicle.value,
      "vehicle_number": vehicleNumberController.text.trim(),
      "driver_name": driverNameController.text.trim(),
      "driver_phone": driverPhoneController.text.trim(),
      "xdate": DateFormat('yyyy-MM-dd').format(selectedDate.value),
      "workshop_type": selectedWorkshopType.value,
      "workshop_name": selectedWorkshopType.value == "T.K. Central Workshop"
          ? "N/A"
          : workshopNameController.text.trim(),
      "total_cost": costController.text.trim(),
      "zemail": userController.user.value?.username,
      "zid": 100000,
      "Maintenance_details": [], // Still empty, can be filled on TaskInfo screen
    };

    return data;
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