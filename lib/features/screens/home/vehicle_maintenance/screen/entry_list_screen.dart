import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/controller/entry_list_controller.dart';

import '../../../../../common/widgets/custom_button.dart';
import '../../../../../common/widgets/custom_indicator.dart';
import '../../../../../common/widgets/loading_cntroller.dart';
import '../../../../../util/app_color.dart';
import '../../../../../util/date_utils.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';

class EntryListScreen extends StatelessWidget {
  final controller = Get.put(EntryListController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final loadingController = Get.find<LoadingController>();

  // Date format
  final dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.mintGreenBG,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: GetBuilder<EntryListController>(initState: (_) {
            }, builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  // Date Range Fields
                  Row(
                    children: [
                      Expanded(
                        child: buildDateField("From Date", controller.selectedFromDate, controller.fromDateController, isFromDate: true),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: buildDateField("To Date", controller.selectedToDate, controller.toDateController),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Vehicle Selection Dropdown
                  buildSearchableDropdown(
                    "Select Vehicle",
                    controller.vehicleID,
                    controller.selectedVehicle,
                  ),
                  SizedBox(height: 20),

                  // Submit Button
                  Center(
                    child: Obx(() => loadingController.isSubmitting.value
                        ? spinkit
                        : CustomButton(
                      onTap: () {
                        loadingController.runWithLoader(
                          loader: loadingController.isSubmitting,
                          action: () async {
                            controller.filterEntries();
                            await Future.delayed(Duration(milliseconds: 500));
                          },
                        );
                      },
                      text: "Submit",
                    ),
                    )

                  ),

                  SizedBox(height: 20),

                  // Table of Entries
                  Obx(() => buildEntriesTable(controller.filteredEntries)),
                ],
              );
            }),
          ),
        ));
  }

  Widget buildDateField(String label, Rx<DateTime> selectedDate, TextEditingController controller, {bool isFromDate = false}) {
    return TextFormField(
      style: quicksandSemibold.copyWith(
          fontSize: Dimensions.fontSizeFourteen,
          color:AppColor.black),
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: quicksandRegular.copyWith(
            fontSize: Dimensions.fontSizeFourteen,
            color:AppColor.black),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
            borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: 1.5,
                color:  AppColor.green),
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
        suffixIcon: Icon(Icons.calendar_today, color: AppColor.green),
      ),
      onTap: () async {
        DateTime now = DateTime.now();
        DateTime? pickedDate = await showDatePicker(
          context: Get.context!,
          initialDate: selectedDate.value,
          firstDate: DateTime(2000),
          lastDate: isFromDate ? now : DateTime(2100),
        );

        if (pickedDate != null) {
          selectedDate.value = pickedDate;
          controller.text = formatDate(pickedDate);
        }
      },
    );
  }

  // Reusable Searchable Dropdown
  Widget buildSearchableDropdown(
      String label, List<String> items, RxnString selectedValue,
      {bool required = false,
      Function(String)? onSelected,
      bool allowAdd = false}) {
    // Create a TextEditingController for the TextField
    TextEditingController controller = this.controller.vehicleController;

    // Ensure that the TextEditingController always displays the current selected value
    controller.text = selectedValue.value ?? "";

    return Obx(() {
      // Update controller text when selectedValue changes
      if (selectedValue.value != null &&
          controller.text != selectedValue.value) {
        controller.text = selectedValue.value!;
      }

      return TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          // Open search dialog when the TextFormField is tapped
          String? selectedItem = await showSearchDialog(
              label, items, selectedValue, controller,
              allowAdd: false);
          if (selectedItem != null) {
            selectedValue.value = selectedItem; // Update selected value
          }
        },
        decoration: InputDecoration(
          errorText: null,
          errorStyle:
              quicksandRegular.copyWith(fontSize: Dimensions.fontSizeTen),
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
          suffixIcon: Icon(Icons.arrow_drop_down,
              color: AppColor.green), // Dropdown icon
        ),
      );
    });
  }

  // Show Search Dialog
  Future<String?> showSearchDialog(String label, List<String> items,
      RxnString selectedValue, TextEditingController controller,
      {bool allowAdd = false}) {
    TextEditingController searchController = TextEditingController();
    RxList<String> filteredItems = items.obs;
    RxBool isNewItem = false.obs;

    return showDialog<String>(
      context: Get.context!,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        borderSide:
                            BorderSide(width: 1.5, color: AppColor.green),
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
                                    Get.back();
                                  },
                                );
                              },
                            )
                          : Center(
                              child: Text("No matches found",
                                  style: quicksandBold.copyWith(
                                      fontSize: Dimensions.fontSizeSixteen))),
                    )),

                SizedBox(height: 10),

                // Close Button
                CustomButton(
                    onTap: () => Get.back(),
                    text: "OK",
                    width: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  // Table to display the filtered entries
  Widget buildEntriesTable(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) {
      return Center(child: Text("No Entries found for the selected criteria."));
    }

    // Calculate total cost
    double totalCost = 0;
    for (var entry in entries) {
      final cost = double.tryParse(entry["Cost"] ?? "0") ?? 0;
      totalCost += cost;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(width: 1, color: AppColor.neviBlue),
      ),
      child: DataTable(
        columnSpacing: 10,
        headingRowColor:
        MaterialStateColor.resolveWith((states) => AppColor.neviBlue),
        columns: [
          DataColumn(
              label: Expanded(
                  child: Text("Date",
                      style: quicksandBold.copyWith(
                          fontSize: Dimensions.fontSizeFourteen,
                          color: AppColor.white)))),
          DataColumn(
              label: Expanded(
                  child: Text("Vehicle Code",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: quicksandBold.copyWith(
                          fontSize: Dimensions.fontSizeFourteen,
                          color: AppColor.white)))),
          DataColumn(
              label: Expanded(
                  child: Text("Workshop Type",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: quicksandBold.copyWith(
                          fontSize: Dimensions.fontSizeFourteen,
                          color: AppColor.white)))),
          DataColumn(
              label: Expanded(
                  child: Text("Cost",textAlign: TextAlign.right,
                      style: quicksandBold.copyWith(
                          fontSize: Dimensions.fontSizeFourteen,
                          color: AppColor.white)))),
        ],
        rows: [
          ...entries.map((entry) {
            return DataRow(cells: [
              DataCell(Text(entry["Date"] ?? "",
                  style: quicksandRegular.copyWith(
                      fontSize: Dimensions.fontSizeFourteen))),
              DataCell(Align(
                  alignment: Alignment.center,
                  child: Text(entry["Vehicle Code"] ?? "",
                      style: quicksandRegular.copyWith(
                          fontSize: Dimensions.fontSizeFourteen)))),
              DataCell(Align(
                  alignment: Alignment.center,
                  child: Text(entry["Workshop Type"] ?? "",textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,maxLines: 2,
                      style: quicksandRegular.copyWith(
                          fontSize: Dimensions.fontSizeFourteen)))),
              DataCell(Align(alignment: Alignment.centerRight,
                child: Text(entry["Cost"] ?? "",
                    style: quicksandRegular.copyWith(
                        fontSize: Dimensions.fontSizeFourteen)),
              )),
            ]);
          }).toList(),

          // 👇 Add total row
          DataRow(
            color: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) => AppColor.neviBlue.withOpacity(0.1)),
            cells: [
              DataCell(Text("")),
              DataCell(Text("")),
              DataCell(Text("Total:",
                  style: quicksandBold.copyWith(
                      fontSize: Dimensions.fontSizeFourteen))),
              DataCell(Text(
                totalCost.toStringAsFixed(2),
                style: quicksandBold.copyWith(
                    fontSize: Dimensions.fontSizeFourteen),
              )),
            ],
          )
        ],
      ),
    );
  }
}
