import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tk_logistics/common/widgets/custom_button.dart';
import 'package:tk_logistics/common/widgets/custom_outlined_button.dart';

import '../../../../../common/widgets/custom_indicator.dart';
import '../../../../../common/widgets/loading_cntroller.dart';
import '../../../../../util/app_color.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';
import '../controller/fuel_entry_controller.dart';

class FuelEntryScreen extends StatelessWidget {
  final FuelEntryController controller = Get.put(FuelEntryController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final loadingController = Get.find<LoadingController>();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.pickDate(picked); // Save only the date
    }
  }

  @override
  Widget build(BuildContext context) {
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
            "Fuel Entry Form",
            style: quicksandBold.copyWith(
                fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeTwenty,
              vertical: Dimensions.paddingSizeTwenty),
          child: Form(
            key: _formKey,
            child: GetBuilder<FuelEntryController>(initState: (_) {
              controller.fetchVehicleNumbers();
              controller.fetchFuelType();
              controller.fetchPumpNames();
              controller.fetchFuelEntries();
              if (controller.fuelTypes.isNotEmpty) {
                controller.fuelType.value = controller.fuelTypes[1];
// Set first item as default
              } //  Fetch locations when screen opens
            }, builder: (controller) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: buildSearchableDropdown(
                          "Vehicle ID",
                          controller.vehicleID,
                          controller.selectedVehicle,
                          required: true,
                          // Bind selected vehicle
                          onSelected: (selectedValue) {
                            controller.onVehicleSelected(selectedValue);
                            // Trigger selection
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Obx(() {
                          print(
                              "Vehicle Number: ${controller.selectedVehicleNumbers.value}");

                          //  Update the controller before building the UI
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            controller.vehicleNumberController.text =
                                controller.selectedVehicleNumbers.value;
                          });

                          return buildReadOnlyField('Vehicle Number',
                              controller.vehicleNumberController);
                        }),
                      ),
                    ],
                  ),
                  Obx(() {
                    print(
                        "Driver Name: ${controller.selectedDriverName.value}");
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.driverNameController.text =
                          controller.selectedDriverName.value;
                    });

                    return buildReadOnlyField(
                        'Driver Name', controller.driverNameController);
                  }),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      controller.selectDate(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeTen,
                        vertical: Dimensions.paddingSizeFifteen,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.green, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Text(
                                controller.selectedDate.value != null
                                    ? DateFormat('yyyy-MM-dd').format(controller
                                        .selectedDate
                                        .value!) // ✅ Safely handle null
                                    : "Pick a date to view trips",
                                // ✅ Placeholder for null
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
                  SizedBox(height: 12),
                  buildSearchableDropdown(
                    "Fuel Type",
                    required: true,
                    controller.fuelTypes,
                    controller.selectedFuelType,
                    onSelected: (selectedValue) {
                      controller.onFuelTypeSelected(selectedValue);
                      // Trigger selection
                    },
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          print(
                              "Rate per ltr: ${controller.selectedRatePerLtr.value}");

                          //  Update the controller before building the UI
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            controller.ratePerLtrController.text =
                                controller.selectedRatePerLtr.value;
                          });

                          return buildReadOnlyField(
                              'Rate Per Ltr', controller.ratePerLtrController);
                        }),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: buildDieselAmountField(
                          "Fuel Amount (Ltr)",
                          required: true,
                          controller.dieselAmountController,
                          TextInputType.number,
                          onChanged: () => controller
                              .updateTotalPrice(), //  Update total price dynamically
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Obx(() {
                    return buildTextField(
                      "Total Price",
                      TextEditingController(
                        text: controller.totalPrice.value
                            .toStringAsFixed(2), //  Use observable value
                      ),
                      TextInputType.number,
                      isNumeric: true,
                      isLabel: false,
                      readOnly: true, //  Make it read-only
                    );
                  }),
                  SizedBox(height: 7,),
                  buildSearchableDropdown(
                    "Pump Name",
                    controller.pumpNames,
                    controller.selectedPumpName,
                    required: false,
                    onSelected: (selectedPump) {
                      controller.pumpNameController.text = selectedPump; // update text controller if needed
                      print("Selected Pump: $selectedPump");
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: Obx(() => loadingController.isSubmitting.value
                              ? spinkit // Show the loader when the action is running
                              : CustomButton(
                            onTap: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                print("Form validated successfully!");
                                // Show the confirmation dialog
                                bool? confirmed = await Get.dialog<bool>(
                                  AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          30), // Rounded corners
                                    ),
                                    backgroundColor: AppColor.mintGreenBG,
                                    title: Text("Confirm Submission",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeTwenty,color: AppColor.neviBlue)),
                                    content: Text("Are you sure you want to submit this form?",style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeSixteen)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(result: false), // No button
                                        child: Text("No",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.primaryRed)),
                                      ),
                                      TextButton(
                                        onPressed: () => Get.back(result: true), // Yes button
                                        child: Text("Yes",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.persianGreen)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  // If user selects 'Yes', proceed with submission
                                  loadingController.runWithLoader(
                                    loader: loadingController.isSubmitting,
                                    action: () async {
                                      await controller.addEntry(); // Proceed with submission if valid
                                      await controller.fetchFuelEntries(); // Fetch updated fuel entries
                                      await Future.delayed(Duration(milliseconds: 500));
                                    },
                                  );
                                } else {
                                  print("Submission canceled.");
                                }
                              } else {
                                print("Validation failed! Please check inputs.");
                              }
                            },
                            text: 'Submit',
                          ),
                          )
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Obx(() => loadingController.isLoading.value
                            ? spinkit // Show the loader when the action is running
                            : CustomOutlinedButton(
                          width: double.infinity,
                          onTap: () {
                            loadingController.runWithLoader(
                              loader: loadingController.isLoading,
                              action: () async {
                                // Simulate a delay or any other task before navigation
                                await Future.delayed(Duration(seconds: 1));
                                Get.toNamed("FuelEntryList"); // Navigate to the Fuel Entry List screen
                              },
                            );
                          },
                          text: 'See Entry List',
                        ),
                        )
                      )
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType, {
    bool required = false,
    bool isNumeric = false,
    bool isLabel = false,
    bool readOnly = false, //  Added readOnly parameter
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeEight),
      child: TextFormField(
        style: quicksandSemibold.copyWith(
          fontSize: Dimensions.fontSizeFourteen, // Ensure text is not bold
        ),
        maxLines: isLabel ? 2 : null,
        decoration: InputDecoration(
          errorText: null,
          errorStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeTen),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width: 1.5, color: AppColor.primaryRed),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width: 1.5, color: AppColor.primaryRed),
          ),
        ),
        readOnly: readOnly,
        //  Now controlled by the parameter
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: required
            ? (value) =>
        (value == null || value.isEmpty) ? "Please select $label" : null
            : null,
      ),
    );
  }

  Widget buildSearchableDropdown(
      String label, List<String> items, RxnString selectedValue,
      {bool required = false, Function(String)? onSelected}) {
    TextEditingController controller = TextEditingController(
        text: selectedValue.value ?? ""); // Initialize controller

    // Ensure controller updates when selectedValue changes
    once(selectedValue, (value) {
      controller.text = value ?? "";
    });

    return TextFormField(
      style: quicksandSemibold.copyWith(
        fontSize: Dimensions.fontSizeFourteen, // Ensure text is not bold
      ),
      controller: controller,
      readOnly: true,
      // Prevent manual typing
      onTap: () {
        showSearchDialog(
          label,
          items,
          selectedValue,
          controller,
          (selectedItem) {
            selectedValue.value = selectedItem; // Update selected value
            if (onSelected != null) {
              onSelected(selectedItem); // Dynamically call the correct function
            }
          },
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
                : AppColor.green,
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

  void showSearchDialog(
      String label,
      List<String> items,
      RxnString selectedValue,
      TextEditingController controller,
      Function(String)? onSelected) {
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

  Widget buildDieselAmountField(String label, TextEditingController controller,
      TextInputType keyboardType,
      {VoidCallback? onChanged,  bool required = false,}) {
    return TextFormField(
      style: quicksandSemibold.copyWith(
        fontSize: Dimensions.fontSizeFourteen, // Ensure text is not bold
      ),
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        errorText: null,
        errorStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeTen),
        labelText: label,
        labelStyle: quicksandRegular.copyWith(
          fontSize: Dimensions.fontSizeFourteen,
          color: (required && controller.text.isEmpty)
              ? AppColor.primaryRed
              : AppColor.black,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.5,
            color: (required && controller.text.isEmpty)
                ? AppColor.primaryRed
                : AppColor.neviBlue,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.5,
            color: (required && controller.text.isEmpty)
                ? AppColor.primaryRed
                : AppColor.green, // or AppColor.neviBlue if you want
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
      onChanged: (value) {
        if (onChanged != null) {
          onChanged(); //  Call updateTotalPrice() whenever value changes
        }
      },
      validator: required
          ? (value) =>
      (value == null || value.isEmpty) ? "Please select $label" : null
          : null,
    );
  }

  Widget buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () => controller.selectDate(context),
      child: Obx(() => InputDecorator(
            decoration: InputDecoration(
              labelText: "Select Date",
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1.5, color: AppColor.green),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              controller.selectedDate.value == null
                  ? "Choose a Date"
                  : DateFormat('yyyy-MM-dd')
                      .format(controller.selectedDate.value!),
              style: TextStyle(fontSize: 16),
            ),
          )),
    );
  }
}

Widget buildReadOnlyField(String label, TextEditingController controller) {
  print(
      "I AM Vehicle No Value ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ${controller.text}");

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      style: quicksandSemibold.copyWith(
        fontSize: Dimensions.fontSizeFourteen, // Ensure text is not bold
      ),
      controller: controller, //  Use only controller (No initialValue)
      decoration: InputDecoration(
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
      readOnly: true,
    ),
  );
}
