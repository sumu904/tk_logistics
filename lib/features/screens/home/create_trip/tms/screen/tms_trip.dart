import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:image_picker/image_picker.dart';
import 'package:tk_logistics/common/widgets/custom_indicator.dart';
import 'package:tk_logistics/common/widgets/custom_outlined_button.dart';
import 'package:tk_logistics/features/screens/home/create_trip/3ms/controller/threems_controller.dart';
import 'package:tk_logistics/features/screens/home/create_trip/tms/controller/tms_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../common/widgets/custom_button.dart';
import '../../../../../../util/app_color.dart';
import '../../../../../../util/dimensions.dart';
import '../../../../../../util/styles.dart';
import '../../pod/controller/filed_picker_controller.dart';

class TmsTrip extends StatelessWidget {
  final TmsController tmsController = Get.put(TmsController());
  final FilePickerController fileController = Get.put(FilePickerController());

  /// 🔴 Add GlobalKey for Form State
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // 🔴 Wrap in Form widget
            child: GetBuilder<TmsController>(
              initState: (_) {
                tmsController.fetchLocations();
                tmsController
                    .fetchVehicleNumbers();
                tmsController.fetchBillingUnits();
                tmsController.fetchCargoType();
                tmsController.fetchTypeofTrip();
                tmsController.fetchSegment();// ✅ Fetch locations when screen opens
              },
              builder: (controller) {
                return Column(
                  children: [
                    /// FROM - TO (Required)
                    Row(
                      children: [
                        Expanded(
                            child: buildSearchableDropdown("From",
                                controller.locations, controller.from,
                                required: true)),
                        SizedBox(width: 10),
                        Expanded(
                            child: buildSearchableDropdown(
                                "To", controller.locations, controller.to,
                                required: true)),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),

                    /// VEHICLE NO & DRIVER INFO (Auto-generated)
                    Row(
                      children: [
                        Expanded(
                          child: buildSearchableDropdown(
                            "Vehicle ID",
                            controller.vehicleID,
                            controller.selectedVehicle,  // Bind selected vehicle
                            onSelected: (selectedValue) {
                              controller.onVehicleSelected(selectedValue);
                              spinkit;
                              // Trigger selection
                            },
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Obx(() {
                            print("Vehicle Number: ${controller.selectedVehicleNumbers.value}");

                            // ✅ Update the controller before building the UI
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              controller.vehicleNumberController.text = controller.selectedVehicleNumbers.value;
                            });

                            return buildReadOnlyField('Vehicle Number', controller.vehicleNumberController);
                          }),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            print("Driver ID: ${controller.selectedDriverID.value}");

                            // ✅ Update the controller before building the UI
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              controller.driverIDController.text = controller.selectedDriverID.value;
                            });

                            return buildReadOnlyField('Vehicle Number', controller.driverIDController);
                          }),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Obx(() {
                            print("Driver Phone: ${controller.selectedDriverMobile.value}");  // Print driver phone
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              controller.driverPhoneController.text = controller.selectedDriverMobile.value;
                            });

                            return buildReadOnlyField('Driver"s Phone', controller.driverPhoneController);
                          }),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),

                    /// CUSTOMER (Required)
                    buildSearchableDropdown("Billing Unit",
                        controller.billingUnits, controller.billingUnit,
                        required: true),
                    SizedBox(height: 5,),

                    /// DATE (Auto-generated)
                    buildReadOnlyField("Date", controller.currentDateController),

                    /// Cargo Weight (Required, Numeric)
                    Row(
                      children: [
                        Expanded(
                            child: buildTextField("Cargo Weight (MT)",
                                controller.cargoWeightController,
                                required: false, isNumeric: true)),
                        SizedBox(width: 10),
                        Expanded(
                            child: buildSearchableDropdown("Cargo Type",
                                controller.cargoTypes, controller.cargoType,
                                required: false)),
                      ],
                    ),
                    buildReadOnlyField("Challan", controller.challanController),

                    Row(
                      children: [
                        Expanded(
                            child: buildTextField(
                                "Distance (KM)", controller.distanceController,
                                isNumeric: true)),
                        SizedBox(width: 10),
                        Expanded(
                            child: buildTextField("Service Charge (BDT)",
                                controller.serviceChargeController,
                                isNumeric: true)),
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

                    /// Type of Trip (Required)
                    Row(
                      children: [
                        Expanded(
                            child: buildSearchableDropdown("Type of Trip",
                                controller.tripTypes, controller.tripType,
                                required: false)),
                        SizedBox(width: 10),
                        Expanded(
                            child: buildSearchableDropdown("Segment",
                                controller.segments, controller.segment,
                                required: false)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    buildTextField("Special Note", controller.noteController,
                        isLabel: true),
                    SizedBox(
                      height: 10,
                    ),

                    /// POD (Required)
                    CustomOutlinedButton(
                      text: "Proof of Delivery",
                      color: AppColor.green,
                      width: double.infinity,
                      height: 45,
                      onTap: () {
                        Get.toNamed("ProofOfDeliveryScreen");
                      },
                    ),

                    SizedBox(height: 10),

                    /// Submit Button
                    CustomButton(
                      text: "Create Trip",
                      color: AppColor.neviBlue,
                      height: 40,
                      width: 180,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          controller.createTrip();
                        }
                      },
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
          suffixIcon: Icon(Icons.calendar_today),
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
        onTap: () => tmsController.pickDateTime(date),
      )),
    );
  }

  Widget buildSearchableDropdown(
      String label, List<String> items, RxnString selectedValue,
      {bool required = false,Function(String)? onSelected,}) {
    TextEditingController controller = TextEditingController(
        text: selectedValue.value ?? ""); // Initialize controller

    // Ensure controller updates when selectedValue changes
    once(selectedValue, (value) {
      controller.text = value ?? "";
    });

    return TextFormField(
      controller: controller,
      readOnly: true,
      // Prevent manual typing
        onTap: () {
          showSearchDialog(
            label,
            items,
            selectedValue,
            controller,
                (selectedVehicle) {
              selectedValue.value = selectedVehicle;  // Update the selected vehicle value
              final tmsController = Get.find<TmsController>();  // Get the controller instance
              tmsController.onVehicleSelected(selectedVehicle);
              // Update driver info
            },
          );
          },

// Open search dialog
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
        // Adjust spacing
        suffixIcon:
            Icon(Icons.arrow_drop_down, color: AppColor.green), // Dropdown icon
      ),
      validator: required
          ? (value) =>
              (value == null || value.isEmpty) ? "Please select $label" : null
          : null,
    );
  }

  void showSearchDialog(String label, List<String> items,
      RxnString selectedValue, TextEditingController controller,Function(String)? onSelected,) {
    TextEditingController searchController = TextEditingController();
    RxList<String> filteredItems = items.obs;

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
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColor.neviBlue,
                  ),
                  hintText: "Search...",
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
                },
              ),
              SizedBox(height: 10),
              // 📋 Search Result List
              Obx(() => Container(
                    height: 200,
                    child: ListView.separated(
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
                              onSelected(filteredItems[index]); // Call callback
                            }
                            Get.back(); // Close dialog
                          },
                        );
                      },
                    ),
                  )),
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

  /// 🔹 Read-Only Text Field (No Validation)
  Widget buildReadOnlyField(String label, TextEditingController _controller) {
    print("I AM Vehicle No Value ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ${_controller.text}");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controller, // ✅ Use only controller (No initialValue)
        decoration: InputDecoration(
          labelStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
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
      ),
    );
  }

  /// 🔹 Standard Text Field with Validation
  Widget buildTextField(String label, TextEditingController controller,
      {bool required = false, bool isNumeric = false, bool isLabel = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        maxLines: isLabel ? 2 : null,
        decoration: InputDecoration(
          hintText: isLabel ? "Can not exceed more than 250 words" : null,
          hintStyle:
              quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
          labelStyle:
              quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
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
      ),
    );
  }
}