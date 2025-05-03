import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../../../../../../const/const_values.dart';
import '../../../../../../../util/app_color.dart';
import '../../../../../../auth/login/controller/user_controller.dart';


class Update3msController extends GetxController {
  final userController = Get.find<UserController>();
  RxString tripId = ''.obs;
  RxString tripPoD = ''.obs;
  // Dropdown Selections
  RxList<String> locations = <String>[].obs;
  RxList<String> billingUnits = <String>[].obs;
  RxList<String> cargoTypes = <String>[].obs;
  RxList<String> segments = <String>[].obs;
  RxList<String> pickSuppliers = <String>[].obs;
  var isDataLoading = false.obs;

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
  late Map<String, dynamic> trip;
  //RxnString selectedVehicle = RxnString();
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  void pickDate(DateTime date) {
    selectedDate.value = date;
  }
  Rx<DateTime?> pickupDate = Rx<DateTime?>(null);
  Rx<DateTime?> dropOffDate = Rx<DateTime?>(null);

  // Text Controllers
  TextEditingController loadingPointController = TextEditingController();
  TextEditingController unloadingPointController = TextEditingController();
  TextEditingController vehicleIDController = TextEditingController();
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
    loadingPointController.text = "1";
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
          fetchTripDetails(tripNo); //  Call fetchTripDetails
        }
      }
    }
  }

  Future<void> fetchTripDetails(String tripNo) async {
    final String apiUrl = "${baseUrl}/Trip_list?xsornum=$tripNo";
    print(apiUrl);

    try {
      final response = await http.get(Uri.parse(apiUrl)); // Send GET request

      if (response.statusCode == 200) {
        try {
          final response = await http.get(Uri.parse(apiUrl)); // Send GET request

          print("Response Status Code: ${response.statusCode}");
          print("Response Body: ${response.body}"); // Debug full response

          if (response.statusCode == 200) {
            try {
              final data = json.decode(response.body);
              print("Decoded JSON: $data");

              // Debugging: Print the type of `results`
              if (data.containsKey('results')) {
                print("Type of 'results': ${data['results'].runtimeType}"); // Check type

                if (data['results'] is List && data['results'].isNotEmpty) {
                  var tripData = data['results'][0];

                  // Safely extract values
                  from.value = tripData['xsdestin'] ?? '';
                  to.value = tripData['xdestin'] ?? '';
                  loadingPointController.text = (tripData['xlpoint'] ?? '').toString();
                  unloadingPointController.text = (tripData['xulpoint'] ?? '').toString();
                  pickSupplier.value = tripData['xsup'] ?? '';
                  vehicleIDController.text = '${tripData['xvehicle'] ?? ''} ${tripData['xvmregno'] ?? ''}';
                  driverNameController.text = tripData['xdriver'] ?? '';
                  driverPhoneController.text = tripData['xmobile'] ?? '';
                  billingUnit.value = tripData['xproj'] ?? '';
                  selectedDate.value = tripData['xdate'] != null
                      ? DateTime.parse(tripData['xdate']) // Parse the string to DateTime
                      : null;
                  cargoWeightController.text = tripData['xinweight'] ?? '';
                  cargoType.value = (tripData['xtypecat'] != null && tripData['xtypecat'] != '')
                      ? List<String>.from([tripData['xtypecat']])  // Convert string to a list with one item
                      : [];
                  distanceController.text = tripData['trkm'] ?? '';
                  serviceChargeController.text = tripData['xprime'] ?? '';
                  pickupDate.value = tripData['xouttime'] != null
                      ? DateTime.parse(tripData['xouttime']) // Parse the string to DateTime
                      : null;
                  dropOffDate.value = tripData['xchallantime'] != null
                      ? DateTime.parse(tripData['xchallantime']) // Parse the string to DateTime
                      : null;
                  tripType.value = tripData['xmovetype'] ?? '';
                  segment.value = tripData['xsagnum'] ?? '';
                  noteController.text = tripData['xrem'] ?? '';

                  tripId.value = tripData['xsornum'] ?? '';
                  tripPoD.value = tripData['xlink'] ?? '';

                  print("Fetched Trip ID: ${tripId.value}");
                  print("Fetched Trip PoD: ${tripPoD.value}");;

                  print("Fetched From: ${from.value}, To: ${to.value}");
                  update(); // Refresh UI
                } else {
                  print("Error: 'results' is not a List or is empty.");
                }
              } else {
                print("Error: 'results' key not found in API response.");
              }
            } catch (jsonError) {
              print("Error decoding JSON: $jsonError");
            }
          } else {
            print("Failed to fetch trip history: ${response.statusCode}");
          }
        } catch (e) {
          print("Error: $e");
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
      "xulpoint": unloadingPointController.text,
      "xsup": pickSupplier.value,
      "xvehicle": vehicleIDController.text,
      "xvmregno": vehicleIDController.text,
      "xname": driverNameController.text,
      "xmobile": driverPhoneController.text,
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
            snackPosition: SnackPosition.TOP, backgroundColor: AppColor.seaGreen);
      } else {
        print("Failed to create trip: ${response.statusCode}, Response: ${response.body}");
        Get.snackbar("Error", "Failed to create trip",
            snackPosition: SnackPosition.TOP, backgroundColor: AppColor.primaryRed);
      }
    } catch (e) {
      print("Error creating trip: $e");
      Get.snackbar("Error", "Something went wrong",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red);
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
      "xsagnum": segment.value?.trim() ?? "",
      "xvehicle": vehicleIDController.text.trim(),
      "xvmregno": vehicleIDController.text.trim(),
      "xdriver": driverNameController.text.trim(),
      "xmobile": driverPhoneController.text.trim(),
      "xinweight": double.tryParse(cargoWeightController.text)?.toStringAsFixed(2),
      "xprime": double.tryParse(serviceChargeController.text)?.toStringAsFixed(2),
      "xouttime": formattedOutTime ?? null,
      "xchallantime": formattedChallanTime ?? null,
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
}