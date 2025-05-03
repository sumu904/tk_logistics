import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../../const/const_values.dart';
import '../../../../../../util/app_color.dart';
import '../../../../../auth/login/controller/user_controller.dart';

class TmsController extends GetxController {
  final userController = Get.find<UserController>();
  RxInt currentPage = 1.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMoreData = true.obs;
  RxList<String> locations = <String>[].obs;
  RxList<String> billingUnits = <String>[].obs;
  RxList<String> cargoTypes = <String>[].obs;
  RxList<String> tripTypes = <String>[].obs;
 // RxList<String> segments = <String>[].obs;

  var from = RxnString();
  var to = RxnString();
  var billingUnit = RxnString();
  RxList<String> cargoType = <String>[].obs;
  var tripType = RxnString();
  //var segment = RxnString();
  RxnString selectedVehicle = RxnString();
  var vehicleNo = RxnString();
  var isTripCreated = false.obs;
  Rx<DateTime?> pickupDate = Rx<DateTime?>(null);
  Rx<DateTime?> dropOffDate = Rx<DateTime?>(null);
  var selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).obs;
  void pickDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
  }

  var selectedVehicleNumbers = "".obs;
  var selectedDriverName = "".obs;
  var selectedDriverMobile = "".obs;
  RxBool isLoading = false.obs;

  var challanText = RxString("");
  RxList<String> vehicleID = <String>[].obs;
  RxList<Map<String, dynamic>> vehicleData = <Map<String, dynamic>>[].obs;  // RxString for reactive updates

  final TextEditingController loadingPointController = TextEditingController();
  final TextEditingController unloadingPointController = TextEditingController();
  final TextEditingController currentDateController = TextEditingController();
  final TextEditingController cargoWeightController = TextEditingController();
  final TextEditingController serviceChargeController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController unloadingTimeController = TextEditingController();
  final TextEditingController podController = TextEditingController();
  final TextEditingController pickSupplierController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverPhoneController = TextEditingController();


  @override
  void onInit() {
    super.onInit();
    fetchLocations();
    fetchVehicleNumbers();
    fetchBillingUnits();
    fetchCargoType();
    fetchTypeofTrip();
    //fetchSegment();
   /* if (challanText.value.isEmpty) {
      challanText.value = "Auto Generated";
    }// Set initial date*/
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

  /// Fetch locations from API and extract `xcode`
  Future<void> fetchLocations({int page = 1}) async {
    String apiUrl = "${baseUrl}/dropdown_list?page=$page&xtype=Load_Unload_Point";
    print("Fetching locations from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print("Decoded JSON: $data");

          if (data.containsKey('results') && data['results'] is List) {
            // Use a Set to prevent duplicate values
            Set<String> uniqueLocations = locations.toSet();

            // Add new items, preventing duplicates
            for (var item in data['results']) {
              String xcode = item['xcode'].toString();
              uniqueLocations.add(xcode); // Set will automatically ignore duplicates
            }

            locations.assignAll(uniqueLocations.toList()); // Convert back to List

            from.value = (userController.user.value?.zone?.isNotEmpty ?? false)
                ? userController.user.value?.zone
                : locations.first;

            print("Fetched Locations: $locations");
            print("Number of Locations Fetched: ${locations.length}");

            // Check if there's a next page before making another request
            if (data.containsKey('next') && data['next'] != null) {
              print("Fetching next page...");
              fetchLocations(page: page + 1);
            } else {
              print("No more pages to fetch.");
            }
          } else {
            print("Unexpected API Response Format: 'results' key not found or not a List");
          }
        } catch (jsonError) {
          print("Error decoding JSON: $jsonError");
        }
      } else {
        print("Failed to fetch locations: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching locations: $e");
    }
  }

  /// Fetch billing unit list from API
  Future<void> fetchBillingUnits() async {
    String apiUrl = "${baseUrl}/dropdown_list?xtype=Billing_Unit";
    print("Fetching billing unit from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Check API Response

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print("Decoded JSON: $data"); // Ensure data is properly decoded

          if (data.containsKey('results') && data['results'] is List) {
            billingUnits.assignAll(List<String>.from(
                data['results'].map((item) => item['xcode'].toString())));
            print("Fetched Billing Units: $billingUnits"); // Check list before UI updates
          } else {
            print("Unexpected API Response Format: 'results' key not found or not a List");
          }
        } catch (jsonError) {
          print("Error decoding JSON: $jsonError");
        }
      } else {
        print("Failed to fetch billing unit: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching billing unit: $e");
    }
  }

  /// Fetch vehicle number list from API
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

  // Track the last selected vehicle to maintain persistence
  String? lastSelectedVehicle;
  String? lastSelectedVehicleNumbers;
  String? lastSelectedDriverName;
  String? lastSelectedDriverMobile;

  void onVehicleSelected(String selectedVehicle) {
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
    update();
  }

///  Fetch cargo type list from API
  Future<void> fetchCargoType() async {
    String apiUrl = "${baseUrl}/dropdown_list?xtype=Cargo_Type";
    print("Fetching cargo type from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Check API Response

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print("Decoded JSON: $data"); // Ensure data is properly decoded

          if (data.containsKey('results') && data['results'] is List) {
            cargoTypes.assignAll(List<String>.from(
                data['results'].map((item) => item['xcode'].toString())));
            print("Fetched Cargo Type: $cargoTypes"); // Check list before UI updates
          } else {
            print("Unexpected API Response Format: 'results' key not found or not a List");
          }
        } catch (jsonError) {
          print("Error decoding JSON: $jsonError");
        }
      } else {
        print("Failed to fetch cargo type: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching cargo type: $e");
    }
  }

  ///  Fetch cargo type list from API
  Future<void> fetchTypeofTrip() async {
    String apiUrl = "${baseUrl}/dropdown_list?xtype=Trip_Type";
    print("Fetching cargo type from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Check API Response

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print("Decoded JSON: $data"); // Ensure data is properly decoded

          if (data.containsKey('results') && data['results'] is List) {
            tripTypes.assignAll(List<String>.from(
                data['results'].map((item) => item['xcode'].toString())));
            print("Fetched Trip Type: $tripTypes"); // Check list before UI updates
          } else {
            print("Unexpected API Response Format: 'results' key not found or not a List");
          }
        } catch (jsonError) {
          print("Error decoding JSON: $jsonError");
        }
      } else {
        print("Failed to fetch trip type: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching trip type: $e");
    }
  }

  ///  Fetch cargo type list from API

/*  Future<void> fetchSegment() async {
    String apiUrl = "http://103.250.68.75/api/v1/dropdown_list?xtype=Segment";
    print("Fetching segment from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Check API Response

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print("Decoded JSON: $data"); // Ensure data is properly decoded

          if (data.containsKey('results') && data['results'] is List) {
            segments.assignAll(List<String>.from(
                data['results'].map((item) => item['xcode'].toString())));
            print("Fetched Trip Type: $segments"); // Check list before UI updates
          } else {
            print("Unexpected API Response Format: 'results' key not found or not a List");
          }
        } catch (jsonError) {
          print("Error decoding JSON: $jsonError");
        }
      } else {
        print("Failed to fetch segment: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching segment: $e");
    }
  }*/

  /// Handle form submission
  Future<void> createTrip() async {
    isLoading.value = true;

    Map<String, dynamic> tripData = {
    "xtype": "TMS",
    "zid": "100010",
    "zemail": userController.user.value?.username,
    "xsdestin": from.value,
    "xdestin": to.value,
    "xlpoint": loadingPointController.text,
    "xulpoint":unloadingPointController.text,
    "xvehicle": selectedVehicle.value,
    "xvmregno": selectedVehicleNumbers.value,
    "xdriver": selectedDriverName.value,
    "xmobile": selectedDriverMobile.value,
    "xproj": billingUnit.value,
    "xdate": selectedDate.value.toIso8601String(),
    "xinweight":double.tryParse(cargoWeightController.text)?.toStringAsFixed(2),
    "xtypecat": cargoType.join(", "),
    "xglref": "GL-56789",
    "trkm": double.tryParse(distanceController.text)?.toStringAsFixed(2),
    "xprime": double.tryParse(serviceChargeController.text)?.toStringAsFixed(2),
    "xouttime": pickupDate.value?.toIso8601String(),
    "xchallantime": dropOffDate.value?.toIso8601String(),
    "xmovetype": tripType.value,
    //"xsagnum": segment.value,
    "xsornum": "", // This is usually auto-generated by backend
    "xsup":"",
    "xrem": noteController.text,
    "xstatusmove": "1-Open",// Example status
    };



    try {
      final response = await http.post(
        Uri.parse("${baseUrl}/trip/new"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(tripData),
      );
      print("Trip Data: ${jsonEncode(tripData)}");
      if (response.statusCode == 201) {
        print(" Trip created successfully!");
        Get.snackbar("Success", "Trip Created Successfully",
            snackPosition: SnackPosition.TOP, backgroundColor: AppColor.seaGreen,colorText: AppColor.white);
      } else {
        print("Failed to create trip: ${response.statusCode}, Response: ${response.body}");
        Get.snackbar("Error", "Failed to create trip",
            snackPosition: SnackPosition.TOP, backgroundColor: AppColor.primaryRed,colorText: AppColor.white);
      }
    } catch (e) {
      print("Error creating trip: $e");
      Get.snackbar("Error", "Something went wrong",
          snackPosition: SnackPosition.TOP, backgroundColor: AppColor.primaryRed,colorText: AppColor.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Dispose controllers to avoid memory leaks
  @override
  void onClose() {
    cargoWeightController.dispose();
    serviceChargeController.dispose();
    startTimeController.dispose();
    unloadingTimeController.dispose();
    pickSupplierController.dispose();
    distanceController.dispose();
    noteController.dispose();
    currentDateController.dispose();
    loadingPointController.dispose();
    unloadingPointController.dispose();
    super.onClose();
  }
}