import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/util/dimensions.dart';
import 'package:tk_logistics/util/styles.dart';
import '../../../../../common/widgets/custom_button.dart';
import '../../../../../common/widgets/custom_indicator.dart';
import '../../../../../common/widgets/loading_cntroller.dart';
import '../../../../../util/app_color.dart';
import '../controller/update_maintenance_controller.dart';

class UpdateMaintenanceForm extends StatefulWidget {
  final Map<String, dynamic> entry;

  UpdateMaintenanceForm({super.key, required this.entry});

  @override
  State<UpdateMaintenanceForm> createState() => _UpdateMaintenanceFormState();
}

class _UpdateMaintenanceFormState extends State<UpdateMaintenanceForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final loadingController = Get.find<LoadingController>();
  final UpdateMaintenanceController controller =
  Get.put(UpdateMaintenanceController());

  String? maintenanceId;

  @override
  void initState() {
    super.initState();

    // Try to get maintenanceId from the passed widget.entry or from Get.arguments if used
    maintenanceId = widget.entry["xmaintenanceid"]?.toString() ??
        widget.entry["Maintenance No"]?.toString() ??
        Get.arguments?['entry']?['xmaintenanceid']?.toString() ??
        Get.arguments?['entry']?['Maintenance No']?.toString();

    if (maintenanceId != null && maintenanceId!.isNotEmpty) {
      controller.loadMaintenanceDetails(maintenanceId!);
    }

    controller.fetchVehicleNumbers(); // Load vehicles on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      appBar: AppBar(
        title: Text(
          'Update Maintenance Entry',
          style: quicksandBold.copyWith(
              fontSize: Dimensions.fontSizeTwenty, color: AppColor.white),
        ),
        centerTitle: true,
        backgroundColor: AppColor.neviBlue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 22, color: AppColor.white),
          onPressed: () {
            // Pass true (or any signal) back to indicate that refresh is needed
            Get.back(result: true);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeFifteen),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: GetBuilder<UpdateMaintenanceController>(
              builder: (controller) {
                return Column(
                  children: [
                    SizedBox(height: 20),

                    /// VEHICLE NO & DRIVER INFO (Auto-generated)
                    Row(
                      children: [
                        Expanded(
                          child: buildSearchableDropdown(
                            "Vehicle Code",
                            required: true,
                            allowAdd: false,
                            controller.vehicleID,
                            controller.selectedVehicle,
                            onSelected: (selectedValue) {
                              controller.onVehicleSelected(selectedValue);
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: buildReadOnlyField(
                            "Vehicle Regn No.",
                            controller.selectedVehicleNumbers,
                            controller.vehicleNumberController,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: buildReadOnlyField(
                            "Driver Name",
                            controller.selectedDriverName,
                            controller.driverNameController,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: buildReadOnlyField(
                            "Driver's Phone",
                            controller.selectedDriverMobile,
                            controller.driverPhoneController,
                          ),
                        ),
                      ],
                    ),

                    /// DATE & TIME PICKERS
                    buildDateTimeField(
                      "In-Time",
                      controller.inTime,
                      controller: controller.inTimeController,
                      required: true,
                      onPickDateTime: controller.pickDateTime,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: buildDateTimeField(
                            "Est. Out-Time",
                            controller.estOutTime,
                            controller: controller.estOutTimeController,
                            required: true,
                            onPickDateTime: controller.pickDateTime,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: buildDateTimeField(
                            "Actual Out-Time",
                            controller.actOutTime,
                            controller: controller.actOutTimeController,
                            required: false,
                            onPickDateTime: controller.pickDateTime,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    /// Workshop Type & Name
                    Row(
                      children: [
                        Expanded(
                          child: buildSearchableDropdown(
                            "Workshop Type",
                            controller.workshopTypes,
                            controller.selectedWorkshopType,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Obx(() {
                            if (controller.selectedWorkshopType.value == "3rd Party Workshop") {
                              return buildSearchableDropdown(
                                "Workshop Name",
                                controller.workshopNameList,
                                controller.selectedWorkshopName,
                              );
                            } else {
                              // Default: T.K. Central Workshop (read-only)
                              controller.workshopNameController.value = "T.K. Central Workshop";
                              return buildTextField(
                                "Workshop Name",
                                "",
                                readOnly: true,
                                controller: TextEditingController(text: "T.K. Central Workshop"),
                                style: quicksandSemibold.copyWith(color: AppColor.grey2),
                              );
                            }
                          }),
                        ),

                      ],
                    ),

                    SizedBox(height: 12),

                    buildTextField(
                      "Total Cost",
                      "",
                      controller: controller.costController,
                      keyboardType: TextInputType.number,
                    ),

                    SizedBox(height: 30),

                    Obx(() {
                      if (loadingController.isSubmitting.value) {
                        return spinkit; // Your loading indicator widget
                      } else {
                        return CustomButton(
                          width: 120,
                          onTap: () async {
                            if (maintenanceId == null || maintenanceId!.isEmpty) {
                              Get.snackbar("Error", "Maintenance ID is missing");
                              return;
                            }

                            if (!_formKey.currentState!.validate()) {
                              Get.snackbar("Error", "Please fill all required fields");
                              return;
                            }

                            await loadingController.runWithLoader(
                              loader: loadingController.isSubmitting,
                              action: () async {
                                bool success = await controller.updateMaintenance(maintenanceId!);
                                if (success) {
                                  // Refresh the updated maintenance details or list
                                  await controller.loadMaintenanceDetails(maintenanceId!);

                                  // If you have a parent list controller, you might want to refresh that as well:
                                  // For example:
                                  // Get.find<EntryListController>().filterEntries();

                                  // Then navigate back (or update UI)
                                  Get.back();
                                } else {
                                  Get.snackbar("Error", "Failed to update maintenance");
                                }
                                await Future.delayed(Duration(milliseconds: 800));
                              },
                            );
                          },
                          text: 'Update',
                        );
                      }
                    }),

                    SizedBox(height: 30),

                    Obx(() {
                      if (controller.records.isEmpty) {
                        return Center(child: Text("No records found."));
                      }
                      return SingleChildScrollView(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1, color: AppColor.neviBlue),
                          ),
                          child: DataTable(
                            columnSpacing: 22,
                            headingRowColor: MaterialStateColor.resolveWith(
                                    (states) => AppColor.neviBlue),
                            columns: [
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    "Date",
                                    style: quicksandBold.copyWith(
                                      fontSize: Dimensions.fontSizeFourteen,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    "Vehicle Code",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: quicksandBold.copyWith(
                                      fontSize: Dimensions.fontSizeFourteen,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    "Workshop Type",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: quicksandBold.copyWith(
                                      fontSize: Dimensions.fontSizeFourteen,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    "Cost",textAlign: TextAlign.right,
                                    style: quicksandBold.copyWith(
                                      fontSize: Dimensions.fontSizeFourteen,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            rows: controller.records.map((record) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      record["maintenanceDate"] ?? "",
                                      style: quicksandRegular.copyWith(
                                          fontSize: Dimensions.fontSizeFourteen),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      record["vehicleNumber"] ?? "",
                                      style: quicksandRegular.copyWith(
                                          fontSize: Dimensions.fontSizeFourteen),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      record["workshopType"] ?? "",
                                      textAlign: TextAlign.center,
                                      style: quicksandRegular.copyWith(
                                          fontSize: Dimensions.fontSizeFourteen),
                                    ),
                                  ),
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        record["cost"] ?? "",
                                        style: quicksandRegular.copyWith(
                                            fontSize: Dimensions.fontSizeFourteen),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}


Widget buildDateTimeField(
  String label,
  Rx<DateTime?> date, {
  required TextEditingController controller,
  required Future<void> Function(Rx<DateTime?>) onPickDateTime, // 👈 Add this
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
              : AppColor.green;

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
          await onPickDateTime(date); // ✅ fixed here
        },
      );
    }),
  );
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
        errorStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeTen),
        labelText: label,
        labelStyle: quicksandRegular.copyWith(
          fontSize: Dimensions.fontSizeFourteen,
          color: (required &&
                  (selectedValue.value == null || selectedValue.value!.isEmpty))
              ? AppColor.primaryRed
              : AppColor.black, // or any color you want for filled state
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.5,
            color: (required &&
                    (selectedValue.value == null ||
                        selectedValue.value!.isEmpty))
                ? AppColor.primaryRed
                : AppColor.neviBlue,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.5,
            color: (required &&
                    (selectedValue.value == null ||
                        selectedValue.value!.isEmpty))
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
        suffixIcon:
            Icon(Icons.arrow_drop_down, color: AppColor.green), // Dropdown icon
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

            CustomButton(onTap: () => Get.back(), text: "OK", width: 80),
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
        style: quicksandSemibold.copyWith(
          fontSize: Dimensions.fontSizeFourteen, // Ensure text is not bold
        ),
      );
    }),
  );
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
