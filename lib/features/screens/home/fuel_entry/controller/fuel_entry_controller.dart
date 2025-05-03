import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tk_logistics/features/auth/login/controller/user_controller.dart';
import 'dart:convert';

import '../../../../../const/const_values.dart';
import '../../../../../util/app_color.dart';

class FuelEntryController extends GetxController {
  final userController = Get.find<UserController>();
  var vehicleController = TextEditingController();
  var driverController = TextEditingController();
  var dieselAmountController = TextEditingController();
  var pumpNameController = TextEditingController();
  var vehicleNumberController = TextEditingController();
  var driverNameController = TextEditingController();
  var ratePerLtrController = TextEditingController();
  var totalPrice = 0.0.obs; //  Make totalPrice observable
  TextEditingController totalPriceController = TextEditingController();

  void updateTotalPrice() {
    double ratePerLtr = double.tryParse(ratePerLtrController.text) ?? 0.0;
    double fuelAmount = double.tryParse(dieselAmountController.text) ?? 0.0;

    totalPrice.value = ratePerLtr * fuelAmount; //  Observable update
    totalPriceController.text = totalPrice.value.toStringAsFixed(2);

    update();// Sync with controller
  }

  var latestEntry = Rxn<Map<String, String>>();
  var vehicleNo = RxnString();
  var driverName = RxnString();
  var fuelType = RxnString();
  var ratePerLtr = RxString("");
  var pumpData = <Map<String, dynamic>>[].obs;
  RxList<String> vehicleID = <String>[].obs;
  RxList<String> fuelTypes = <String>[].obs;
  RxList<String> pumpNames = <String>[].obs;
  RxnString selectedVehicle = RxnString();
  RxnString selectedFuelType = RxnString();
  RxnString selectedPumpName = RxnString();
  var fuelEntries = <Map<String, dynamic>>[].obs; // Store fuel entries
  var isLoading = false.obs;

  var selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).obs;
  void pickDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day); // Removes time
  }
  Rx<DateTime> entryListDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).obs;

  void pickDateForEntryList(DateTime date) {
    entryListDate.value = DateTime(date.year, date.month, date.day); // Removes time
  }

  RxString selectedVehicleNumbers = "Not Found".obs;
  RxString selectedDriverName = "Not Found".obs;
  RxString selectedRatePerLtr = "Not Found".obs;
  RxList<Map<String, dynamic>> vehicleData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> fuelData = <Map<String, dynamic>>[].obs;



  @override
  void onInit() {
    super.onInit();
    fetchVehicleNumbers();
  fetchFuelType();
  fetchPumpNames();
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

  ///fetch fuel type
  Future<void> fetchFuelType() async {
    String apiUrl = "${baseUrl}/dropdown_list?xtype=Fuel_Type";
    print("Fetching fuel type from: $apiUrl");


    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Check API Response

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print("Decoded JSON: $data"); // Ensure data is properly decoded

          if (data.containsKey('results') && data['results'] is List) {
            fuelData.assignAll(List<Map<String, dynamic>>.from(data['results']));
            fuelTypes.assignAll(fuelData.map((item) => item['xcode'].toString()).toList());
            if (fuelTypes.isNotEmpty) {
              selectedFuelType.value = fuelTypes[1]; // Set default fuel type

              // Now call onFuelTypeSelected to initialize ratePerLtr properly
              onFuelTypeSelected(selectedFuelType.value!);
            }
            print("Fetched Fuel Types: $fuelTypes"); // Check list before UI updates
          } else {
            print("Unexpected API Response Format: 'results' key not found or not a List");
          }
        } catch (jsonError) {
          print("Error decoding JSON: $jsonError");
        }
      } else {
        print("Failed to fetch fuel type: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching fuel type: $e");
    }
  }

  ///fetch pump name
  Future<void> fetchPumpNames() async {
    String apiUrl = "${baseUrl}/dropdown_list?xtype=Pump_Name";
    print("Fetching pump names from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Check API Response

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print("Decoded JSON: $data"); // Ensure data is properly decoded

          if (data.containsKey('results') && data['results'] is List) {
            pumpData.assignAll(List<Map<String, dynamic>>.from(data['results']));
            pumpNames.assignAll(pumpData.map((item) => item['xcode'].toString()).toList());

            print("Fetched Pump Names: $pumpNames"); // Check list before UI updates
          } else {
            print("Unexpected API Response Format: 'results' key not found or not a List");
          }
        } catch (jsonError) {
          print("Error decoding JSON: $jsonError");
        }
      } else {
        print("Failed to fetch pump names: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching pump names: $e");
    }
  }


  Future<void> fetchFuelEntries() async {
    String zemail = userController.user.value?.username ?? "";
    String xdate = "${DateFormat('yyyy-MM-dd').format(entryListDate.value)}T00:00:00"; // Include T00:00:00

    String apiUrl = "${baseUrl}/vmfuelentry_list?zemail=$zemail&xdate=$xdate";
    print("Fetching fuel entries for date: ${entryListDate.value}");
    print("API URL: $apiUrl");

    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        final data = json.decode(response.body);
        if (data.containsKey('results') && data['results'] is List) {
          fuelEntries.assignAll(List<Map<String, dynamic>>.from(data['results']));
        } else {
          fuelEntries.clear();
        }
      } else {
        fuelEntries.clear();
      }
    } catch (e) {
      fuelEntries.clear();
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

  void onFuelTypeSelected(String selectedFuelType) async {
    var selectedFuelData = fuelData.firstWhere(
          (item) => item['xcode'] == selectedFuelType,
      orElse: () => <String, dynamic>{},
    );
    print("My select: $selectedFuelData");
    if (selectedFuelData.isNotEmpty) {
      fuelType.value = selectedFuelType;
      selectedRatePerLtr.value = (selectedFuelData["xrate"] as String?) ?? "Not Available";
      ratePerLtr.value = selectedRatePerLtr.value; // Update ratePerLtr here
    } else {
      selectedRatePerLtr.value = "Not Found";
      ratePerLtr.value = "Not Found"; // Ensure ratePerLtr is also updated
    }
    dieselAmountController.clear();

    // Reset total price as well
    totalPrice.value = 0.0;
    totalPriceController.text = "0.00";
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
  void selectEntryListDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      entryListDate.value = picked;
    }
  }

  Future<void> addEntry() async {
    if (selectedVehicle.value == null ||
        selectedDate.value == null ||
        fuelType.value==null ||
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

    // Parse the totalPrice from the totalPriceController.text
    double? totalPriceValue = double.tryParse(totalPriceController.text);
    if (totalPriceValue == null) {
      totalPriceValue = 0.0; // Default to 0 if parsing fails
    }

    // Prepare request body according to API format
    Map<String, dynamic> requestBody = {
      "zid": 100010, // Static or dynamic based on your requirements
      "xdate": selectedDate.value.toIso8601String(),// Adjusted format
      "xvehicle": selectedVehicle.value,
      "xvmregno": selectedVehicleNumbers.value,
      "xdriver": selectedDriverName.value,
      "xtype": fuelType.value,
      "xrate": ratePerLtr.value,
      "xqtyord": dieselAmount,
      "xamount": totalPriceValue,
      "xunit": "Ltr", // Assuming diesel is measured in liters
      "xwh": pumpNameController.text, // Modify if needed
      "zemail": userController.user.value?.username ,// Modify if needed
    };

    String apiUrl = "${baseUrl}/vmfuelentry/new";

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

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Fuel entry added successfully",
          snackPosition: SnackPosition.TOP,
          colorText: AppColor.white,
          backgroundColor: AppColor.seaGreen,
        );
        await fetchFuelEntries();

        // Clear inputs after successful submission
        selectedVehicle.value = null;
        selectedVehicleNumbers.value = "Not Found";
        selectedDriverName.value = "Not Found";
        selectedFuelType.value = null;
        selectedPumpName.value = null;  // This clears the observable
        ratePerLtrController.clear();
        dieselAmountController.clear();
        totalPrice.value = 0; // Reset observable
        totalPriceController.text = "0"; // Ensure the controller is cleared
        pumpNameController.clear();  // This clears the TextEditingController


        update();
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
