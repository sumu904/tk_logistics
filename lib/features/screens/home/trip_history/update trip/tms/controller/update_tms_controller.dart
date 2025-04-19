import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../../../const/const_values.dart';
import '../../../../../../../util/app_color.dart';
import '../../../../../../auth/login/controller/user_controller.dart';


class UpdateTmsController extends GetxController {
  final userController = Get.find<UserController>();
  RxList<String> locations = <String>[].obs;
  RxList<String> billingUnits = <String>[].obs;
  RxList<String> cargoTypes = <String>[].obs;
  RxList<String> tripTypes = <String>[].obs;
  //RxList<String> segments = <String>[].obs;

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
  //Rx<DateTime?> date = Rx<DateTime?>(null);
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  void pickDate(DateTime date) {
    selectedDate.value = date;
  }

  var selectedVehicleNumbers = "".obs;
  var selectedDriverName = "".obs;
  var selectedDriverMobile = "".obs;
  RxBool isLoading = false.obs;
  RxList<dynamic> tripDetails = <dynamic>[].obs;

  late Map<String, dynamic> trip;

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

    // Fetch necessary dropdowns
    fetchLocations();
    fetchVehicleNumbers();
    fetchBillingUnits();
    fetchCargoType();
    fetchTypeofTrip();
   // fetchSegment();


    loadingPointController.text = "1"; // Set default value

    ever(selectedDriverName, (_) {
      driverNameController.text = selectedDriverName.value;
    });

    ever(selectedDriverMobile, (_) {
      driverPhoneController.text = selectedDriverMobile.value;
    });

    // Get arguments
    final args = Get.arguments;
    if (args != null) {
      if (args.containsKey("trip")) {
        trip = args["trip"];
      } else {
        trip = {}; // Handle empty case
      }

      // Fetch trip details if tripNo is provided
      if (args.containsKey("tripNo")) {
        String tripNo = args["tripNo"];
        if (tripNo.isNotEmpty) {
          fetchTripDetails(tripNo); // ✅ Call fetchTripDetails
        }
      }
    }
  }

  Future<void> fetchTripDetails(String tripNo) async {
    final String apiUrl = "${baseUrl}/Trip_list?xsornum=$tripNo";
    print(apiUrl);

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Decoded JSON: $data");

        if (data.containsKey('results') && data['results'] is List && data['results'].isNotEmpty) {
          var tripData = data['results'][0];

          // Populate fields with fetched values
          from.value = tripData['xsdestin'] ?? '';
          to.value = tripData['xdestin'] ?? '';
          loadingPointController.text = (tripData['xlpoint'] ?? '').toString();
          unloadingPointController.text = (tripData['xulpoint'] ?? '').toString();
          selectedVehicle.value = tripData['xvehicle'] ?? '';
          selectedVehicleNumbers.value = tripData['xvmregno'] ?? '';
          selectedDriverName.value = tripData['xdriver'] ?? '';
          selectedDriverMobile.value = tripData['xmobile'] ?? '';
          billingUnit.value = tripData['xproj'] ?? '';
          cargoWeightController.text = tripData['xinweight'] ?? '';
          cargoType.value = (tripData['xtypecat'] != null && tripData['xtypecat'] != '')
              ? List<String>.from([tripData['xtypecat']])  // Convert string to a list with one item
              : [];
          distanceController.text = tripData['trkm'] ?? '';
          serviceChargeController.text = tripData['xprime'] ?? '';
          tripType.value = tripData['xmovetype'] ?? '';
          //segment.value = tripData['xsagnum'] ?? '';
          noteController.text = tripData['xrem'] ?? '';

          // Handle DateTime safely
          selectedDate.value = tripData['xdate'] != null ? DateTime.parse(tripData['xdate']) : DateTime.now();
          pickupDate.value = tripData['xouttime'] != null ? DateTime.parse(tripData['xouttime']) : null;
          dropOffDate.value = tripData['xchallantime'] != null ? DateTime.parse(tripData['xchallantime']) : null;

          print("Fetched From: ${from.value}, To: ${to.value}, Pickup Date: $pickupDate, Dropoff Date: $dropOffDate");

          update(); // Refresh UI
        } else {
          print("Error: 'results' is empty or missing.");
        }
      } else {
        print("Failed to fetch trip history: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
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
            picked.year, picked.month, picked.day, time.hour, time.minute);
      }
    }
  }


  /// Fetch locations from API and extract `xcode`
  Future<void> fetchLocations() async {
    String apiUrl = "${baseUrl}/dropdown_list?xtype=Load_Unload_Point";
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
            //from.value = locations.first;
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

  // Track the last selected vehicle to maintain persistence
  String? lastSelectedVehicle;
  String? lastSelectedVehicleNumbers;
  String? lastSelectedDriverName;
  String? lastSelectedDriverMobile;

  void onVehicleSelected(String selectedVehicle) {
    var emptyValue = "Not available";

    // Update last selected vehicle
    lastSelectedVehicle = selectedVehicle;

    // Find vehicle data
    var selectedVehicleData = vehicleData.firstWhere(
          (item) => item['xvehicle'] == selectedVehicle,
      orElse: () => <String, dynamic>{},
    );

    print("Selected Vehicle Data: $selectedVehicleData"); // Debugging

    if (selectedVehicleData.isNotEmpty) {
      selectedVehicleNumbers.value = selectedVehicleData["xvmregno"]?.toString() ?? emptyValue;
      selectedDriverName.value = selectedVehicleData["xname"]?.toString() ?? emptyValue;
      selectedDriverMobile.value = selectedVehicleData["xmobile"]?.toString() ?? emptyValue;
    } else {
      selectedVehicleNumbers.value = emptyValue;
      selectedDriverName.value = emptyValue;
      selectedDriverMobile.value = emptyValue;
      print("Selected Vehicle Data not found");
    }

    // Save selected values
    lastSelectedVehicleNumbers = selectedVehicleNumbers.value;
    lastSelectedDriverName = selectedDriverName.value;
    lastSelectedDriverMobile = selectedDriverMobile.value;

    // **Ensure controller updates after assigning values**
    Future.delayed(Duration(milliseconds: 50), () {
      vehicleNumberController.text = lastSelectedVehicleNumbers ?? "";
      driverNameController.text = lastSelectedDriverName ?? "";
      driverPhoneController.text = lastSelectedDriverMobile ?? "";

      print("Updated Controllers: Vehicle: ${vehicleNumberController.text}, Driver: ${driverNameController.text}, Phone: ${driverPhoneController.text}");
    });

    update(); // If using GetX
  }

  /// Fetch cargo type list from API
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
      "xulpoint": unloadingPointController.text,
      "xvehicle": selectedVehicle.value,
      "xvmregno": selectedVehicleNumbers.value,
      "xname": selectedDriverName.value,
      "xmobile": selectedDriverMobile.value,
      "xproj": billingUnit.value,
      "xdate": selectedDate.value,
      "xinweight":cargoWeightController.text,
      "xtypecat": cargoType.isNotEmpty ? cargoType.join(", ") : "",
      "xglref": "GL-56789",
      "trkm": distanceController.text,
      "xprime": serviceChargeController.text,
      "xouttime": pickupDate.value?.toIso8601String(),
      "xchallantime": dropOffDate.value?.toIso8601String(),
      "xmovetype": tripType.value,
      //"xsagnum": segment.value,
      "xsornum": "", // This is usually auto-generated by backend
      "xsup":"",
      "xrem": noteController.text,
      "xstatusmove": "Pending",// Example status
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
            snackPosition: SnackPosition.TOP, backgroundColor: AppColor.seaGreen);
      } else {
        print("Failed to create trip: ${response.statusCode}, Response: ${response.body}");
        Get.snackbar("Error", "Failed to create trip",
            snackPosition: SnackPosition.TOP, backgroundColor: AppColor.primaryRed);
      }
    } catch (e) {
      print("Error creating trip: $e");
      Get.snackbar("Error", "Something went wrong",
          snackPosition: SnackPosition.TOP, backgroundColor: AppColor.primaryRed);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTrip(String tripId) async {
    isLoading.value = true;

    // Format DateTime fields correctly
    String formattedDate = selectedDate.value != null ? selectedDate.value!.toIso8601String() : "";
    String? formattedOutTime = pickupDate.value?.toIso8601String();
    String? formattedChallanTime = dropOffDate.value?.toIso8601String();

    Map<String, dynamic> updatedData = {
      "zid" : "100010",
      "xsdestin": from.value?.trim() ?? "",
      "xdestin": to.value?.trim() ?? "",
      "xlpoint": loadingPointController.text.trim(),
      "xulpoint": unloadingPointController.text.trim(),
      "xproj": billingUnit.value?.trim() ?? "",
      "xtypecat": cargoType.isNotEmpty ? cargoType.join(", ") : "",
      "xmovetype": tripType.value?.trim() ?? "",
      //"xsagnum": segment.value?.trim() ?? "",
      "xvehicle": selectedVehicle.value ?? "",
      "xvmregno": selectedVehicleNumbers.value ?? "",
      "xdriver": selectedDriverName.value ?? "",
      "xmobile": selectedDriverMobile.value ?? "",
      "xinweight": double.tryParse(cargoWeightController.text)?.toStringAsFixed(2),
      "xprime": double.tryParse(serviceChargeController.text)?.toStringAsFixed(2),
      "xouttime": formattedOutTime ?? null,  // ✅ Converted DateTime to String
      "xchallantime": formattedChallanTime ?? null, // ✅ Converted DateTime to String
      "trkm": double.tryParse(distanceController.text)?.toStringAsFixed(2),
      "xrem": noteController.text.trim(),
      "xglref": "Auto Generated",
      "xdate": formattedDate,
    };

    print("Updated Trip Data: ${jsonEncode(updatedData)}");

    try {
      final response = await http.put(
        Uri.parse("${baseUrl}/trip/update/$tripId/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Trip updated successfully!");
        print("${baseUrl}/trip/update/$tripId/");
        print(updatedData);
        Get.snackbar("Success", "Trip Updated Successfully",
            snackPosition: SnackPosition.TOP, backgroundColor: AppColor.seaGreen,colorText: AppColor.white);
      } else {
        print("Failed to update trip: ${response.statusCode}, Response: ${response.body}");
        Get.snackbar("Error", "Failed to update trip",
            snackPosition: SnackPosition.TOP, backgroundColor: AppColor.primaryRed,colorText: AppColor.white);
      }
    } catch (e) {
      print("Error updating trip: $e");
      Get.snackbar("Error", "Something went wrong: $e",
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
    podController.dispose();
    pickSupplierController.dispose();
    distanceController.dispose();
    noteController.dispose();
    currentDateController.dispose();
    loadingPointController.dispose();
    unloadingPointController.dispose();
    super.onClose();
  }
}