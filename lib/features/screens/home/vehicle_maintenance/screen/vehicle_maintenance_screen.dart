import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tk_logistics/common/widgets/custom_button.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/controller/vehicle_maintenance_controller.dart';

import '../../../../../util/app_color.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';

class VehicleMaintenanceScreen extends StatelessWidget {
  final MaintenanceController controller = Get.put(MaintenanceController());
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
              "Vehicle Maintenance Entry Form",
              style: quicksandBold.copyWith(
                  fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
            )),
        body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeTwenty,
                vertical: Dimensions.paddingSizeTwenty),
            child: SingleChildScrollView(
                child: Form(
                    key: _formKey,
                    child: GetBuilder<MaintenanceController>(
                        initState: (_) {
                          controller
                              .fetchVehicleNumbers();// ✅ Fetch locations when screen opens
                        },
                        builder: (controller) {
                      return Column(
                        children: [
                          buildTextField("Transaction Number",
                              controller.transactionNumber.value,
                              readOnly: true),
                          SizedBox(height: 10),
                          buildSearchableDropdown(
                              "Vehicle Number",
                              controller.vehicleNumbers,
                              controller.selectedVehicle),
                          SizedBox(height: 10),
                          buildDatePicker(context),
                          SizedBox(height: 10),
                          buildTextField("Additional Notes", "",
                              controller: controller.notesController,isLabel: true),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: CustomButton(
                                  width: 120,
                                  onTap: () {
                                    /*if (_formKey.currentState!.validate()) {
                                      if (controller.selectedVehicle.value == null ||
                                          controller.selectedMaintenanceType.value == null ||
                                          controller.selectedWorkshopType.value == null ||
                                          controller.selectedDate.value == null ||
                                          controller.costController.text.isEmpty ||
                                          controller.workshopNameController.text.isEmpty) {
                                        Get.snackbar("Error", "Please fill in all required fields",
                                            snackPosition: SnackPosition.BOTTOM);
                                        return;
                                      }*/
                                      controller.addRecord();
                                  /*  } else {
                                      Get.snackbar("Error", "Please complete the form correctly",
                                          snackPosition: SnackPosition.BOTTOM);
                                    }*/
                                  },
                                  text: 'Submit',
                                ),
                              ),
                             Expanded(child: CustomButton(width:120, text: "TaskType",onTap: _openTaskTypeForm,)),
                              Expanded(
                                child: CustomButton(width:120, onTap: () {}, text: 'Confirm', ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text("Maintenance Records",
                            style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeEighteen,color: AppColor.neviBlue,fontWeight: FontWeight.w800),),
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
                            "Maintenance: ${entry["maintenanceType"]}",style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeSixteen,color: AppColor.neviBlue),),
                            subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                            Text(
                            "Workshop Type: ${entry['workshopType']}",style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.neviBlue),),
                              Obx(() {
                                // Print the current value of selectedWorkshopType
                                print("selectedWorkshopType: ${controller.selectedWorkshopType.value}");
                                print("selectedWorkshopType: ${entry["workshopType"]}");

                                // Check for "3rd Party Workshop" and ensure it's neither null nor empty
                                if (entry["workshopType"]!.isNotEmpty && entry["workshopType"] == "3rd Party Workshop") {
                                  return Text(
                                    "Workshop Name: ${entry["workshopName"]}",
                                    style: quicksandSemibold.copyWith(
                                      fontSize: Dimensions.fontSizeFourteen,
                                      color: AppColor.neviBlue,
                                    ),
                                  );
                                } else {
                                  // Return empty space or SizedBox() when condition is false
                                  return SizedBox();
                                }

                              }),
                              Text(
                            "Cost: \$${entry['cost']}",style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.neviBlue),),
                            ],
                            ),
                            ));
                          }),
                        ],
                      );
                    })))));
  }

  void _openTaskTypeForm() {
    Get.dialog(
      AlertDialog(
        title: Text("Enter Task Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildSearchableDropdown("Maintenance Type", controller.maintenanceTypes,
                controller.selectedMaintenanceType),
            SizedBox(height: 10),
            buildSearchableDropdown("Workshop Type", controller.workshopTypes,
                controller.selectedWorkshopType,),
            SizedBox(height: 10),
            Obx(() {
              return buildTextField(
                "Workshop Name",
                "",
                controller: controller.workshopNameController,
                enabled: controller.selectedWorkshopType.value ==
                    "3rd Party Workshop",);
            } ),
            SizedBox(height: 10),
            buildTextField("Cost", "",
                controller: controller.costController,
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
          ElevatedButton(onPressed: controller.addRecord, child: Text("Save")),
        ],
      ),
    );
  }

  Widget buildSearchableDropdown(String label, List<String> items,
      RxnString selectedValue, {bool required = false}) {
    // This TextEditingController is used to show the selected value.
    TextEditingController controller =
    TextEditingController(text: selectedValue.value ?? "");

    // Listen for changes in selectedValue and update the controller's text accordingly.
    ever(selectedValue, (value) {
      controller.text = value ?? "";
    });

    return TextFormField(
      controller: controller,
      readOnly: true, // Make it read-only so user can only select from the list
      onTap: () => showSearchDialog(label, items, selectedValue),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
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
        suffixIcon: Icon(Icons.arrow_drop_down, color: AppColor.green),
      ),
      validator: required
          ? (value) =>
      (value == null || value.isEmpty) ? "Please select $label" : null
          : null,
    );
  }

  void showSearchDialog(String label, List<String> items,
      RxnString selectedValue) {
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
              Text("Select $label", style: quicksandBold.copyWith(
                  fontSize: Dimensions.fontSizeEighteen,
                  color: AppColor.neviBlue)),
              SizedBox(height: 10),
              // 🔍 Search Field
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: AppColor.neviBlue),
                  hintText: "Search...",
                  hintStyle: quicksandSemibold.copyWith(
                      fontSize: Dimensions.fontSizeSixteen,
                      color: AppColor.neviBlue),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1.5, color: AppColor.green),
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
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
                        selectedValue.value = filteredItems[index]; // Update selectedValue
                        Get.back(); // Close the dialog
                      },
                    );
                  },
                ),
              )),
              TextButton(
                onPressed: () => Get.back(), // Close dialog
                child: Text(
                  "CLOSE",
                  style: quicksandSemibold.copyWith(
                      fontSize: Dimensions.fontSizeSixteen,
                      color: AppColor.primaryRed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildTextField(String label, String initialValue,
      {bool readOnly = false,
        bool isLabel = false,
        TextEditingController? controller,
        TextInputType keyboardType = TextInputType.text,
        bool? enabled}) {  // ✅ Added enabled parameter for dynamic control
    return TextFormField(
      controller: controller ?? TextEditingController(text: initialValue),
      readOnly: readOnly,
      enabled: enabled ?? true, // ✅ Uses enabled value if provided
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: isLabel ? "Can not exceed more than 250 words" : null,
        hintStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
        labelText: label,
        labelStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
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
      ),
      validator: (value) {
        if ((enabled ?? true) && (value == null || value.isEmpty)) {
          return "$label is required";
        }
        return null;
      },
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
              : DateFormat('yyyy-MM-dd').format(controller.selectedDate.value!),
          style: TextStyle(fontSize: 16),
        ),
      )),
    );
  }
}
