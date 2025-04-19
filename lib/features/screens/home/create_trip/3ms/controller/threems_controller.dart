import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../const/const_values.dart';
import '../../../../../../util/app_color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../auth/login/controller/user_controller.dart';

class ThreemsController extends GetxController {
  final userController = Get.find<UserController>();
  // Dropdown Selections
  RxList<String> locations = <String>[].obs;
  RxList<String> billingUnits = <String>[].obs;
  RxList<String> cargoTypes = <String>[].obs;
  RxList<String> segments = <String>[].obs;
  RxList<String> pickSuppliers = <String>[].obs;

  var from = RxnString();
  var to = RxnString();
  var billingUnit = RxnString();
  var pickSupplier = RxnString();
  RxList<String> cargoType = <String>[].obs;
  var tripType = RxnString();
  var segment = RxnString();
  var deliveryStatus = RxnString();
  var isTripCreated = false.obs;
  RxBool isLoading = false.obs;
  var selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).obs;
  void pickDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day); // Removes time
  }

  Rx<DateTime?> pickupDate = Rx<DateTime?>(null);
  Rx<DateTime?> dropOffDate = Rx<DateTime?>(null);

  // Text Controllers
  TextEditingController loadingPointController = TextEditingController();
  TextEditingController unloadingPointController = TextEditingController();
  TextEditingController currentDateController = TextEditingController();
  //TextEditingController vehicleIDController = TextEditingController();
  TextEditingController vehicleNoController = TextEditingController();
  TextEditingController driverNameController = TextEditingController();
  TextEditingController driverPhoneController = TextEditingController();
  TextEditingController cargoWeightController = TextEditingController();
  TextEditingController serviceChargeController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController unloadingTimeController = TextEditingController();
  TextEditingController podController = TextEditingController();
  TextEditingController pickSupplierController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchLocations();
    //fetchVehicleNumbers();
    fetchBillingUnits();
    fetchSuppliers();
    fetchCargoType();
    fetchSegment();
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

  Future<void> fetchSuppliers() async {
    String apiUrl = "${baseUrl}/dropdown_list?xtype=Supplier";
    print("Fetching locations from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Check API Response

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print("Decoded JSON: $data"); // Ensure data is properly decoded

          if (data.containsKey('results') && data['results'] is List) {
            pickSuppliers.assignAll(List<String>.from(
                data['results'].map((item) => item['xcode'].toString())));
            print("Fetched Suppliers: $pickSuppliers"); // Check list before UI updates
          } else {
            print("Unexpected API Response Format: 'results' key not found or not a List");
          }
        } catch (jsonError) {
          print("Error decoding JSON: $jsonError");
        }
      } else {
        print("Failed to fetch suppliers: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching suppliers: $e");
    }
  }

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

  Future<void> fetchSegment() async {
    String apiUrl = "${baseUrl}/dropdown_list?xtype=Segment";
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
  }

  // Function to handle form submission
  Future<void> createTrip() async {
    isLoading.value = true;

    Map<String, dynamic> tripData = {
      "xtype": "3MS",
      "zid": "100010",
      "zemail": userController.user.value?.username,
      "xsdestin": from.value,
      "xdestin": to.value,
      "xlpoint": loadingPointController.text,
      "xulpoint":unloadingPointController.text,
      "xsup": pickSupplier.value,
      "xvehicle": vehicleNoController.text,
      "xdriver": driverNameController.text,
      "xmobile": driverPhoneController.text,
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
      "xsagnum": segment.value,
      "xsornum": "", // This is usually auto-generated by backend
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