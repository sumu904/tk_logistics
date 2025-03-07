

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:tk_logistics/features/auth/login/controller/user_controller.dart';
import 'dart:convert';

import '../../../../../util/app_color.dart';

class DieselEntryController extends GetxController {
  final userController = Get.find<UserController>();
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
  var fuelEntries = <Map<String, dynamic>>[].obs; // Store fuel entries
  var isLoading = false.obs;

  RxString selectedVehicleNumbers = "Not Found".obs;
  RxString selectedDriverName = "Not Found".obs;
  RxList<Map<String, dynamic>> vehicleData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVehicleNumbers();
    fetchFuelEntries();
  }
  @override
  void onClose() {
    vehicleController.dispose();
    driverController.dispose();
    dieselAmountController.dispose();
    pumpNameController.dispose();
    vehicleNumberController.dispose();
    driverNameController.dispose();
    super.onClose();
  }

  ///fetch vehicle numbers
  Future<void> fetchVehicleNumbers() async {
    String apiUrl = "http://103.250.68.75/api/v1/vehicle_list";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('results') && data['results'] is List) {
          vehicleData.assignAll(List<Map<String, dynamic>>.from(data['results']));
          vehicleID.assignAll(vehicleData.map((item) => item['xvehicle'].toString()).toList());
        }
      }
    } catch (e) {
      print("Error fetching vehicle numbers: $e");
    }
  }


  ///  fetch fuelentries
  Future<void> fetchFuelEntries() async {
    String apiUrl = "http://103.250.68.75:8055/api/v1/vmfuelentry_list";
    isLoading.value = true;

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body); // ✅ Fix here

        // Convert to list of maps and store in observable list
        if (data.containsKey('results') && data['results'] is List) {
          fuelEntries.assignAll(List<Map<String, dynamic>>.from(data['results']));
          print("Fuel Entries Fetched: ${fuelEntries.length}");
        } else {
          print("Unexpected API Response Format: Missing 'results' key");
          fuelEntries.clear();
        }
      } else {
        print("Failed to fetch fuel entries: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching fuel entries: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onVehicleSelected(String selectedVehicle) {
    var selectedVehicleData = vehicleData.firstWhere(
          (item) => item['xvehicle'] == selectedVehicle,
      orElse: () => <String, dynamic>{},
    );

    if (selectedVehicleData.isNotEmpty) {
      selectedVehicleNumbers.value = (selectedVehicleData["xvmregno"] as String?) ?? "Not Available";
      selectedDriverName.value = (selectedVehicleData["xname"] as String?) ?? "Not Available";
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

  Future<void> addEntry() async {
    if (selectedVehicle.value == null ||
        selectedDate.value == null ||
        dieselAmountController.text.isEmpty ||
        pumpNameController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        snackPosition: SnackPosition.TOP,
        colorText: AppColor.white,
        backgroundColor: AppColor.primaryRed,
      );
      return;
    }

    double? dieselAmount = double.tryParse(dieselAmountController.text);
    if (dieselAmount == null) {
      Get.snackbar(
        "Error",
        "Please enter a valid diesel amount",
        snackPosition: SnackPosition.TOP,
        colorText: AppColor.white,
        backgroundColor: AppColor.primaryRed,
      );
      return;
    }

    // Prepare request body according to API format
    Map<String, dynamic> requestBody = {
      "zid": 100010, // Static or dynamic based on your requirements
      "xdate": DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate.value!), // Adjusted format
      "xvehicle": selectedVehicle.value,
      "xvmregno": selectedVehicleNumbers.value,
      "xdriver": selectedDriverName.value,
      "xqtyord": dieselAmount,
      "xunit": "Ltr", // Assuming diesel is measured in liters
      "xwh": pumpNameController.text, // Modify if needed
      "zemail": userController.user.value?.username ,// Modify if needed
    };

    String apiUrl = "http://103.250.68.75/api/v1/vmfuelentry/new";

    print("Sending request to: $apiUrl");
    print("Request Body: ${json.encode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      );

      print("Response Status Code: ${response.statusCode}");
      print("POSTED Body: ${response.body}");
      Map<String, dynamic> responseMap = jsonDecode(response.body);

      // Extract the value of "xtrnnum"
      /*String? transactionNo = responseMap['xtrnnum']?.toString();

      // Print the value
      print('TransactionNo: $transactionNo');*/

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Diesel entry added successfully",
          snackPosition: SnackPosition.TOP,
          colorText: AppColor.white,
          backgroundColor: AppColor.seaGreen,
        );
        await fetchFuelEntries();

        // Clear inputs after successful submission
        selectedVehicle.value = null;
        selectedVehicleNumbers.value = "Not Found";
        selectedDriverName.value = "Not Found";
        dieselAmountController.clear();
        pumpNameController.clear();
        selectedDate.value = null;
      }
      else {
        Get.snackbar(
          "Error",
          "Failed to submit entry",
          snackPosition: SnackPosition.TOP,
          colorText: AppColor.white,
          backgroundColor: AppColor.primaryRed,
        );
        print("Error Response: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        snackPosition: SnackPosition.TOP,
        colorText: AppColor.white,
        backgroundColor: AppColor.primaryRed,
      );
    }
  }
}
