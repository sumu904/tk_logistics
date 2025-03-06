import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tk_logistics/common/widgets/custom_button.dart';
import 'package:tk_logistics/common/widgets/custom_outlined_button.dart';

import '../../../../../util/app_color.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';
import '../controller/diesel_entry_controller.dart';

class DieselEntryScreen extends StatelessWidget {
  final DieselEntryController controller = Get.put(DieselEntryController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
            "Diesel Entry Form",
            style: quicksandBold.copyWith(
                fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
          )),
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeTwenty,vertical: Dimensions.paddingSizeTwenty),
        child: SingleChildScrollView(
            child: Form(
                key: _formKey,
              child: GetBuilder<DieselEntryController>(
                  initState: (_) {
                    controller
                        .fetchVehicleNumbers();// ✅ Fetch locations when screen opens
                  },
                  builder: (controller) {
                    return Column(
                      children: [
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
                        Obx(() {
                          print("Driver Name: ${controller.selectedDriverName.value}");
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            controller.driverNameController.text = controller.selectedDriverName.value;
                          });

                          return buildReadOnlyField('Driver Name', controller.driverNameController);
                        }),
                        SizedBox(height: 10),
                        buildDatePicker(context),
                        SizedBox(height: 10),
                        buildDieselAmountField("Diesel Amount (Ltr)",
                            controller.dieselAmountController,
                            TextInputType.number),
                        buildTextField(
                            "Pump Name", controller.pumpNameController,
                            TextInputType.text),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(child: CustomButton(
                              onTap: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  print("Form validated successfully!");
                                  controller.addEntry(); // ✅ Proceed with submission if valid
                                } else {
                                  print("Validation failed! Please check inputs.");
                                }
                              },
                              text: 'Submit',)),
                            SizedBox(width: 10,),
                            Expanded(child: CustomOutlinedButton(
                              onTap: () {}, text: 'Confirm',)),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text("Diesel Entry List", style: quicksandBold.copyWith(
                            fontSize: Dimensions.fontSizeEighteen,
                            fontWeight: FontWeight.w800,
                            color: AppColor.neviBlue)),
                        SizedBox(height: 10,),
                        Obx(() {
                          if (controller.latestEntry.value == null) {
                            return Text(
                              "No entries yet.",
                              style: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeSixteen, color: AppColor.neviBlue),
                            );
                          }

                          var entry = controller.latestEntry.value!;

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text(
                                "Vehicle ID: ${entry['vehicle']}",
                                style: quicksandSemibold.copyWith(
                                    fontSize: Dimensions.fontSizeSixteen,
                                    color: AppColor.neviBlue),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Vehicle Number: ${entry['vehicleNumbers']}",
                                    style: quicksandSemibold.copyWith(
                                        fontSize: Dimensions.fontSizeFourteen,
                                        color: AppColor.neviBlue),
                                  ),
                                  Text(
                                    "Driver: ${entry['driver']}",
                                    style: quicksandSemibold.copyWith(
                                        fontSize: Dimensions.fontSizeFourteen,
                                        color: AppColor.neviBlue),
                                  ),
                                  Text(
                                    "Date: ${entry['date']}",
                                    style: quicksandSemibold.copyWith(
                                        fontSize: Dimensions.fontSizeFourteen,
                                        color: AppColor.neviBlue),
                                  ),
                                  Text(
                                    "Diesel: ${entry['diesel']} Ltr",
                                    style: quicksandSemibold.copyWith(
                                        fontSize: Dimensions.fontSizeFourteen,
                                        color: AppColor.neviBlue),
                                  ),
                                  Text(
                                    "Pump: ${entry['pump']}",
                                    style: quicksandSemibold.copyWith(
                                        fontSize: Dimensions.fontSizeFourteen,
                                        color: AppColor.neviBlue),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }),
            ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, TextInputType keyboardType,
      {bool required = false, bool isNumeric = false, bool isLabel = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeEight),
      child: TextFormField(
        maxLines: isLabel ? 2 : null,
        decoration: InputDecoration(
          hintText: isLabel ? "Can not exceed more than 250 words" : null,
          hintStyle: quicksandRegular.copyWith(fontSize: Dimensions
              .fontSizeFourteen),
          labelStyle: quicksandRegular.copyWith(fontSize: Dimensions
              .fontSizeFourteen),
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
            final controller = Get.find<DieselEntryController>();  // Get the controller instance
            controller.onVehicleSelected(selectedVehicle);
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

  Widget buildDieselAmountField(String label, TextEditingController controller, TextInputType keyboardType) {
    return TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
                borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1.5, color: AppColor.green),
                borderRadius: BorderRadius.circular(12)),
          ));
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
              : DateFormat('yyyy-MM-dd').format(controller.selectedDate.value!),
          style: TextStyle(fontSize: 16),
        ),
      )),
    );
  }
}

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
