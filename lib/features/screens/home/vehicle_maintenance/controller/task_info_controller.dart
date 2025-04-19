import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/controller/main_form_controller.dart';

import '../../../../../const/const_values.dart';
import '../../../../../util/app_color.dart';
import '../../../../auth/login/controller/user_controller.dart';
import 'main_form_controller.dart';


class TaskInfoController extends GetxController {
  var maintenanceID = ''.obs;
  RxMap<String, dynamic> maintenanceData = <String, dynamic>{}.obs;
  final userController = Get.find<UserController>();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverPhoneController = TextEditingController();
  var maintenanceDateController = TextEditingController();
  var workshopNameController = TextEditingController();
  var costController = TextEditingController();
  var selectedVehicle = RxnString();
  var selectedWorkshopType = RxnString();
  var selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).obs;
  RxList<String> maintenanceTypes = [
    "Engine Check",
    "Tyre Change",
    "Oil Change"
  ].obs;

  RxMap<String, List<String>> subTypeMap = {
    "Engine Check": ["Engine Check1", "Engine Check2"],
    "Tyre Change": ["Front Left", "Front Right", "Rear Left", "Rear Right"],
    "Oil Change": ["Oil Change1", "Oil Change2", "Oil Change3"],
  }.obs;

  RxList<String> subTypes = <String>[].obs;
  RxnString selectedMaintenanceType = RxnString();
  RxnString selectedSubType = RxnString();
  var remarksController = TextEditingController();

  // Tyre Change Details
  RxnString tyreChangeReason = RxnString();
  var oldTyreSNController = TextEditingController();
  RxnString newTyreCondition = RxnString();
  var newTyreSNController = TextEditingController();

  // Determines if Tyre Change UI should be shown
  RxBool isTyreChange = false.obs;

  // List to store entries
  var entries = <Map<String, String>>[].obs;

  bool isMounted = false; // Flag to track widget mount status
  bool isSubmitting = false; // Prevent multiple submissions

  @override
  void onInit() {
    super.onInit();
    isMounted = true; // Set as mounted when controller is initialized
    ever(selectedMaintenanceType, (_) => updateDependentSubTypes());
  }

  @override
  void onClose() {
    isMounted = false; // Set as unmounted when controller is disposed
    super.onClose();
  }

  void updateDependentSubTypes() {
    if (selectedMaintenanceType.value != null) {
      subTypes.value = subTypeMap[selectedMaintenanceType.value] ?? [];
    } else {
      subTypes.clear();
    }

    // Reset subtype selection
    selectedSubType.value = null;

    // Update tyre change UI visibility
    isTyreChange.value = selectedMaintenanceType.value == "Tyre Change";
  }

  final MainFormController mainFormController = Get.find<MainFormController>();


  Future<void> submitMaintenanceData() async {
    if (isSubmitting) {
      Get.snackbar("Info", "Already submitting data, please wait.");
      return;
    }

    if (entries.isEmpty) {
      Get.snackbar("Error", "No maintenance records to submit.");
      return;
    }

    if (maintenanceID.value.isEmpty) {
      Get.snackbar("Error", "Missing maintenance ID. Submit main form first.");
      return;
    }

    isSubmitting = true;

    print("Maintenance ID: $maintenanceID");

    final url = Uri.parse('${baseUrl}/maintenanceheader/');

    final data = {
      "zid": 100000,
      //"maintenance_no": maintenanceID.value,
      "vehicle_code": selectedVehicle.value,
      "vehicle_number": vehicleNumberController.text,
      "driver_name": driverNameController.text,
      "driver_phone": driverPhoneController.text,
      "xdate": DateFormat('yyyy-MM-dd').format(selectedDate.value),
      "workshop_type": selectedWorkshopType.value,
      "workshop_name": workshopNameController.text,
      "zemail": userController.user.value?.username,
      "total_cost": double.tryParse(costController.text) ?? 0.0,
      "Maintenance_details": entries.map((entry) {
        return {
          "maintenance_type": entry["Maintenance Type"],
          "sub_type": entry["Sub Type"] ?? "",
          "remarks": entry["Remarks"],
          "tyre_change_reason": entry["Reason"] ?? "",
          "old_tyre_sn": entry["Old Tyre SN"] ?? "",
          "new_tyre_condition": entry["New Tyre Condition"] ?? "",
          "new_tyre_sn": entry["New Tyre SN"] ?? "",
        };
      }).toList()
    };

    print(" Data to be sent: ${jsonEncode(data)}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      print(" Response status: ${response.statusCode}");
      print(" Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Maintenance details updated successfully!",
          snackPosition: SnackPosition.TOP,
          colorText: AppColor.white,
          backgroundColor: AppColor.seaGreen,
        );
        entries.clear();
      } else {
        Get.snackbar("Error", "Failed to update details: ${response.headers}",
          snackPosition: SnackPosition.TOP,
          colorText: AppColor.white,
          backgroundColor: AppColor.primaryRed,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e",
        snackPosition: SnackPosition.TOP,
        colorText: AppColor.white,
        backgroundColor: AppColor.primaryRed,
      );
    } finally {
      isSubmitting = false;
    }
  }

  // Set the maintenance ID (after main form submission)
  void setMaintenanceID(String id) {
    maintenanceID.value = id;
  }

  // Adds entry to entries list
  void addEntry() {
    print(" Attempting to add entry");
    print(" Controller instance: ${this.hashCode}");
    print(" Entries BEFORE add: ${entries.length}");
    print(" Current entries: $entries");
   // entries.add({...});
    print(" Entries AFTER add: ${entries.length}");
    print(" Updated entries: $entries");


    if (selectedMaintenanceType.value == null || selectedSubType.value?.isEmpty != false) {
      Get.snackbar("Error", "Please fill all required fields",
        snackPosition: SnackPosition.TOP,
        colorText: AppColor.white,
        backgroundColor: AppColor.primaryRed,
      );
      return;
    }

    final newEntry = {
      "Maintenance Type": selectedMaintenanceType.value ?? "",
      "Sub Type": selectedSubType.value ?? "",
      "Remarks": remarksController.text.trim(),
      "Reason": tyreChangeReason.value ?? "",
      "Old Tyre SN": oldTyreSNController.text.trim(),
      "New Tyre Condition": newTyreCondition.value ?? "",
      "New Tyre SN": newTyreSNController.text.trim(),
    };

    // Check for duplicates
    bool alreadyExists = entries.any((entry) =>
    entry["Maintenance Type"] == newEntry["Maintenance Type"] &&
        entry["Sub Type"] == newEntry["Sub Type"] &&
        entry["Remarks"] == newEntry["Remarks"] &&
        entry["Reason"] == newEntry["Reason"] &&
        entry["Old Tyre SN"] == newEntry["Old Tyre SN"] &&
        entry["New Tyre Condition"] == newEntry["New Tyre Condition"] &&
        entry["New Tyre SN"] == newEntry["New Tyre SN"]
    );

    if (alreadyExists) {
      Get.snackbar("Warning", "This record already exists!",
        snackPosition: SnackPosition.TOP,
        colorText: AppColor.white,
        backgroundColor: AppColor.primaryRed,
      );
      return;
    }

    // Save record
    entries.add(newEntry);

    Get.snackbar("Success", "Record successfully added!",
      snackPosition: SnackPosition.TOP,
      colorText: AppColor.white,
      backgroundColor: AppColor.seaGreen,
    );

    clearFields();
  }


  void clearFields() {
    selectedMaintenanceType.value = null;
    selectedSubType.value = null;
    remarksController.clear();
    newTyreCondition.value = null;
    tyreChangeReason.value = null;
    isTyreChange.value = false; // Reset tyre change visibility
  }
}



