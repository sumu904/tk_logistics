import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:tk_logistics/util/app_color.dart';
import 'dart:convert';

import '../../../../../const/const_values.dart';
import '../../../../auth/login/controller/user_controller.dart';

class EntryListController extends GetxController {
  Rx<DateTime> selectedFromDate = DateTime.now().obs;
  Rx<DateTime> selectedToDate = DateTime.now().obs;

  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  final vehicleController = TextEditingController();

  final userController = Get.find<UserController>();
  RxnString selectedVehicle = RxnString();
  RxList<String> vehicleID = <String>[].obs;
  RxList<Map<String, dynamic>> vehicleData = <Map<String, dynamic>>[].obs;
/*  Rxn<DateTime> selectedFromDate = Rxn<DateTime>();
  Rxn<DateTime> selectedToDate = Rxn<DateTime>();*/
  RxList<Map<String, dynamic>> filteredEntries = <Map<String, dynamic>>[].obs;
  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  void onInit() {
    super.onInit();
    fetchVehicleNumbers();
    fromDateController.text = formatDate(selectedFromDate.value);
    toDateController.text = formatDate(selectedToDate.value);
  }

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
            // Add the fetched data to vehicleData and vehicleID
            vehicleData.addAll(List<Map<String, dynamic>>.from(data['results']));

            // Add "All Vehicle" to the list of vehicle codes, ensuring no duplicates
            List<String> newVehicleIDs = ["All Vehicle"];
            for (var vehicle in vehicleData) {
              String vehicleNumber = vehicle['xvehicle'].toString();
              if (!newVehicleIDs.contains(vehicleNumber)) {
                newVehicleIDs.add(vehicleNumber);
              }
            }

            // Update the vehicleID list
            vehicleID.assignAll(newVehicleIDs);

            print("Fetched Vehicle Numbers (Page $page): $vehicleID");
          } else {
            print("Unexpected API Response Format for vehicle numbers");
          }

          // Check if there's a next page
          if (data['next'] != null) {
            page++; // Move to the next page
          } else {
            hasNextPage = false; // No more pages available
          }
        } else {
          print("Failed to fetch vehicle numbers: ${response.statusCode}");
          hasNextPage = false;
        }
      } catch (e) {
        print("Error fetching vehicle numbers: $e");
        hasNextPage = false;
      }
    }

    print("✅ All Vehicle Numbers Fetched (${vehicleID.length}): $vehicleID");
  }



  void filterEntries() async {
    if (selectedVehicle.value == null || selectedVehicle.value!.isEmpty) {
      Get.snackbar(
        "Warning", "Please select a vehicle.",
        snackPosition: SnackPosition.TOP,
        colorText: AppColor.white,
        backgroundColor: AppColor.primaryRed,
      );
      return;
    }

    final fromDate = selectedFromDate.value;
    final toDate = selectedToDate.value;
    final zemail = userController.user.value?.username;
    final isAllVehicle = selectedVehicle.value == "All Vehicle";

    int currentPage = 1;
    bool hasMore = true;
    List<Map<String, dynamic>> allResults = [];

    while (hasMore) {
      final apiUrl = isAllVehicle
          ? "$baseUrl/Maintenance_list?zemail=$zemail&page=$currentPage"
          : "$baseUrl/Maintenance_list?zemail=$zemail&vehicle_code=${selectedVehicle.value}&page=$currentPage";

      print("Fetching maintenance list from: $apiUrl");

      try {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data.containsKey('results') && data['results'] is List) {
            final results = List<Map<String, dynamic>>.from(data['results']);
            if (results.isEmpty) {
              hasMore = false;
            } else {
              allResults.addAll(results);
              currentPage++;
            }
          } else {
            hasMore = false;
          }
        } else {
          print("Failed with status: ${response.statusCode}");
          hasMore = false;
        }
      } catch (e) {
        print("Error fetching maintenance list: $e");
        hasMore = false;
      }
    }

    // Manual date filtering
    final filtered = allResults.where((item) {
      final dateStr = item["xdate"] ?? "";
      final itemDate = DateTime.tryParse(dateStr);
      if (itemDate == null) return false;
      return !DateTime(itemDate.year, itemDate.month, itemDate.day)
          .isBefore(DateTime(fromDate.year, fromDate.month, fromDate.day)) &&
          !DateTime(itemDate.year, itemDate.month, itemDate.day)
              .isAfter(DateTime(toDate.year, toDate.month, toDate.day));

    }).toList();

    filteredEntries.value = filtered.map((item) {
      return {
        "Date": item["xdate"] ?? "",
        "Vehicle Code": item["vehicle_code"] ?? "",
        "Vehicle Number": item["vehicle_number"] ?? "",
        "Driver Name": item["driver_name"] ?? "",
        "Workshop Type": item["workshop_type"] ?? "",
        "Workshop Name": item["workshop_name"] ?? "",
        "Total Cost": item["total_cost"] ?? "0.00",
        "Maintenance No": item["maintenance_no"] ?? "",
        "Maintenance Type": item["maintenance_type"] ?? "N/A",
        "Cost": item["cost"] ?? item["total_cost"] ?? "0.00",
      };
    }).toList();

    //clearFields();
  }

 /* void clearFields() {
    selectedVehicle.value = null;
    selectedFromDate.value = DateTime.now();
    selectedToDate.value = DateTime.now();
    fromDateController.text = formatDate(selectedFromDate.value);
    toDateController.text = formatDate(selectedToDate.value);
    vehicleController.clear();
  }*/
}
