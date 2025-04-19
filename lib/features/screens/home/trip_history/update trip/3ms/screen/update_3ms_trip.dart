import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../../../../common/widgets/custom_button.dart';
import '../../../../../../../common/widgets/custom_outlined_button.dart';
import '../../../../../../../routes/routes_name.dart';
import '../../../../../../../util/app_color.dart';
import '../../../../../../../util/dimensions.dart';
import '../../../../../../../util/styles.dart';
import '../../../controller/trip_history_controller.dart';
import '../controller/update_3ms_controller.dart';


class Update3msTrip extends StatelessWidget {
  final Update3msController _controller = Get.put(Update3msController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
      initialDate: _controller.selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _controller.pickDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments; //  Get arguments safely

    final String tripNo = args?["tripNo"] ?? "Unknown";
    final Map<String, dynamic> tripData = args?["tripData"] ?? {};
    final String apiUrl = args?["apiUrl"] ?? "";

    if (tripNo != "Unknown") {
      _controller.fetchTripDetails(tripNo); //  Use tripNo to fetch data
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
            "Update 3MS Trip Data",
            style: quicksandBold.copyWith(
                fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: GetBuilder<Update3msController>(
              initState: (_) {
                _controller.fetchLocations();
                //tripController.fetchVehicleNumbers();
                _controller.fetchBillingUnits();
                _controller.fetchSuppliers();
                _controller.fetchCargoType();
                _controller.fetchSegment();
                if (_controller.locations.isNotEmpty) {
                  _controller.from.value = _controller.locations.first; // Set first item as default
                }//  Fetch locations when screen opens
              },
              builder: (controller) {
                return Column(
                  children: [
                    SizedBox(height: 5,),
                    /// FROM - TO (Required)
                    Row(
                      children: [
                        Expanded(child: buildSearchableDropdown("From", controller.locations, controller.from, required: true,allowAdd: true)),
                        SizedBox(width: 10),
                        Expanded(child: buildSearchableDropdown("To", controller.locations, controller.to, required: true,allowAdd: true)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      children: [
                        Expanded(child: buildTextField(
                          "Loading Points", controller.loadingPointController,
                          isNumeric: true, isDefault: true,)),
                        SizedBox(width: 10,),
                        Expanded(child: buildTextField("Unloading Points",
                          controller.unloadingPointController,
                          isNumeric: true, isDefault: true,)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    buildSearchableDropdown(
                        "Pick Vendor", controller.pickSuppliers,
                        controller.pickSupplier,allowAdd: true),
                    SizedBox(height: 5,),
                    buildTextField(
                      "Vehicle Number",
                      controller.vehicleIDController,
                    ),
                    SizedBox(width: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: buildTextField('Driver Name', controller.driverNameController),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: buildTextField(
                              "Driver's Phone",
                              controller.driverPhoneController),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),

                    /// CUSTOMER (Required)
                    buildSearchableDropdown(
                        "Billing Unit", controller.billingUnits, controller.billingUnit,
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
                              controller.cargoWeightController,
                              required: false, isNumeric: true),
                        ),
                      ],
                    ),

                    SizedBox(height: 5),
                    buildMultiSelectDropdown(
                      "Product Type", // Label for the dropdown
                      controller.cargoTypes, // List of cargo types (RxList<String>)
                      controller.cargoType, // Selected cargo types (RxList<String>)
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
                        Expanded(child: buildTextField("Distance (KM)", controller.distanceController,isNumeric: true)),
                        SizedBox(width: 10),
                        Expanded(child: buildTextField("Service Charge (BDT)", controller.serviceChargeController, isNumeric: true)),
                      ],
                    ),

                    /// Start & Unloading Time
                    Row(
                      children: [
                        Expanded(child: buildDateTimeField(
                            "Pickup Time", controller.pickupDate)),
                        SizedBox(width: 10,),
                        Expanded(
                          child: buildDateTimeField(
                              "Drop-off Time", controller.dropOffDate),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),

                    /// Segment (Required)
                   /* buildSearchableDropdown("Segment", controller.segments, controller.segment, required: false, allowAdd: false),
                    SizedBox(height: 5,),*/
                    buildTextField("Special Note", controller.noteController, isLabel: true),
                    SizedBox(height: 10,),
                    CustomOutlinedButton(
                      text : "Proof of Delivery",
                      color: AppColor.green,
                      width: double.infinity,
                      height: 45,
                      onTap: (){
                        Get.toNamed("ProofOfDocumentScreen");
                      },
                    ),

                    SizedBox(height: 10),

                    /// Submit Button
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Update Trip",
                            color: AppColor.neviBlue,
                            height: 40,
                            width: 180,
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                controller.updateTrip(tripNo).then((_) {
                                  // Trigger a refresh after updating the trip
                                  Get.find<TripHistoryController>().fetchTrips();
                                }
                                );
                                Get.back();;
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: CustomButton(
                            text: "Close Trip",
                            height: 40,
                            width: 180,
                            onTap: ()=> Get.back(),
                          ),
                        ),
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
        onTap: () => _controller.pickDateTime(date),
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

              TextButton(
                onPressed: () => Get.back(),
                child: Text("CLOSE",
                    style: quicksandSemibold.copyWith(
                        fontSize: Dimensions.fontSizeSixteen,
                        color: AppColor.primaryRed)),
              ),
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

            // Close Button
            TextButton(
              onPressed: () => Get.back(),
              child: Text("CLOSE", style: quicksandSemibold.copyWith(
                  fontSize: Dimensions.fontSizeSixteen,
                  color: AppColor.primaryRed)),
            ),
          ],
        ),
      ),
    ),
  );
}


/// 🔹 Read-Only Text Field (No Validation)
  Widget buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: quicksandSemibold.copyWith(
          fontSize: Dimensions.fontSizeFourteen,// Ensure text is not bold
        ),
        decoration: InputDecoration(
          labelStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
          labelText: label,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
              borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.green),
              borderRadius: BorderRadius.circular(12)),
        ),
        readOnly: true,
        initialValue: value,
      ),
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