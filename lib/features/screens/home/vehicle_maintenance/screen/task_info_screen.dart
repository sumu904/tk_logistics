import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/common/widgets/custom_button.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/controller/main_form_controller.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/controller/task_info_controller.dart';
import 'package:tk_logistics/util/app_color.dart';

import '../../../../../common/widgets/custom_indicator.dart';
import '../../../../../common/widgets/custom_outlined_button.dart';
import '../../../../../common/widgets/loading_cntroller.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';

// Main Maintenance Screen
class TaskInfoScreen extends StatelessWidget {
  final controller = Get.put(TaskInfoController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final loadingController = Get.find<LoadingController>();
  bool isAddEntryTapped = false;


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      body: Form(
        key: _formKey,
        child: GetBuilder<TaskInfoController>(
          builder: (controller) {
            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                SizedBox(height: 20),
                Obx(() {
                  return buildSearchableDropdown(
                    "Maintenance Type",
                    controller.maintenanceTypes,
                    controller.selectedMaintenanceType,
                  );
                }),
                SizedBox(height: 10),
                /*Expanded(
                  child: Obx(() {
                    return buildSearchableDropdown(
                      "Sub Type",
                      allowAdd: true,
                      controller.subTypes,
                      controller.selectedSubType,
                    );
                  }),
                ),*/
                // In your Obx widget (where you show the multi-select dropdown)
                Obx(() {
                  return buildMultiSelectDropdown(
                    "Sub Type",
                    controller.subTypes,
                    controller.selectedSubType,
                    required: false,
                    onSelected: (selectedItems) {
                      print("Selected sub types: $selectedItems");
                    },
                    allowAdd: true,
                  );
                }),
                SizedBox(height: 10),

                buildTextField(
                  "Remarks",
                  controller: controller.remarksController,
                  isLabel: true,
                ),

                SizedBox(height: 15),

                // Tyre Change section
                Obx(() => controller.isTyreReplacement.value
                    ? tyreChangeFields()
                    : SizedBox.shrink()),

                SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() => loadingController.isLoading.value
                        ? spinkit
                        : CustomButton(
                      width: 120,
                      onTap: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (controller.modifiedFormData.isEmpty) {
                            Get.snackbar(
                              "Warning",
                              "Main form is required before submitting.",
                              snackPosition: SnackPosition.TOP,
                              colorText: AppColor.white,
                              backgroundColor: AppColor.primaryRed,
                            );
                            return;
                          }

                          if (!isAddEntryTapped) {
                            isAddEntryTapped = true;
                            await loadingController.runWithLoader(
                              loader: loadingController.isLoading,
                              action: () async {
                                await controller.addEntry();
                              },
                            ).then((_) {
                              Future.delayed(Duration(milliseconds: 500), () {
                                isAddEntryTapped = false;
                              });
                            });
                          }
                        } else {
                          Get.snackbar(
                            "Warning",
                            "Please fill all required fields correctly.",
                            snackPosition: SnackPosition.TOP,
                            colorText: AppColor.white,
                            backgroundColor: AppColor.primaryRed,
                          );
                        }
                      },
                      text: 'Submit',
                    ),
                    ),
                    SizedBox(width: 10),
                    Obx(() => loadingController.isCompleting.value
                        ? spinkit
                        : CustomOutlinedButton(
                      width: 120,
                      onTap: () async {
                        if (controller.entries.isEmpty) {
                          Get.snackbar(
                            "Warning",
                            "Task info form is required before completing.",
                            snackPosition: SnackPosition.TOP,
                            colorText: AppColor.white,
                            backgroundColor: AppColor.primaryRed,
                          );
                        } else {
                          // Show the confirmation dialog
                          Get.dialog(
                            AlertDialog(
                              backgroundColor: AppColor.mintGreenBG,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), // Change this to adjust the roundness
                              ),
                              title: Text("Confirm",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeTwenty,color: AppColor.neviBlue),),
                              content: Text("Are you sure you want to complete this task?",style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeSixteen),),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Get.back(); // Close the dialog
                                  },
                                  child: Text("No",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.primaryRed),),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Get.back(); // Close the dialog
                                    await loadingController.runWithLoader(
                                      loader: loadingController.isCompleting,
                                      action: () async {
                                        await controller.submitMaintenanceData();
                                        await Future.delayed(Duration(milliseconds: 500));
                                      },
                                    );
                                  },
                                  child: Text("Yes",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.persianGreen),),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      text: "Complete",
                    ),
                    )
                  ],
                ),

                SizedBox(height: 30),

                Obx(() => controller.entries.isEmpty
                    ? Center(child: Text("No records found."))
                    : SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 1, color: AppColor.neviBlue),
                    ),
                    child: DataTable(
                      columnSpacing: 22,
                      headingRowColor: MaterialStateColor.resolveWith(
                            (states) => AppColor.neviBlue,
                      ),
                      columns: [
                        DataColumn(
                          label: Expanded(
                            child: Text("Maintenance Type",overflow: TextOverflow.ellipsis,maxLines: 2,textAlign: TextAlign.center,
                                style: quicksandBold.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen,
                                  color: AppColor.white,
                                )),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text("Remarks",
                                style: quicksandBold.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen,
                                  color: AppColor.white,
                                )),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text("Reason",
                                style: quicksandBold.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen,
                                  color: AppColor.white,
                                )),
                          ),
                        ),
                      ],
                      rows: controller.entries.map((entry) {
                        return DataRow(cells: [
                          DataCell(Text(entry["Maintenance Type"] ?? "",
                              style: quicksandRegular.copyWith(
                                fontSize: Dimensions.fontSizeFourteen,
                              ))),
                          DataCell(Text(entry["Remarks"] ?? "",
                              style: quicksandRegular.copyWith(
                                fontSize: Dimensions.fontSizeFourteen,
                              ))),
                          DataCell(Text(entry["Reason"] ?? "",
                              style: quicksandRegular.copyWith(
                                fontSize: Dimensions.fontSizeFourteen,
                              ))),
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
                controller.tyreChangeTypes,  // Use the fetched list here
                controller.tyreChangeReason,),
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
                 controller.tyreConditionTypes, controller.newTyreCondition),
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
}

Widget buildMultiSelectDropdown(
    String label,
    RxList<String> items,
    RxList<String> selectedValues, {
      bool required = false,
      Function(List<String>)? onSelected,
      bool allowAdd = false,
    }) {
  final controller = TextEditingController();

  // update controller initially
  controller.text =
  selectedValues.isNotEmpty ? selectedValues.join(", ") : "";

  return Obx(() {
    controller.text = selectedValues.join(", "); // update value when list changes

    return TextFormField(
      minLines: 1,
      maxLines: null,
      controller: controller,
      readOnly: true,
      style: quicksandSemibold.copyWith(
        fontSize: Dimensions.fontSizeFourteen,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        showMultiSelectDialog(
          label,
          items,
          selectedValues,
          controller,
          onSelected,
          allowAdd,
        );
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: quicksandRegular.copyWith(
          fontSize: Dimensions.fontSizeFourteen,
        ),
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
          vertical: Dimensions.paddingSizeFourteen,
        ),
        suffixIcon: Icon(Icons.arrow_drop_down, color: AppColor.green),
      ),
      validator: required
          ? (value) =>
      (value == null || value.isEmpty)
          ? "Please select $label"
          : null
          : null,
    );
  });
}



void showMultiSelectDialog(String label,
    RxList<String> items, // Available items
    RxList<String> selectedValues, // Selected values
    TextEditingController controller,
    Function(List<String>)? onSelected,
    bool allowAdd) {
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
                  borderSide: BorderSide(
                      width: 1.5, color: AppColor.neviBlue),
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
                  if (!items.contains(newItem)) {
                    items.add(newItem);
                  }
                  if (!selectedValues.contains(newItem)) {
                    selectedValues.add(newItem);
                  }

                  if (onSelected != null) {
                    onSelected(selectedValues);
                  }

                  controller.text = selectedValues.join(", ");
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