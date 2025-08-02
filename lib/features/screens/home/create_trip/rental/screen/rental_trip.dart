import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tk_logistics/common/widgets/custom_outlined_button.dart';
import 'package:tk_logistics/common/widgets/custom_textfield.dart';
import 'package:tk_logistics/features/screens/home/create_trip/rental/controller/rental_controller.dart';
import 'package:tk_logistics/util/dimensions.dart';
import 'package:tk_logistics/util/styles.dart';

import '../../../../../../common/widgets/custom_button.dart';
import '../../../../../../common/widgets/custom_indicator.dart';
import '../../../../../../common/widgets/loading_cntroller.dart';
import '../../../../../../util/app_color.dart';
import '../../../../../auth/login/controller/user_controller.dart';


class RentalTrip extends StatelessWidget {
  final userController = Get.find<UserController>();
  final RentalController Controller = Get.put(RentalController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final loadingController = Get.find<LoadingController>();


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: Controller.selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      Controller.pickDate(picked); // Save only the date
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: GetBuilder<RentalController>(
              initState: (_) {
                Controller.fetchLocations();
                Controller.fetchVehicleNumbers();
                Controller.fetchBillingUnits();
                //Controller.fetchSuppliers();
                Controller.fetchCargoType();
                Controller.fetchSegment();
                if (Controller.locations.isNotEmpty) {
                  Controller.from.value = (userController.user.value?.zone?.isNotEmpty ?? false)
                      ? userController.user.value?.zone
                      : Controller.locations.first; // Set first item as default
                }// ✅ Fetch locations when screen opens
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
                    //SizedBox(height: 5,),
                    /*buildSearchableDropdown(
                        "Pick Vendor", controller.pickSuppliers,
                        controller.pickSupplier,allowAdd: true,required: true),*/
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
                                controller.selectedDriverName,
                                controller.driverNameController)),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: buildReadOnlyField(
                                "Driver's Phone",
                                controller.selectedDriverMobile,
                                controller.driverPhoneController)),
                      ],
                    ),
                    buildReadOnlyField("Vendor", Controller.selectedVendorName, Controller.vendorNameController),
                    SizedBox(height: 5,),
                    /// CUSTOMER (Required)
                    buildSearchableDropdown(
                        "Billing Unit", Controller.billingUnits, Controller.billingUnit,
                        required: true,allowAdd: false),

                    SizedBox(height: 10,),


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
                                vertical: Dimensions.paddingSizeTwelve,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColor.green, width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Obx(() =>
                                      Text(
                                        Controller.selectedDate.value == null
                                            ? "Pick a date to view trips"
                                            : DateFormat('yyyy-MM-dd').format(
                                            Controller.selectedDate.value!),
                                        // Formats only date
                                        style: quicksandRegular.copyWith(
                                            fontSize: Dimensions.fontSizeFourteen),
                                      )),
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
                        Expanded(
                          child: buildTextField("Cargo Weight (MT)",
                              Controller.cargoWeightController,
                              required: true, isNumeric: true),
                        ),
                      ],
                    ),

                    SizedBox(height: 5,),

                    /// Cargo Weight (Required, Numeric)
                    //SizedBox(width: 10),
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

                    // buildReadOnlyField("Challan", controller.challan.value), not necessary

                    SizedBox(height: 5,),
                    Row(
                      children: [
                        Expanded(child: buildTextField("Distance (KM)", Controller.distanceController,isNumeric: true,required: true)),
                        SizedBox(width: 10),
                        Expanded(child: buildTextField("Service Charge (BDT)", Controller.serviceChargeController, isNumeric: true)),
                      ],
                    ),

                    /// Start & Unloading Time
                    Row(
                      children: [
                        Expanded(
                          child: buildDateTimeField(
                            "Pickup Time",
                            Controller.pickupDate,
                            controller: Controller.pickupDateController,
                            required: true,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: buildDateTimeField(
                            "Est. Drop-off Time",
                            Controller.dropOffDate,
                            controller: Controller.dropOffDateController,

                            required: true,
                          ),
                        ),
                      ],
                    ),

                    /// Segment (Required)
                    //buildSearchableDropdown("Segment", controller.segments, controller.segment, required: false,allowAdd: false),
                    buildTextField("Special Note", Controller.noteController, isLabel: true),
                    SizedBox(height: 10,),

                    /// Submit Button
                    Obx(() => loadingController.isCreatingTrip.value
                        ? spinkit
                        : CustomButton(
                      text: "Create Trip",
                      color: AppColor.neviBlue,
                      height: 40,
                      width: 180,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          // Show confirmation dialog
                          Get.dialog(
                            AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), // Rounded corners for dialog
                              ),
                              backgroundColor: AppColor.mintGreenBG,
                              title: Text("Confirm",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeTwenty,color: AppColor.neviBlue)),
                              content: Text("Are you sure you want to create this trip?",style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeSixteen)),
                              actions: [
                                // No button
                                TextButton(
                                  onPressed: () {
                                    Get.back(); // Close the dialog
                                  },
                                  child: Text("No",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.primaryRed)),
                                ),
                                // Yes button
                                TextButton(
                                  onPressed: () async {
                                    Get.back(); // Close the dialog

                                    // Run with loader and create the trip
                                    await loadingController.runWithLoader(
                                      loader: loadingController.isCreatingTrip,
                                      action: () async {
                                        await Controller.createTrip();  // Just await it

                                        _formKey.currentState?.reset();     // Reset form validation
                                        Controller.clearFormFields();
                                        Controller.refreshFormUI();// Clear input fields
                                      },
                                    );
                                  },
                                  child: Text("Yes",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.persianGreen)),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    )),
                   /* Obx(() {
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
                    }),*/
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDateTimeField(
      String label,
      Rx<DateTime?> date, {
        required TextEditingController controller,
        bool required = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeEight),
      child: Obx(() {
        bool isFieldEmpty = date.value == null;
        bool hasDate = !isFieldEmpty;

        Color borderColor = (required && isFieldEmpty)
            ? AppColor.primaryRed
            : hasDate
            ? AppColor.neviBlue
            : AppColor.neviBlue;

        Color labelColor = (required && isFieldEmpty)
            ? AppColor.primaryRed
            : hasDate
            ? AppColor.black
            : AppColor.black;

        Color iconColor = (required && isFieldEmpty)
            ? AppColor.primaryRed
            : hasDate
            ? AppColor.green
            : AppColor.green;

        Color textColor = hasDate ? AppColor.black : AppColor.black;

        return TextFormField(
          readOnly: true,
          controller: controller,
          style: quicksandSemibold.copyWith(
            fontSize: Dimensions.fontSizeFourteen,
            color: textColor,
          ),
          decoration: InputDecoration(
            errorText: null,
            errorStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeTen),
            labelText: label,
            labelStyle: quicksandRegular.copyWith(
              fontSize: Dimensions.fontSizeFourteen,
              color: labelColor,
            ),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: iconColor,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 1.5, color: AppColor.primaryRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 1.5, color: AppColor.primaryRed),
            ),
          ),
          validator: (_) {
            if (required && date.value == null) {
              return "This field is required";
            }
            return null;
          },
          onTap: () async {
            await Controller.pickDateTime(date);
          },
        );
      }),
    );
  }

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
        controller: controller,
        readOnly: true,
        style: quicksandSemibold.copyWith(
          fontSize: Dimensions.fontSizeFourteen,// Ensure text is not bold
        ),// Prevent manual typing
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
          errorText: null,
          errorStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeTen),
          labelText: label,
          labelStyle: quicksandRegular.copyWith(
            fontSize: Dimensions.fontSizeFourteen,
            color: (required && (selectedValue.value == null || selectedValue.value!.isEmpty))
                ? AppColor.primaryRed
                : AppColor.black, // or any color you want for filled state
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.5,
              color: (required && (selectedValue.value == null || selectedValue.value!.isEmpty))
                  ? AppColor.primaryRed
                  : AppColor.neviBlue,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.5,
              color: (required && (selectedValue.value == null || selectedValue.value!.isEmpty))
                  ? AppColor.primaryRed
                  : AppColor.neviBlue,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
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
    RxList<String> filteredItems = items.toList().obs;
    RxBool isNewItem = false.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select $label", style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeEighteen, color: AppColor.neviBlue)),
              SizedBox(height: 10),

              // Search Field
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: AppColor.neviBlue),
                  hintText: allowAdd ? "Search or add..." : "Search...",
                  hintStyle: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeSixteen, color: AppColor.neviBlue),
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
                      .where((item) => item.toLowerCase().contains(query.toLowerCase()))
                      .toList();

                  isNewItem.value = allowAdd && query.isNotEmpty && !items.contains(query.trim());
                },
              ),
              SizedBox(height: 10),

              // List of Items with Checkboxes
              Obx(() => Container(
                height: 200,
                child: filteredItems.isNotEmpty
                    ? ListView.separated(
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, index) {
                    String currentItem = filteredItems[index];
                    return Obx(() => CheckboxListTile(
                      title: Text(currentItem, style: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen, color: AppColor.neviBlue)),
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
              Obx(() => isNewItem.value
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
                label: Text("Add", style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen, color: AppColor.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.neviBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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


  /// 🔹 Standard Text Field with Validation
  Widget buildTextField(
      String label,
      TextEditingController controller, {
        bool required = false,
        bool isNumeric = false,
        bool isLabel = false,
        bool isDefault = false,
      }) {
    if (isDefault && controller.text.isEmpty) {
      controller.text = "1";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          bool isFieldEmpty = value.text.isEmpty;

          return TextFormField(
            maxLines: isLabel ? 2 : null,
            decoration: InputDecoration(
              errorText: null,
              errorStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeTen),
              hintText: isLabel ? "Cannot exceed more than 250 words" : null,
              hintStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
              labelStyle: quicksandRegular.copyWith(
                fontSize: Dimensions.fontSizeFourteen,
                color: (required && isFieldEmpty) ? AppColor.primaryRed : AppColor.black,
              ),
              labelText: label,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: (required && isFieldEmpty) ? AppColor.primaryRed : AppColor.neviBlue,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: (required && isFieldEmpty) ? AppColor.primaryRed : AppColor.green,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(width: 1.5, color: AppColor.primaryRed),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(width: 1.5, color: AppColor.primaryRed),
              ),
            ),
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            inputFormatters: isDefault ? [FilteringTextInputFormatter.digitsOnly] : [],
            style: quicksandSemibold.copyWith(
              fontSize: Dimensions.fontSizeFourteen,
            ),
            onChanged: (value) {
              if (isDefault && value.isEmpty) {
                controller.text = "";
                controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
              }
            },
            validator: required
                ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            }
                : null,
          );
        },
      ),
    );
  }
}