import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/common/widgets/custom_outlined_button.dart';
import 'package:tk_logistics/common/widgets/custom_textfield.dart';
import 'package:tk_logistics/util/dimensions.dart';
import 'package:tk_logistics/util/styles.dart';

import '../../../../../../common/widgets/custom_button.dart';
import '../../../../../../util/app_color.dart';
import '../controller/threems_controller.dart';


class ThreemsTrip extends StatelessWidget {
  final ThreemsController tripController = Get.put(ThreemsController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: GetBuilder<ThreemsController>(
              initState: (_) {
                tripController.fetchLocations();
                tripController.fetchVehicleNumbers();
                tripController.fetchBillingUnits();
                tripController.fetchSuppliers();
                tripController.fetchCargoType();
                tripController.fetchSegment();// ✅ Fetch locations when screen opens
              },
              builder: (controller) {
                return Column(
                  children: [
                    /// FROM - TO (Required)
                    Row(
                      children: [
                        Expanded(child: buildSearchableDropdown("From", controller.locations, controller.from, required: true)),
                        SizedBox(width: 10),
                        Expanded(child: buildSearchableDropdown("To", controller.locations, controller.to, required: true)),
                      ],
                    ),
                    SizedBox(height: 10,),
                    buildSearchableDropdown(
                        "Pick Vendor", controller.pickSuppliers,
                        controller.pickSupplier),
                    Row(
                      children: [
                        Expanded(
                          child: buildSearchableDropdown(
                            "Vehicle ID",
                            controller.vehicleID,
                            controller.selectedVehicle,  // Bind selected vehicle
                            onSelected: (selectedValue) {
                              controller.onVehicleSelected(selectedValue);
                              // Trigger selection
                            },
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Obx(() {
                            print("Vehicle Number: ${controller.selectedVehicleNumbers.value}");  // Print driver name
                            return buildReadOnlyField('Vehicle Number', controller.selectedVehicleNumbers.value);
                          }),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            print("Driver ID: ${controller.selectedDriverID.value}");  // Print driver name
                            return buildReadOnlyField('Driver ID', controller.selectedDriverID.value);
                          }),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Obx(() {
                            print("Driver Phone: ${controller.selectedDriverMobile.value}");  // Print driver phone
                            return buildReadOnlyField(
                                "Driver's Phone",
                                controller.selectedDriverMobile.value
                            );
                          }),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),

                    /// CUSTOMER (Required)
                    buildSearchableDropdown(
                        "Billing Unit", controller.billingUnits, controller.billingUnit,
                        required: true),

                    SizedBox(height: 10,),


                    /// DATE (Auto-generated)
                    buildReadOnlyField("Date", controller.currentDate.value),

                    Row(
                      children: [
                        Expanded(child: buildTextField("Cargo Weight (MT)", controller.cargoWeightController, required: true, isNumeric: true)),
                        SizedBox(width: 10),
                        Expanded(child: buildSearchableDropdown("Cargo Type", controller.cargoTypes, controller.cargoType, required: false)),
                      ],
                    ),

                    buildReadOnlyField("Challan", controller.challan.value),

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
                            "Pickup Date & Time", controller.pickupDate)),
                        SizedBox(width: 10,),
                        Expanded(
                          child: buildDateTimeField(
                              "Drop-off Date & Time", controller.dropOffDate),
                        ),
                      ],
                    ),

                    /// Segment (Required)
                    buildSearchableDropdown("Segment", controller.segments, controller.segment, required: false),

                    buildTextField("Special Note", controller.noteController, isLabel: true),
                    SizedBox(height: 15,),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Create Trip",
                            color: AppColor.neviBlue,
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                controller.createTrip();
                              }
                            },
                          ),
                        ),
                        Obx(() {
                          return Expanded(
                            child: CustomOutlinedButton(
                              text: "Quotation",
                              color: AppColor.neviBlue,
                              disableColor: Colors.grey, // 🟡 Set disabled color
                              isEnabled: tripController.isTripCreated.value, // 🔹 Control enable/disable state
                              onTap: tripController.isTripCreated.value ? () {
                                Get.toNamed("QuotationScreen");
                              } : null,
                            ),
                          );
                        }),

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
        onTap: () => tripController.pickDateTime(date),
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
            final tmsController = Get.find<ThreemsController>();  // Get the controller instance
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
  Widget buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
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
  Widget buildTextField(String label, TextEditingController controller, {bool required = false, bool isNumeric = false, bool isLabel = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        maxLines: isLabel ? 2 : null,
        decoration: InputDecoration(
          hintText: isLabel ? "Can not exceed more than 250 words" : null,
          hintStyle: quicksandRegular.copyWith(fontSize: Dimensions
              .fontSizeFourteen),
          labelStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
          labelText: label,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
              borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.green),
              borderRadius: BorderRadius.circular(12)),
        ),
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        /*validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return "Please enter $label";
          }
          if (isNumeric && value != null && value.isNotEmpty && double.tryParse(value) == null) {
            return "Enter a valid number";
          }
          return null;
        },*/
      ),
    );
  }
}