import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../const/const_values.dart';
import '../../../../../util/app_color.dart';
import '../../../../auth/login/controller/user_controller.dart';

class UpdateMaintenanceController extends GetxController {
  final userController = Get.find<UserController>();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverPhoneController = TextEditingController();
  var maintenanceDateController = TextEditingController();
  var workshopNameController = RxnString();
  var costController = TextEditingController();

  var latestEntry = Rxn<Map<String, String>>();
  var selectedVehicle = RxnString();
  var selectedWorkshopType = RxnString();
  var selectedSubType = RxnString();
  var isWorkshopNameEnabled = false.obs;

  RxMap<String, dynamic> modifiedFormData = <String, dynamic>{}.obs;

  Rx<DateTime?> inTime = Rx<DateTime?>(null);
  Rx<DateTime?> estOutTime = Rx<DateTime?>(null);
  Rx<DateTime?> actOutTime = Rx<DateTime?>(null);
  late TextEditingController inTimeController;
  late TextEditingController estOutTimeController;
  late TextEditingController actOutTimeController;

  var selectedVehicleNumbers = "".obs;
  var selectedDriverName = "".obs;
  var selectedDriverMobile = "".obs;
  RxList<String> vehicleID = <String>[].obs;
  RxList<String> vehicleNumbers = <String>[].obs;
  RxList<Map<String, dynamic>> vehicleData = <Map<String, dynamic>>[].obs;

  var records = <Map<String, String>>[].obs;

  var selectedDate = DateTime.now().obs;
  void pickDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
  }

  final List<String> workshopTypes = ["T.K. Central Workshop", "3rd Party Workshop"];

  var workshopNameList = <String>[].obs;
  var selectedWorkshopName = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchVehicleNumbers();
    fetchWorkshopNames();

    inTimeController = TextEditingController();
    estOutTimeController = TextEditingController();
    actOutTimeController = TextEditingController();

    ever(inTime, (DateTime? val) {
      inTimeController.text = val != null ? DateFormat('yyyy-MM-dd HH:mm').format(val) : '';
    });

    ever(estOutTime, (DateTime? val) {
      estOutTimeController.text = val != null ? DateFormat('yyyy-MM-dd HH:mm').format(val) : '';
    });

    ever(actOutTime, (DateTime? val) {
      actOutTimeController.text = val != null ? DateFormat('yyyy-MM-dd HH:mm').format(val) : '';
    });
  }

  void onWorkshopTypeChanged(String? value) {
    selectedWorkshopType.value = value;
    if (value == "3rd Party Workshop") {
      fetchWorkshopNames();
    } else {
      selectedWorkshopName.value = '';
/*
      workshopNameController.clear();
*/
    }
  }

  Future<void> fetchWorkshopNames() async {
    final url = 'http://103.250.68.75/api/v1/dropdown_list?xtype=Workshop';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        workshopNameList.value = results
            .map((item) => item['xcode'].toString())
            .where((x) => x.isNotEmpty)
            .toList();
      } else {
        Get.snackbar("Error", "Failed to load workshop list");
      }
    } catch (e) {
      Get.snackbar("Error", "Workshop list error: $e");
    }
  }

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
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
      }
    }
  }

  Future<void> fetchVehicleNumbers() async {
    int page = 1;
    bool hasNextPage = true;

    vehicleData.clear();
    vehicleID.clear();

    while (hasNextPage) {
      String apiUrl = "http://103.250.68.75/api/v1/vehicle_list?page=$page";

      try {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data.containsKey('results') && data['results'] is List) {
            final newVehicles = List<Map<String, dynamic>>.from(data['results']);
            vehicleData.addAll(newVehicles);

            for (var vehicle in newVehicles) {
              String vehicleNumber = vehicle['xvehicle'].toString();
              if (!vehicleID.contains(vehicleNumber)) {
                vehicleID.add(vehicleNumber);
              }
            }
          } else {
            hasNextPage = false;
          }

          if (data['next'] != null) {
            page++;
          } else {
            hasNextPage = false;
          }
        } else {
          hasNextPage = false;
        }
      } catch (e) {
        hasNextPage = false;
      }
    }
  }

  void onVehicleSelected(String selectedVehicle) {
    var emptyValue = "Not available";
    var selectedVehicleData = vehicleData.firstWhere(
          (item) => item['xvehicle'] == selectedVehicle,
      orElse: () => <String, dynamic>{},
    );

    if (selectedVehicleData.isNotEmpty) {
      selectedVehicleNumbers.value = selectedVehicleData["xvmregno"]?.toString() ?? emptyValue;
      selectedDriverName.value = selectedVehicleData["xname"]?.toString() ?? emptyValue;
      selectedDriverMobile.value = selectedVehicleData['xmobile']?.toString() ?? emptyValue;
    } else {
      selectedVehicleNumbers.value = emptyValue;
      selectedDriverName.value = emptyValue;
      selectedDriverMobile.value = emptyValue;
    }

    vehicleNumberController.text = selectedVehicleNumbers.value;
    driverNameController.text = selectedDriverName.value;
    driverPhoneController.text = selectedDriverMobile.value;

    update();
  }

  void addRecord() {
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

    if (selectedWorkshopType.value == "3rd Party Workshop" &&
        (selectedWorkshopName.value?.trim().isEmpty ?? true)) {
      Get.snackbar(
        "Error",
        "Please select a Workshop Name for 3rd Party Workshop",
        snackPosition: SnackPosition.TOP,
        colorText: AppColor.white,
        backgroundColor: AppColor.primaryRed,
      );
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    records.assignAll([
      {
        "vehicleNumber": selectedVehicle.value!,
        "maintenanceDate": formattedDate,
        "workshopType": selectedWorkshopType.value!,
        "workshopName": selectedWorkshopType.value == "T.K. Central Workshop"
            ? ""
            : selectedWorkshopName.value!,
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
      "xdate": inTime.value != null ? DateFormat('yyyy-MM-dd').format(inTime.value!) : null,
      "xintime": inTime.value != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(inTime.value!) : null,
      "xlotime": estOutTime.value != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(estOutTime.value!) : null,
      "xouttime": actOutTime.value != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(actOutTime.value!) : null,
      "workshop_type": selectedWorkshopType.value,
      "workshop_name": selectedWorkshopType.value == "T.K. Central Workshop"
          ? "T.K. Central Workshop"
          : selectedWorkshopName.value,
      "total_cost": costController.text.trim(),
      "zemail": userController.user.value?.username,
      "zid": 100010,
      "Maintenance_details": [],
    };

    modifiedFormData.assignAll(data);
    modifiedFormData.remove('Maintenance_details');
    return modifiedFormData;
  }

  void clearFields() {
    costController.clear();
    selectedWorkshopName.value = null;
    vehicleNumberController.clear();
    driverNameController.clear();
    driverPhoneController.clear();
    maintenanceDateController.clear();
    selectedWorkshopType.value = null;
    selectedVehicle.value = null;
    selectedDriverName.value = "";
    selectedDriverMobile.value = "";
    inTimeController.dispose();
    estOutTimeController.dispose();
    actOutTimeController.dispose();
  }

  Future<void> loadMaintenanceDetails(String maintenanceId) async {
    try {
      final url = "${baseUrl}/maintenance/$maintenanceId/";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Update the controller fields
        selectedVehicle.value = data["vehicle_code"];
        vehicleNumberController.text = data["vehicle_number"] ?? "";
        driverNameController.text = data["driver_name"] ?? "";
        driverPhoneController.text = data["driver_phone"] ?? "";
        selectedWorkshopType.value = data["workshop_type"];
        selectedWorkshopName.value = data["workshop_name"] ?? "";
        costController.text = data["total_cost"] ?? "";

        inTime.value = DateTime.tryParse(data["xintime"] ?? "");
        estOutTime.value = DateTime.tryParse(data["xlotime"] ?? "");
        actOutTime.value = DateTime.tryParse(data["xouttime"] ?? "");

        // Set initial record for the table (if needed)
        final formattedDate = data["xdate"] ?? "";
        records.assignAll([
          {
            "vehicleNumber": selectedVehicle.value ?? "",
            "maintenanceDate": formattedDate,
            "workshopType": selectedWorkshopType.value ?? "",
            "workshopName": selectedWorkshopName.value ?? "",
            "cost": costController.text,
          }
        ]);
      } else {
        print("Failed to fetch maintenance details. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading maintenance details: $e");
    }
  }

  Future<bool> updateMaintenance(String maintenanceId) async {
    final url = "$baseUrl/maintenance/$maintenanceId/";

    // Collect form data
    final body = await collectMainFormDataLocally();

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      print("PUT $url response status: ${response.statusCode}");
      print("PUT $url response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar("Success", "Maintenance updated successfully",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        return true;
      } else {
        Get.snackbar("Error", "Failed to update maintenance: ${response.statusCode}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
  }
}