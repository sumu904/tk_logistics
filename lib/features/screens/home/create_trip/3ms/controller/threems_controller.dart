import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../util/app_color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ThreemsController extends GetxController {
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
  var cargoType = RxnString();
  var tripType = RxnString();
  var segment = RxnString();
  var deliveryStatus = RxnString();
  var isTripCreated = false.obs;
  RxnString selectedVehicle = RxnString();
  Rx<DateTime?> pickupDate = Rx<DateTime?>(null);
  Rx<DateTime?> dropOffDate = Rx<DateTime?>(null);

  RxString selectedVehicleNumbers = "Not Found".obs;
  RxString selectedDriverID = "Not Found".obs;
  RxString selectedDriverMobile = "Not Found".obs;
  RxList<String> vehicleID = <String>[].obs;
  RxList<Map<String, dynamic>> vehicleData = <Map<String, dynamic>>[].obs;

  // Text Controllers
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
    fetchVehicleNumbers();
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
            picked.year, picked.month, picked.day, time.hour, time.minute);
      }
    }
  }

  Future<void> fetchLocations() async {
    String apiUrl = "http://103.250.68.75/api/v1/dropdown_list?xtype=Load_Unload_Point";
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
            locations.assignAll(List<String>.from(
                data['results'].map((item) => item['xcode'].toString())));
            print("Fetched Locations: $locations"); // Check list before UI updates
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

  Future<void> fetchVehicleNumbers() async {
    String apiUrl = "http://103.250.68.75/api/v1/vehicle_list";
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

  void onVehicleSelected(String selectedVehicle) {
    print("Vehicle Selected: $selectedVehicle");

    // Find the selected vehicle data from the vehicleData list
    var selectedVehicleData = vehicleData.firstWhere(
          (item) => item['xvehicle'] == selectedVehicle,
      orElse: () => <String, dynamic>{}, // ✅ Ensures an empty Map<String, dynamic> is returned
    );

    if (selectedVehicleData.isNotEmpty) {
      // ✅ Use safe type casting to ensure values are Strings
      selectedVehicleNumbers.value = (selectedVehicleData["xvmregno"] as String?) ?? "Not Available";
      selectedDriverID.value = (selectedVehicleData["xdriver"] as String?) ?? "Not Available";
      selectedDriverMobile.value = (selectedVehicleData['xmobile'] as String?) ?? "Not Available";

      print("Driver Data Updated:  ${selectedVehicleNumbers.value} - ${selectedDriverID.value} - ${selectedDriverMobile.value}");
    } else {
      selectedVehicleNumbers.value = "Not Found";
      selectedDriverID.value = "Not Found";
      selectedDriverMobile.value = "Not Found";
    }

    update(); // Notify listeners
  }

  /// Fetch billing unit list from API

  Future<void> fetchBillingUnits() async {
    String apiUrl = "http://103.250.68.75/api/v1/dropdown_list?xtype=Billing_Unit";
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
    String apiUrl = "http://103.250.68.75/api/v1/dropdown_list?xtype=Supplier";
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
    String apiUrl = "http://103.250.68.75/api/v1/dropdown_list?xtype=Cargo_Type";
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
  }


  final currentDate = DateTime.now().toString().split(" ")[0].obs;
  final challan = "Auto-generated".obs;

  // Function to handle form submission
  Future<void> createTrip() async {
    if (from.value == null || to.value == null) {
      print("Please select both From and To locations.");
      return;
    }else{
      bool success = true; // This should be replaced with actual API response or logic

      isTripCreated.value = success;
      Get.snackbar(
        success ? "Success" : "Error",
        success ? "Trip Created Successfully" : "Failed to Create Trip",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: success ? AppColor.seaGreen : Colors.red,
      );
    }

    Map<String, dynamic> tripData = {
      "from": from.value,
      "to": to.value,
      "billing_unit": billingUnit.value,
      "cargo_type": cargoType.value,
      "trip_type": tripType.value,
      "segment": segment.value,
      "cargo_weight": cargoWeightController.text,
      "service_charge": serviceChargeController.text,
      "start_time": startTimeController.text,
      "unloading_time": unloadingTimeController.text,
      "pod": podController.text,
      "pick_supplier": pickSupplierController.text,
      "distance": distanceController.text,
      "note": noteController.text,
      /* "driver": driver.value,
      "driver_phone": driverPhone.value,*/
      "challan": challan.value,
      "date": currentDate.value,
    };

    print("Submitting Trip Data: $tripData");

    try {
      final response = await http.post(
        Uri.parse("http://103.250.68.75/api/v1/create_trip"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(tripData),
      );

      if (response.statusCode == 201) {
        print("Trip created successfully!");
      } else {
        print("Failed to create trip: ${response.statusCode}");
      }
    } catch (e) {
      print("Error creating trip: $e");
    }
  }
}