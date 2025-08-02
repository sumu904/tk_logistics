import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tk_logistics/features/screens/home/trip_history/update%20trip/pod/screen/proof_of_delivery_screen_rental.dart';
import 'package:tk_logistics/features/screens/home/trip_history/update%20trip/rental/controller/update_rental_controller.dart';

import '../../../../../../../common/widgets/custom_button.dart';
import '../../../../../../../common/widgets/custom_indicator.dart';
import '../../../../../../../common/widgets/custom_outlined_button.dart';
import '../../../../../../../common/widgets/loading_cntroller.dart';
import '../../../../../../../routes/routes_name.dart';
import '../../../../../../../util/app_color.dart';
import '../../../../../../../util/dimensions.dart';
import '../../../../../../../util/styles.dart';
import '../../../controller/trip_history_controller.dart';


class UpdateRentalTrip extends StatelessWidget {
  final UpdateRentalController Controller = Get.put(UpdateRentalController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final loadingController = Get.find<LoadingController>();

  Future<void> fetchDataFromApi(String apiUrl) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(" API Data fetched successfully: $data");
      } else {
        print(" Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print(" Error fetching API data: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: Controller.selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      Controller.pickDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments; //  Get arguments safely

    final String tripNo = args?["tripNo"] ?? "Unknown";
    final Map<String, dynamic> tripData = args?["tripData"] ?? {};
    final String apiUrl = args?["apiUrl"] ?? "";

    if (tripNo != "Unknown") {
      Controller.fetchTripDetails(tripNo); //  Use tripNo to fetch data
    }
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColor.neviBlue,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 22,
              color: AppColor.white,
            ),
          ),
          title: Text(
            "Update RENTAL Trip Data",
            style: quicksandBold.copyWith(
                fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: GetBuilder<UpdateRentalController>(
              initState: (_) {
                Controller.fetchLocations();
                //tripController.fetchVehicleNumbers();
                Controller.fetchVehicleNumbers();
                Controller.fetchBillingUnits();
                Controller.fetchSuppliers();
                Controller.fetchCargoType();
                Controller.fetchSegment();
                if (Controller.locations.isNotEmpty) {
                  Controller.from.value = Controller.locations.first; // Set first item as default
                }//  Fetch locations when screen opens
              },
              builder: (controller) {
                return Column(
                  children: [
                    SizedBox(height: 5,),
                    /// FROM - TO (Required)
                    Row(
                      children: [
                        Expanded(child: buildSearchableDropdown("From", Controller.locations, Controller.from, required: true,allowAdd: true)),
                        SizedBox(width: 10),
                        Expanded(child: buildSearchableDropdown("To", Controller.locations, Controller.to, required: true,allowAdd: true)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      children: [
                        Expanded(child: buildTextField(
                          "Loading Points", Controller.loadingPointController,
                          isNumeric: true, isDefault: true,)),
                        SizedBox(width: 10,),
                        Expanded(child: buildTextField("Unloading Points",
                          Controller.unloadingPointController,
                          isNumeric: true, isDefault: true,)),
                      ],
                    ),
                    Row(children: [
                      Expanded(
                        child: buildSearchableDropdown(
                          "Vehicle Code",
                          required: true,
                          allowAdd: false,
                          Controller.vehicleID,
                          Controller.selectedVehicle,
                          // Bind selected vehicle
                          onSelected: (selectedValue) {
                            Controller.onVehicleSelected(selectedValue);
                            spinkit;
                            // Trigger selection
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: buildReadOnlyField(
                              "Vehicle Regn No.",
                              Controller.selectedVehicleNumbers,
                              Controller.vehicleNumberController)),
                    ]),
                    Row(
                      children: [
                        Expanded(
                            child: buildReadOnlyField(
                                "Driver Name",
                                Controller.selectedDriverName,
                                Controller.driverNameController)),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: buildReadOnlyField(
                                "Driver's Phone",
                                Controller.selectedDriverMobile,
                                Controller.driverPhoneController)),
                      ],
                    ),
                    buildReadOnlyField("Pick Vendor", Controller.selectedVendorName, Controller.vendorNameController),
                    SizedBox(height: 5,),

                    /// CUSTOMER (Required)
                    buildSearchableDropdown(
                        "Billing Unit", Controller.billingUnits, Controller.billingUnit,
                        required: true,allowAdd: false),

                    SizedBox(height: 5,),


                    /// DATE (Auto-generated)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              _selectDate(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeEight,
                                  vertical: Dimensions.paddingSizeTwelve),
                              decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.green,width: 1.5),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Obx(() => Text(
                                      controller.selectedDate.value == null
                                          ? "Pick a date"
                                          : " ${DateFormat('MMMM dd, yyyy').format(controller.selectedDate.value!)}",
                                      style: quicksandRegular.copyWith(
                                          fontSize: Dimensions.fontSizeFourteen))),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColor.green,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),


                        /// Cargo Weight (Required, Numeric)
                        Expanded(
                          child: buildTextField("Cargo Weight (MT)",
                              Controller.cargoWeightController,
                              required: false, isNumeric: true),
                        ),
                      ],
                    ),

                    SizedBox(height: 5),
                    buildMultiSelectDropdown(
                      "Product Type", // Label for the dropdown
                      Controller.cargoTypes, // List of cargo types (RxList<String>)
                      Controller.cargoType, // Selected cargo types (RxList<String>)
                      required: false, // You can make it required if needed
                      onSelected: (selectedItems) {
                        // Handle the selected items, if necessary
                        print("Selected cargo types: $selectedItems");
                      },
                      allowAdd: true, // If you want to allow adding new items, set to true
                    ),

                    SizedBox(height: 5,),

                    Row(
                      children: [
                        Expanded(child: buildTextField("Distance (KM)", Controller.distanceController,isNumeric: true)),
                        SizedBox(width: 10),
                        Expanded(child: buildTextField("Service Charge (BDT)", Controller.serviceChargeController, isNumeric: true)),
                      ],
                    ),

                    /// Start & Unloading Time
                    Row(
                      children: [
                        Expanded(child: buildDateTimeField(
                            "Pickup Time", Controller.pickupDate)),
                        SizedBox(width: 10,),
                        Expanded(
                          child: buildDateTimeField(
                              "Drop-off Time", Controller.dropOffDate),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),

                    /// Segment (Required)
                    /* buildSearchableDropdown("Segment", controller.segments, controller.segment, required: false, allowAdd: false),
                    SizedBox(height: 5,),*/
                    buildTextField("Special Note", Controller.noteController, isLabel: true),
                    SizedBox(height: 10,),
                    CustomOutlinedButton(
                      text: "Proof of Delivery",
                      color: AppColor.green,
                      width: double.infinity,
                      height: 45,
                      onTap: () {
                        //Get.toNamed("ProofOfDeliveryScreen");
                        Get.to(() => ProofOfDeliveryScreenRental(), arguments: {
                          'tripId': tripNo,
                          'tripPoD': Get.find<UpdateRentalController>().tripPoD.value ?? '',
                        });
                      },
                    ),

                    SizedBox(height: 10),

                    /// Submit Button
                    Row(
                      children: [
                        Expanded(
                            child: Obx(() => loadingController.isUpdatingTrip.value
                                ? spinkit
                                : CustomButton(
                              text: "Update Trip",
                              color: AppColor.neviBlue,
                              height: 40,
                              width: 180,
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  loadingController.runWithLoader(
                                    loader: loadingController.isUpdatingTrip,
                                    action: () async {
                                      await Controller.updateTrip(tripNo);
                                      await Future.delayed(Duration(milliseconds: 500));
                                      Get.find<TripHistoryController>().fetchTrips();
                                      Get.back();
                                    },
                                  );
                                }
                              },
                            ))
                        ),
                       /* Expanded(
                            child: Obx(() => loadingController.isClosingTrip.value
                                ? spinkit
                                : CustomButton(
                              text: "Close Trip",
                              height: 40,
                              width: 180,
                              onTap: () {
                                loadingController.runWithLoader(
                                  loader: loadingController.isClosingTrip,
                                  action: () async {
                                    // Optional: simulate a delay or do other closing operations
                                    await Future.delayed(Duration(milliseconds: 500));
                                    Get.back();
                                  },
                                );
                              },
                            ))
                        ),*/
                        Expanded(
                            child: CustomButton(
                              text: "Print Challan",
                              height: 40,
                              width: 200,
                              onTap: () {
                                Get.toNamed(RoutesName.challanScreen, arguments: "$tripNo"); //  Example trip number
                              },
                            ))
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDateTimeField(String label, Rx<DateTime?> date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(() => TextFormField(
        readOnly: true,
        style: quicksandSemibold.copyWith(
          fontSize: Dimensions.fontSizeFourteen,// Ensure text is not bold
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
          suffixIcon: Icon(Icons.calendar_today,color: AppColor.green,),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
              borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.green),
              borderRadius: BorderRadius.circular(12)),
        ),
        controller: TextEditingController(
            text: date.value != null
                ? "${date.value!.toLocal()}".split(' ')[0] +
                " " +
                "${date.value!.hour}:${date.value!.minute}"
                : ""),
        onTap: () => Controller.pickDateTime(date),
      )),
    );
  }

  Widget buildSearchableDropdown(
      String label, List<String> items, RxnString selectedValue,
      {bool required = false, String? defaultValue, Function(String)? onSelected, bool allowAdd = false}) { // allowAdd default to false
    return Obx(() {
      if (selectedValue.value == null && defaultValue != null) {
        selectedValue.value = defaultValue;
      }

      TextEditingController controller = TextEditingController(
          text: selectedValue.value ?? "");

      return TextFormField(
        style: quicksandSemibold.copyWith(
          fontSize: Dimensions.fontSizeFourteen,// Ensure text is not bold
        ),
        controller: controller,
        readOnly: true, // Prevent manual typing
        onTap: () {
          showSearchDialog(
            label,
            items,
            selectedValue,
            controller,
            onSelected,
            allowAdd, // Pass allowAdd dynamically
          );
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
          quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
              borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.green),
              borderRadius: BorderRadius.circular(12)),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width: 1.5, color: AppColor.primaryRed),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width: 1.5, color: AppColor.primaryRed),
          ),
          contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeTwelve,
              vertical: Dimensions.paddingSizeFourteen),
          suffixIcon:
          Icon(Icons.arrow_drop_down, color: AppColor.green), // Dropdown icon
        ),
        validator: required
            ? (value) =>
        (value == null || value.isEmpty) ? "Please select $label" : null
            : null,
      );
    });
  }

  void showSearchDialog(
      String label,
      List<String> items,
      RxnString selectedValue,
      TextEditingController controller,
      Function(String)? onSelected,
      bool allowAdd, // Accept allowAdd parameter
      ) {
    TextEditingController searchController = TextEditingController();
    RxList<String> filteredItems = items.obs;
    RxBool isNewItem = false.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select $label",
                  style: quicksandBold.copyWith(
                      fontSize: Dimensions.fontSizeEighteen,
                      color: AppColor.neviBlue)),
              SizedBox(height: 10),

              // 🔍 Search Field
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: AppColor.neviBlue),
                  hintText: allowAdd ? "Search or add..." : "Search...",
                  hintStyle: quicksandSemibold.copyWith(
                      fontSize: Dimensions.fontSizeSixteen,
                      color: AppColor.neviBlue),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1.5, color: AppColor.green),
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(width: 1.5, color: AppColor.neviBlue),
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (query) {
                  filteredItems.value = items
                      .where((item) =>
                      item.toLowerCase().contains(query.toLowerCase()))
                      .toList();

                  // Show "Add" button only if allowed and item is new
                  isNewItem.value =
                      allowAdd && query.isNotEmpty && !items.contains(query.trim());
                },
              ),
              SizedBox(height: 10),

              // 📋 Search Result List
              Obx(() => Container(
                height: 200,
                child: filteredItems.isNotEmpty
                    ? ListView.separated(
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        filteredItems[index],
                        style: quicksandRegular.copyWith(
                            fontSize: Dimensions.fontSizeFourteen,
                            color: AppColor.neviBlue),
                      ),
                      onTap: () {
                        selectedValue.value = filteredItems[index];
                        if (onSelected != null) {
                          onSelected(filteredItems[index]);
                        }
                        Get.back();
                      },
                    );
                  },
                )
                    : Center(child: Text("No matches found")),
              )),

              Obx(() => isNewItem.value
                  ? ElevatedButton.icon(
                onPressed: () {
                  String newItem = searchController.text;
                  if (newItem.isNotEmpty) {
                    items.add(newItem);
                    selectedValue.value = newItem;
                    if (onSelected != null) {
                      onSelected(newItem);
                    }
                    Get.back();
                  }
                },
                icon: Icon(Icons.add, color: AppColor.white),
                label: Text("Add",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.neviBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              )
                  : SizedBox()),

              SizedBox(height: 10,),
              CustomButton(
                  onTap: () => Get.back(),
                  text: "OK",
                  width: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMultiSelectDropdown(
      String label,
      RxList<String> items,  // Available options
      RxList<String> selectedValues,  // Selected values
          {bool required = false, Function(List<String>)? onSelected, bool allowAdd = false}
      ) {
    return Obx(() {
      TextEditingController controller = TextEditingController(
          text: selectedValues.isNotEmpty ? selectedValues.join(", ") : ""
      );

      return TextFormField(
        minLines: 1,
        maxLines: null,
        controller: controller,
        readOnly: true,
        style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen),
        onTap: () {
          showMultiSelectDialog(label, items, selectedValues, controller, onSelected, allowAdd);
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: AppColor.green),
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeTwelve,
              vertical: Dimensions.paddingSizeFourteen
          ),
          suffixIcon: Icon(Icons.arrow_drop_down, color: AppColor.green),
        ),
        validator: required
            ? (value) => (value == null || value.isEmpty) ? "Please select $label" : null
            : null,
      );
    });
  }



  void showMultiSelectDialog(
      String label,
      RxList<String> items,  // Available items
      RxList<String> selectedValues,  // Selected values
      TextEditingController controller,
      Function(List<String>)? onSelected,
      bool allowAdd
      ) {
    TextEditingController searchController = TextEditingController();
    RxList<String> filteredItems = items
        .toList()
        .obs;
    RxBool isNewItem = false.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select $label", style: quicksandBold.copyWith(
                  fontSize: Dimensions.fontSizeEighteen,
                  color: AppColor.neviBlue)),
              SizedBox(height: 10),

              // Search Field
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: AppColor.neviBlue),
                  hintText: allowAdd ? "Search or add..." : "Search...",
                  hintStyle: quicksandSemibold.copyWith(
                      fontSize: Dimensions.fontSizeSixteen,
                      color: AppColor.neviBlue),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.5, color: AppColor.green),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (query) {
                  filteredItems.value = items
                      .where((item) =>
                      item.toLowerCase().contains(query.toLowerCase()))
                      .toList();

                  isNewItem.value = allowAdd && query.isNotEmpty &&
                      !items.contains(query.trim());
                },
              ),
              SizedBox(height: 10),

              // List of Items with Checkboxes
              Obx(() =>
                  Container(
                    height: 200,
                    child: filteredItems.isNotEmpty
                        ? ListView.separated(
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => Divider(),
                      itemBuilder: (context, index) {
                        String currentItem = filteredItems[index];
                        return Obx(() =>
                            CheckboxListTile(
                              title: Text(currentItem,
                                  style: quicksandRegular.copyWith(
                                      fontSize: Dimensions.fontSizeFourteen,
                                      color: AppColor.neviBlue)),
                              value: selectedValues.contains(currentItem),
                              onChanged: (bool? isChecked) {
                                if (isChecked == true) {
                                  selectedValues.add(currentItem);
                                } else {
                                  selectedValues.remove(currentItem);
                                }
                                controller.text = selectedValues.join(", ");
                              },
                            ));
                      },
                    )
                        : Center(child: Text("No matches found")),
                  )),

              // Add Button (if new item doesn't exist)
              Obx(() =>
              isNewItem.value
                  ? ElevatedButton.icon(
                onPressed: () {
                  String newItem = searchController.text.trim();
                  if (newItem.isNotEmpty) {
                    items.add(newItem);
                    selectedValues.add(newItem);
                    controller.text = selectedValues.join(", ");
                    if (onSelected != null) {
                      onSelected(selectedValues);
                    }
                    Get.back();
                  }
                },
                icon: Icon(Icons.add, color: AppColor.white),
                label: Text("Add", style: quicksandBold.copyWith(
                    fontSize: Dimensions.fontSizeFourteen,
                    color: AppColor.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.neviBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              )
                  : SizedBox()),

              SizedBox(height: 10),

              CustomButton(
                  onTap: () => Get.back(),
                  text: "OK",
                  width: 80),
            ],
          ),
        ),
      ),
    );
  }


  /// 🔹 Read-Only Text Field (No Validation)
  Widget buildReadOnlyField(String label, RxString value,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(() {
        // If value is empty, set a default value without changing RxString state
        String emptyValue = "N/A";
        controller.text = value.value.isEmpty ? emptyValue : value.value;

        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelStyle: quicksandRegular.copyWith(
                fontSize: Dimensions.fontSizeFourteen),
            labelText: label,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.green),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          readOnly: true,
          style: quicksandSemibold.copyWith(
            fontSize: Dimensions.fontSizeFourteen, // Ensure text is not bold
          ),
        );
      }),
    );
  }

  /// 🔹 Standard Text Field with Validation
  Widget buildTextField(String label,
      TextEditingController controller, {
        bool required = false,
        bool isNumeric = false,
        bool isLabel = false,
        bool isDefault = false, // Add this parameter to check if default value should be used
      }) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        maxLines: isLabel ? 2 : null,
        decoration: InputDecoration(
          hintText: isLabel ? "Cannot exceed more than 250 words" : null,
          hintStyle: quicksandRegular.copyWith(
              fontSize: Dimensions.fontSizeFourteen),
          labelStyle: quicksandRegular.copyWith(
              fontSize: Dimensions.fontSizeFourteen),
          labelText: label,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: AppColor.green),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters: isDefault
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
        style: quicksandSemibold.copyWith(
          fontSize: Dimensions.fontSizeFourteen,// Ensure text is not bold
        ),
      ),
    );
  }
}