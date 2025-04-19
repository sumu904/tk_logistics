import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/controller/entry_list_controller.dart';

import '../../../../../common/widgets/custom_button.dart';
import '../../../../../util/app_color.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';

class EntryListScreen extends StatelessWidget {
  final controller = Get.put(EntryListController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                      // Expanded to make the DateField take up equal space in the Row
                      Expanded(
                        child: buildDateField("From Date", controller.selectedFromDate, controller.fromDateController),
                      ),
                      SizedBox(width: 10,),
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
                    child: CustomButton(
                      onTap: () {
                        controller.filterEntries();
                      },
                      text: "Submit",
                    ),
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

  // Reusable Date Field
  Widget buildDateField(String label, Rxn<DateTime> selectedDate, TextEditingController dateController) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: Get.context!,
          initialDate: selectedDate.value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          selectedDate.value = pickedDate;
          dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: dateController,
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
            // Add other styling as needed
          ),
        ),
      ),
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
        );
      },
    );
  }

  // Table to display the filtered entries
  Widget buildEntriesTable(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) {
      return Center(child: Text("No Entries found for the selected criteria."));
    }

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 1, color: AppColor.neviBlue)),
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
                  child: Text("Cost",
                      style: quicksandBold.copyWith(
                          fontSize: Dimensions.fontSizeFourteen,
                          color: AppColor.white)))),
        ],
        rows: entries.map((entry) {
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
                child: Text(entry["Workshop Type"] ?? "",
                    style: quicksandRegular.copyWith(
                        fontSize: Dimensions.fontSizeFourteen)))),
            DataCell(Text(entry["Cost"] ?? "",
                style: quicksandRegular.copyWith(
                    fontSize: Dimensions.fontSizeFourteen))),
          ]);
        }).toList(),
      ),
    );
  }
}
