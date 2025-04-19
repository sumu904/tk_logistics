import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/common/widgets/custom_button.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/controller/main_form_controller.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/controller/task_info_controller.dart';
import 'package:tk_logistics/util/app_color.dart';

import '../../../../../common/widgets/custom_outlined_button.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';

// Main Maintenance Screen
class TaskInfoScreen extends StatelessWidget {
  final controller = Get.put(TaskInfoController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isAddEntryTapped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      body: Form(
        key: _formKey, //  Wrap in Form widget
        child: GetBuilder<TaskInfoController>(
          initState: (_) {},
          builder: (controller) {
            return ListView(
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => buildSearchableDropdown(
                            "Maintenance Type",
                            controller.maintenanceTypes,
                            controller.selectedMaintenanceType,
                          )),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Obx(() => buildSearchableDropdown("Sub Type",
                          controller.subTypes, controller.selectedSubType)),
                    ),
                  ],
                ),
                SizedBox(height: 15),
            buildTextField(
            "Remarks",
            controller: controller.remarksController,
            isLabel: true
            ),
            SizedBox(height: 15),
                // Show additional fields when "Tyre Change" is selected
                Obx(() => controller.isTyreChange.value
                    ? tyreChangeFields()
                    : SizedBox.shrink()),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      width: 120,
                      onTap: () {
                        if (!isAddEntryTapped) {
                          isAddEntryTapped = true;
                          controller.addEntry(); //  Just add to the table
                          Future.delayed(Duration(milliseconds: 300), () {
                            isAddEntryTapped = false;
                          });
                        }
                      },
                      text: 'Submit',
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CustomOutlinedButton(
                      width: 120,
                      onTap: () async {
                        final taskController = Get.find<TaskInfoController>();

                        if (taskController.entries.isEmpty) {
                          Get.snackbar(
                            "Warning",
                            "Task info form is required before completing.",
                            snackPosition: SnackPosition.TOP,
                            colorText: AppColor.white,
                            backgroundColor: AppColor.primaryRed,
                          );
                        } else {
                          await taskController.submitMaintenanceData(); //  Only submit now
                        }
                      },
                      text: "Complete",
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Obx(() => controller.entries.isEmpty
                    ? Center(child: Text("No records found."))
                    : SingleChildScrollView(
                        //scrollDirection: Axis.horizontal,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  width: 1, color: AppColor.neviBlue)),
                          child: DataTable(
                            columnSpacing: 22,
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) => AppColor.neviBlue),
                            columns: [
                              DataColumn(
                                  label: Expanded(
                                      child: Text("Maintenance Type",
                                          style: quicksandBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeFourteen,
                                              color: AppColor.white)))),
                              DataColumn(
                                  label: Expanded(
                                      child: Text("Remarks",
                                          style: quicksandBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeFourteen,
                                              color: AppColor.white)))),
                              DataColumn(
                                  label: Expanded(
                                      child: Text("Reason",
                                          textAlign: TextAlign.center,
                                          style: quicksandBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeFourteen,
                                              color: AppColor.white)))),
                            ],
                            rows: controller.entries.map((entry) {
                              return DataRow(cells: [
                                DataCell(Text(entry["Maintenance Type"] ?? "",
                                    style: quicksandRegular.copyWith(
                                        fontSize:
                                            Dimensions.fontSizeFourteen))),
                                DataCell(Text(entry["Remarks"] ?? "",
                                    style: quicksandRegular.copyWith(
                                        fontSize:
                                            Dimensions.fontSizeFourteen))),
                                DataCell(Text(entry["Reason"] ?? "",
                                    textAlign: TextAlign.center,
                                    style: quicksandRegular.copyWith(
                                        fontSize:
                                            Dimensions.fontSizeFourteen))),
                              ]);
                            }).toList(),
                          ),
                        ),
                      )),
              ],
            );
          },
        ),
      ),
    );
  }

  // Tyre Change Fields
  Widget tyreChangeFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: buildSearchableDropdown("Tyre Change Reason",
                  ['Brust / Damage', 'Worn Out'], controller.tyreChangeReason),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
                child:buildTextField(
                    "Old Tyre S/N",
                    controller: controller.oldTyreSNController, // Adjust this accordingly
                    isLabel: false
                )
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: buildSearchableDropdown("New Tyre Condition",
                  ['Brand New', 'Used'], controller.newTyreCondition),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
                child: buildTextField("New Tyre S/N",controller: controller.newTyreSNController,isLabel: false)),
          ],
        ),
      ],
    );
  }

  // Reusable TextField
  Widget buildTextField(
      String label, {
        bool readOnly = false,
        bool isLabel = false,
        TextEditingController? controller,
        TextStyle? style,
        TextInputType keyboardType = TextInputType.text,
        bool enabled = true,
      }) {
    // Create a local controller only if not provided
    final textController = controller ?? TextEditingController();

    return TextFormField(
      style: readOnly ? style : TextStyle(),
      controller: textController,
      readOnly: readOnly,
      enabled: enabled,
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
      validator: (input) {
        if (enabled && (input == null || input.isEmpty)) {
          return "$label is required";
        }
        return null;
      },
      onChanged: (input) {
        // Update the controller's text if needed
        controller?.text = input;
      },
    );
  }


  // Reusable Searchable Dropdown widget
  Widget buildSearchableDropdown(
      String label, List<String> items, RxnString selectedValue,
      {bool required = false,
      Function(String)? onSelected,
      bool allowAdd = false}) {
    // Create a TextEditingController and sync it with the RxnString value
    TextEditingController controller = TextEditingController();
    controller.text = selectedValue.value ??
        ""; // Sync the selected value with the controller

    return TextFormField(
      controller: controller,
      readOnly: true,
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
            color: required ? AppColor.primaryRed : AppColor.black),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
            borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: 1.5,
                color: required ? AppColor.primaryRed : AppColor.green),
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
    );
  }

// Show Search Dialog
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
                  isNewItem.value = allowAdd &&
                      query.isNotEmpty &&
                      !items.contains(query.trim());
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
}