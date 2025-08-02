import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/controller/main_form_controller.dart';

import '../../../../../const/const_values.dart';
import '../../../../../util/app_color.dart';
import '../../../../auth/login/controller/user_controller.dart';
import 'package:collection/collection.dart';


class TaskInfoController extends GetxController {
  var maintenanceID = ''.obs;
  RxMap<String, dynamic> maintenanceData = <String, dynamic>{}.obs;

  final userController = Get.find<UserController>();
  final MainFormController mainFormController = Get.find<MainFormController>();

  RxMap<String, dynamic> modifiedFormData = <String, dynamic>{}.obs;


  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverPhoneController = TextEditingController();
  final maintenanceDateController = TextEditingController();
  final workshopNameController = TextEditingController();
  final costController = TextEditingController();

  var selectedVehicle = RxnString();
  var selectedWorkshopType = RxnString();
  var selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).obs;

  RxList<String> maintenanceTypes = <String>[].obs;
  RxMap<String, List<String>> subTypeMap = <String, List<String>>{}.obs;
  RxList<String> subTypes = <String>[].obs;
  RxnString selectedMaintenanceType = RxnString();
  RxList<String> selectedSubType = <String>[].obs;
  RxnString selectedTyreChangeType = RxnString();
  RxList<String> tyreChangeTypes = RxList<String>();
  RxnString selectedTyreConditionType = RxnString();
  RxList<String> tyreConditionTypes = <String>[].obs;

  Rx<DateTime?> inTime = Rx<DateTime?>(null);
  Rx<DateTime?> estOutTime = Rx<DateTime?>(null);
  Rx<DateTime?> actOutTime = Rx<DateTime?>(null);
  late TextEditingController inTimeController;
  late TextEditingController estOutTimeController;
  late TextEditingController actOutTimeController;

  final remarksController = TextEditingController();

  // Tyre Replacement Fields
  RxnString tyreChangeReason = RxnString();
  final oldTyreSNController = TextEditingController();
  RxnString newTyreCondition = RxnString();
  final newTyreSNController = TextEditingController();

  RxBool isTyreReplacement = false.obs;
  var entries = <Map<String, String>>[].obs;


  bool isMounted = false;
  bool isSubmitting = false;
  var areSubTypesFetched = false.obs;

  @override
  void onInit() {
    super.onInit();

    ever(mainFormController.modifiedFormData, (data) {
      modifiedFormData.assignAll(data);
    });

    // Listen for changes in selectedMaintenanceType
    ever(selectedMaintenanceType, (_) => updateDependentSubTypes());

    // Fetch maintenance types and subtypes
    fetchMaintenanceTypes();
    fetchSubTypes();
    fetchTyreChangeTypes();
    fetchTyreConditionTypes();

    inTimeController = TextEditingController();
    estOutTimeController = TextEditingController();
    actOutTimeController = TextEditingController();

    ever(inTime, (DateTime? val) {
      inTimeController.text = val != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(val)
          : '';
    });

    ever(estOutTime, (DateTime? val) {
      estOutTimeController.text = val != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(val)
          : '';
    });

    ever(actOutTime, (DateTime? val) {
      actOutTimeController.text = val != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(val)
          : '';
    });
  }

  @override
  void onClose() {
    isMounted = false;
    super.onClose();
  }

  void showSnack(String title, String message, Color color) {
    Get.snackbar(
      title, message,
      snackPosition: SnackPosition.TOP,
      colorText: AppColor.white,
      backgroundColor: color,
    );
  }

  Future<void> fetchMaintenanceTypes() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}/dropdown_list?xtype=Maintenance_Type'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map && jsonResponse.containsKey('results')) {
          final results = jsonResponse['results'] as List;
          maintenanceTypes.value = results.map((item) => item['xcode'].toString()).toList();
        } else {
          showSnack("Error", "Invalid response format", AppColor.primaryRed);
        }
      } else {
        showSnack("Error", "Failed to load maintenance types", AppColor.primaryRed);
      }
    } catch (e) {
      showSnack("Error", "Exception: $e", AppColor.primaryRed);
    }
  }

  Future<void> fetchSubTypes() async {
    try {
      // Fetch Tyre Replacement subtypes
      final tyreResponse = await http.get(Uri.parse('${baseUrl}/dropdown_list?xtype=Maintenance_subType&xcodealt=1'));
      // Fetch other maintenance subtypes
      final otherResponse = await http.get(Uri.parse('${baseUrl}/dropdown_list?xtype=Maintenance_subType&xcodealt=0'));

      if (tyreResponse.statusCode == 200 && otherResponse.statusCode == 200) {
        final tyreJson = jsonDecode(tyreResponse.body);
        final otherJson = jsonDecode(otherResponse.body);

        if (tyreJson.containsKey('results') && otherJson.containsKey('results')) {
          // Tyre Replacement types
          subTypeMap["Tyre Replacement"] = List<String>.from(tyreJson['results'].map((item) => item['xcode'].toString()));

          // Other types — REMOVE DUPLICATES
          final otherList = List<String>.from(otherJson['results'].map((item) => item['xcode'].toString()));

          // Use Set to remove duplicates
          subTypeMap["Other"] = otherList.toSet().toList();

          areSubTypesFetched.value = true;
        } else {
          showSnack("Error", "Invalid subtype response", AppColor.primaryRed);
        }
      } else {
        showSnack("Error", "Failed to fetch subtypes", AppColor.primaryRed);
      }
    } catch (e) {
      showSnack("Error", "Exception: $e", AppColor.primaryRed);
    }
  }

  Future<void> fetchTyreChangeTypes() async {
    try {
      final response = await http.get(Uri.parse('http://103.250.68.75/api/v1/dropdown_list?xtype=Tyre_Change'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map && jsonResponse.containsKey('results')) {
          final results = jsonResponse['results'] as List;
          tyreChangeTypes.value = results.map((item) => item['xcode'].toString()).toList();
        } else {
          showSnack("Error", "Invalid response format", AppColor.primaryRed);
        }
      } else {
        showSnack("Error", "Failed to load tyre change types", AppColor.primaryRed);
      }
    } catch (e) {
      showSnack("Error", "Exception: $e", AppColor.primaryRed);
    }
  }

  // Function to fetch Tyre Condition Types
  Future<void> fetchTyreConditionTypes() async {
    try {
      final response = await http.get(Uri.parse('http://103.250.68.75/api/v1/dropdown_list?xtype=Tyre_Condition'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map && jsonResponse.containsKey('results')) {
          final results = jsonResponse['results'] as List;
          tyreConditionTypes.value = results.map((item) => item['xcode'].toString()).toList();
        } else {
          showSnack("Error", "Invalid response format", AppColor.primaryRed);
        }
      } else {
        showSnack("Error", "Failed to load tyre condition types", AppColor.primaryRed);
      }
    } catch (e) {
      showSnack("Error", "Exception: $e", AppColor.primaryRed);
    }
  }




  void updateDependentSubTypes() {
    if (!areSubTypesFetched.value) return; // Wait until subtypes are fetched

    // First CLEAR old subtypes
    subTypes.clear();
    selectedSubType.clear(); // Also clear selected subtypes

    if (selectedMaintenanceType.value == "Tyre Replacement") {
      subTypes.assignAll(subTypeMap["Tyre Replacement"] ?? []);
      isTyreReplacement.value = true;
    } else {
      subTypes.assignAll(subTypeMap["Other"] ?? []);
      isTyreReplacement.value = false;
    }

    print("Updated Subtypes for ${selectedMaintenanceType.value}: $subTypes");
  }



 /* void setMaintenanceID(String id) {
    maintenanceID.value = id;
  }*/

   addEntry() {
    if (!validateEntryForm()) return;

    final newEntry = {
      "Maintenance Type": selectedMaintenanceType.value ?? "",
      "Sub Type": selectedSubType.join(", "),
      "Remarks": remarksController.text.trim(),
      "Reason": tyreChangeReason.value ?? "",
      "Old Tyre SN": oldTyreSNController.text.trim(),
      "New Tyre Condition": newTyreCondition.value ?? "",
      "New Tyre SN": newTyreSNController.text.trim(),
    };


    final entryString = newEntry.map((k, v) => MapEntry(k, v.toString()));

    bool alreadyExists = entries.any((entry) =>
        MapEquality().equals(entry, entryString));

    if (alreadyExists) {
      showSnack("Warning", "This record already exists!", AppColor.primaryRed);
      return;
    }

    entries.add(entryString);
    showSnack("Success", "Record successfully added!", AppColor.seaGreen);
    clearFields();
  }

  bool validateEntryForm() {
    if (selectedMaintenanceType.value == null || selectedSubType.value?.isEmpty != false) {
      showSnack("Error", "Please fill all required fields", AppColor.primaryRed);
      return false;
    }
    return true;
  }

  void clearFields() {
    selectedMaintenanceType.value = null;
    selectedSubType.clear();
    remarksController.clear();
    tyreChangeReason.value = null;
    oldTyreSNController.clear();
    newTyreCondition.value = null;
    newTyreSNController.clear();
    subTypes.clear();
    isTyreReplacement.value = false;
  }

  Future<void> submitMaintenanceData() async {
    if (inTime.value == null) {
      Get.snackbar("Validation Error", "In-Time must be selected");
      return;
    }

    if (isSubmitting) {
      showSnack("Info", "Already submitting, please wait.", AppColor.primaryRed);
      return;
    }

    if (entries.isEmpty) {
      showSnack("Error", "No records to submit.", AppColor.primaryRed);
      return;
    }

    if (maintenanceID.value == null || maintenanceID.value.trim().isEmpty) {
      showSnack("Error", "Missing maintenance ID. Submit main form first.", AppColor.primaryRed);
      return;
    }

    isSubmitting = true;

    final xDate = DateFormat('yyyy-MM-dd').format(inTime.value!);

    final url = Uri.parse('${baseUrl}/maintenanceheader/');
    final data = {
      "zid": 100010,
      "vehicle_code": selectedVehicle.value,
      "vehicle_number": vehicleNumberController.text,
      "driver_name": driverNameController.text,
      "driver_phone": driverPhoneController.text,
      "xdate": xDate,
      "xintime": inTime.value != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(inTime.value!)
          : null,
      "xlotime": estOutTime.value != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(estOutTime.value!)
          : null,
      "xouttime": actOutTime.value != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(actOutTime.value!)
          : null,
      "workshop_type": selectedWorkshopType.value,
      "workshop_name": mainFormController.selectedWorkshopType.value == "T.K. Central Workshop"
          ? "T.K. Central Workshop"
          : mainFormController.selectedWorkshopName.value ?? "",
      "zemail": userController.user.value?.username ?? '',
      "total_cost": double.tryParse(costController.text) ?? 0.0,
      "Maintenance_details": entries.map((entry) => {
        "maintenance_type": entry["Maintenance Type"],
        "sub_type": entry["Sub Type"] ?? "",
        "remarks": entry["Remarks"],
        "tyre_change_reason": entry["Reason"] ?? "",
        "old_tyre_sn": entry["Old Tyre SN"] ?? "",
        "new_tyre_condition": entry["New Tyre Condition"] ?? "",
        "new_tyre_sn": entry["New Tyre SN"] ?? "",
        "zid": 100010,
      }).toList()
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSnack("Success", "Maintenance details submitted successfully!", AppColor.seaGreen);
        entries.clear();
      } else {
        showSnack("Error", "Failed to submit: ${response.body}", AppColor.primaryRed);
      }
    } catch (e) {
      showSnack("Error", "Exception: $e", AppColor.primaryRed);
    } finally {
      isSubmitting = false;
    }
  }
}

