import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tk_logistics/common/widgets/custom_outlined_button.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/screen/task_info_screen.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/screen/vehicle_maintenance_screen.dart';

import '../../../../../common/widgets/custom_button.dart';
import '../../../../../common/widgets/custom_indicator.dart';
import '../../../../../common/widgets/loading_cntroller.dart';
import '../../../../../util/app_color.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';
import '../controller/main_form_controller.dart';
import '../controller/task_info_controller.dart';

class MainFormScreen extends StatelessWidget {
  final VoidCallback? onSuccess;

  MainFormScreen({this.onSuccess, super.key});
  final MainFormController controller = Get.put(MainFormController());
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
      controller.pickDate(picked); // Ensure only date is stored
    }
  }

  onMainFormSubmit() async {
    final controller = Get.find<MainFormController>();
    final taskController = Get.find<TaskInfoController>();

    // Collect data
    final mainFormData = await controller.collectMainFormDataLocally();
    print("Collected main form data: $mainFormData");



   /* controller.validateMainForm.add(mainFormData.remove('Maintenance_details')); // Add main form data to entries list
    print("Entries after adding data: ${controller.validateMainForm}");*/

    // Now pass data to TaskInfoController
    taskController.maintenanceData.value = mainFormData;
    taskController.selectedVehicle.value = mainFormData['vehicle_code'];
    taskController.vehicleNumberController.text = mainFormData['vehicle_number'];
    taskController.driverNameController.text = mainFormData['driver_name'];
    taskController.driverPhoneController.text = mainFormData['driver_phone'];
    taskController.selectedWorkshopType.value = mainFormData['workshop_type'];
    taskController.workshopNameController.text = mainFormData['workshop_name'];
    taskController.costController.text = mainFormData['total_cost'];
    taskController.selectedDate.value = DateFormat('yyyy-MM-dd').parse(mainFormData['xdate']);
    taskController.maintenanceID.value = "TEMP-${DateTime.now().millisecondsSinceEpoch}";

    if (onSuccess != null) {
      onSuccess!();  // You can navigate or update the UI as needed
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.mintGreenBG,
        body: SingleChildScrollView(
            child: Form(
                key: _formKey, //  Wrap in Form widget
                child: GetBuilder<MainFormController>(initState: (_) {
                  controller.fetchVehicleNumbers();
                }, builder: (controller) {
                  return Column(children: [
                    SizedBox(
                      height: 20,
                    ),

                    /// VEHICLE NO & DRIVER INFO (Auto-generated)
                    Row(children: [
                      Expanded(
                        child: buildSearchableDropdown(
                          "Vehicle Code",
                          required: true,
                          allowAdd: false,
                          controller.vehicleID,
                          controller.selectedVehicle,
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
                          child: buildReadOnlyField(
                              "Vehicle Number",
                              controller.selectedVehicleNumbers,
                              controller.vehicleNumberController)),
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
                    SizedBox(
                      height: 5,
                    ),

                    /// DATE (Auto-generated)
                    InkWell(
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
                            Obx(() => Text(
                                  controller.selectedDate.value == null
                                      ? "Pick a date to view trips"
                                      : DateFormat('yyyy-MM-dd').format(
                                          controller.selectedDate.value!),
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
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: buildSearchableDropdown(
                            "Workshop Type",
                            controller.workshopTypes,
                            controller.selectedWorkshopType,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Obx(() {
                            return buildTextField(
                              "Workshop Name",
                              "", // Keep the value of the text field empty
                              readOnly: controller.selectedWorkshopType.value !=
                                  "3rd Party Workshop",
                              // Read-only if not 3rd Party Workshop
                              controller: controller
                                          .selectedWorkshopType.value !=
                                      "3rd Party Workshop"
                                  ? TextEditingController(
                                      text:
                                          "T.K. Central") // Set default placeholder value
                                  : controller.workshopNameController,
                              // Use the actual controller for 3rd Party Workshop
                              style: quicksandSemibold.copyWith(
                                color: controller.selectedWorkshopType.value !=
                                        "3rd Party Workshop"
                                    ? AppColor
                                        .grey2 // Text color set to gray 2 for read-only
                                    : AppColor
                                        .green, // Default color for editable text
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    buildTextField("Total Cost", "",
                        controller: controller.costController,
                        keyboardType: TextInputType.number),
                    SizedBox(
                      height: 30,
                    ),
                    Obx(() => loadingController.isSubmitting.value
                        ? spinkit // Show loader while submission is in progress
                        : CustomButton(
                      width: 120,
                      onTap: () {
                        loadingController.runWithLoader(
                          loader: loadingController.isSubmitting,
                          action: () async {
                            // Register TaskInfoController if not already registered
                            if (!Get.isRegistered<TaskInfoController>()) {
                              Get.put(TaskInfoController());
                            }

                            // Proceed with the main form submission
                            await onMainFormSubmit();
                            await Future.delayed(Duration(milliseconds: 800));
                          },
                        );
                      },
                      text: 'Submit',
                    ),
                    ),

                    SizedBox(height: 30,),
                    Obx(() => controller.records.isEmpty
                        ? Center(child: Text("No records found."))
                        : SingleChildScrollView(
                      //scrollDirection: Axis.horizontal,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1,color: AppColor.neviBlue)
                        ),
                        child: DataTable(
                          columnSpacing: 22,
                          headingRowColor:
                          MaterialStateColor.resolveWith((states) => AppColor.neviBlue),
                          columns: [
                            DataColumn(label: Expanded(child: Text("Vehicle No.",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.white)))),
                            DataColumn(label: Expanded(child: Text("Date",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.white)))),
                            DataColumn(label: Expanded(child: Text("Workshop Type",textAlign: TextAlign.center,style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.white)))),
                            DataColumn(label: Expanded(child: Text("Cost",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.white)))),
                          ],
                          rows: controller.records.map((record) {
                            return DataRow(cells: [
                              DataCell(Text(record["maintenanceDate"] ?? "",style: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen))),
                              DataCell(Text(record["vehicleNumber"] ?? "",style: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen))),
                              DataCell(Text(record["workshopType"] ?? "",textAlign: TextAlign.center,style: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen))),
                              DataCell(Text(record["cost"] ?? "",style: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen))),
                            ]);
                          }).toList(),
                        ),
                      ),
                    )),

                  ]);
                }))));
  }

  Widget buildSearchableDropdown(
      String label, List<String> items, RxnString selectedValue,
      {bool required = false,
      String? defaultValue,
      Function(String)? onSelected,
      bool allowAdd = false}) {
    // allowAdd default to false
    return Obx(() {
      if (selectedValue.value == null && defaultValue != null) {
        selectedValue.value = defaultValue;
      }

      TextEditingController controller =
          TextEditingController(text: selectedValue.value ?? "");

      return TextFormField(
        controller: controller,
        readOnly: true,
        style: quicksandSemibold.copyWith(
          fontSize: Dimensions.fontSizeFourteen, // Ensure text is not bold
        ),
        // Prevent manual typing
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
          errorStyle:
              quicksandRegular.copyWith(fontSize: Dimensions.fontSizeTen),
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
          suffixIcon: Icon(Icons.arrow_drop_down,
              color: AppColor.green), // Dropdown icon
        ),
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required'; // Error message when the field is empty
                }
                return null; // No error
              }
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

              //  Search Field
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
                  isNewItem.value = allowAdd &&
                      query.isNotEmpty &&
                      !items.contains(query.trim());
                },
              ),
              SizedBox(height: 10),

              //  Search Result List
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
                      label: Text(
                        "Add",
                        style: quicksandBold.copyWith(
                            fontSize: Dimensions.fontSizeFourteen,
                            color: AppColor.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.neviBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  : SizedBox()),

              SizedBox(
                height: 10,
              ),

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

  Widget buildReadOnlyField(
      String label, RxString value, TextEditingController controller) {
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
}

Widget buildTextField(String label, String initialValue,
    {bool readOnly = false,
    bool isLabel = false,
    TextEditingController? controller,
    TextStyle? style,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true}) {
  //  Added enabled parameter for dynamic control
  return TextFormField(
    style: readOnly ? style : TextStyle(),
    controller: controller ?? TextEditingController(text: initialValue),
    readOnly: readOnly,
    enabled: enabled ?? true,
    //  Uses enabled value if provided
    keyboardType: keyboardType,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeTwelve,
          horizontal: Dimensions.paddingSizeTwelve),
      hintText: isLabel ? "Can not exceed more than 250 words" : null,
      hintStyle:
          quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
      labelText: label,
      labelStyle:
          quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
      focusedBorder: readOnly
          ? OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.grey2),
              borderRadius: BorderRadius.circular(12))
          : OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
              borderRadius: BorderRadius.circular(12)),
      enabledBorder: readOnly
          ? OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.grey2),
              borderRadius: BorderRadius.circular(12))
          : OutlineInputBorder(
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
