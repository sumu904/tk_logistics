import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/features/screens/home/create_trip/3ms/quotation/controller/quotation_controller.dart';
import 'package:tk_logistics/util/app_color.dart';
import 'package:tk_logistics/util/dimensions.dart';
import 'package:tk_logistics/util/styles.dart';

import '../../../../../../../common/widgets/custom_button.dart';

class QuotationScreen extends StatelessWidget {
  final QuotationController controller = Get.put(QuotationController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      appBar: AppBar(
        centerTitle: true,
          backgroundColor: AppColor.neviBlue,
          leading: IconButton(onPressed: () { Get.back(); }, icon: Icon(Icons.arrow_back_ios,size: 22,color: AppColor.white,),),
          title: Text(
        "Quotation Form",
        style: quicksandBold.copyWith(
            fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
          key: _formKey,
            child: GetBuilder<QuotationController>(
                initState: (_) {
                 controller.fetchSuppliers(); // ✅ Fetch locations when screen opens
                },
                builder: (controller) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Pick Supplier
                      buildSearchableDropdown(
                          "Pick Vendor", controller.pickSuppliers,
                          controller.pickSupplier),
                      SizedBox(height: 10,),

                      /// Vehicle Type
                      Row(
                        children: [
                          Expanded(
                            child: buildSearchableDropdown(
                                "Vehicle Type", controller.vehicleTypes,
                                controller.vehicleType, required: false),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: buildSearchableDropdown(
                                "No of Vehicle", controller.vehicleNumbers,
                                controller.vehicleNo, required: false),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      buildTextField(
                          "Vehicle Number", controller.vehicleNumberController, isNumeric: true),

                      /// Vehicle Capacity
                      buildTextField(
                          "Vehicle Capacity", controller.capacityController,
                          isNumeric: false),

                      /// Pickup Date & Time
                      Row(
                        children: [
                          Expanded(child: buildDateTimeField(
                              "Pickup Date & Time", controller.pickupDate)),
                          SizedBox(width: 10,),
                          Expanded(
                            child: buildDateTimeField(
                                "Drop-off Date & Time", controller.dropOffDate),
                          ),
                        ],
                      ),

                      /// Offered Price
                      buildTextField(
                          "Offered Price", controller.offeredPriceController,
                          isNumeric: false),

                      /// Submit Button
                      SizedBox(height: 20),
                      Center(
                        child: CustomButton(
                          text: "Submit",
                          color: AppColor.neviBlue,
                          height: 40,
                          width: 180,
                          onTap: () {
                            controller.submitForm();
                          },
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }

  /// Reusable TextField
  Widget buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
          labelText: label,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
              borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: AppColor.green),
              borderRadius: BorderRadius.circular(12)),
        ),
        controller: controller,
        keyboardType: isNumeric ? TextInputType.text : TextInputType.number,

      ),
    );
  }

  /// Reusable Date Picker (Only wrapped in Obx)
  Widget buildDateTimeField(String label, Rx<DateTime?> date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(() => TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeFourteen),
              suffixIcon: Icon(Icons.calendar_today),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
                  borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.5, color: AppColor.green),
                  borderRadius: BorderRadius.circular(12)),
            ),
            controller: TextEditingController(
                text: date.value != null
                    ? "${date.value!.toLocal()}".split(' ')[0] +
                        " " +
                        "${date.value!.hour}:${date.value!.minute}"
                    : ""),
            onTap: () => controller.pickDateTime(date),
          )),
    );
  }

  /// Reusable Radio Button (Only wrapped in Obx)
  Widget buildSearchableDropdown(String label, List<String> items,
      RxnString selectedValue, {bool required = false}) {
    TextEditingController controller = TextEditingController(
        text: selectedValue.value ?? ""); // Initialize controller

    // Ensure controller updates when selectedValue changes
    ever(selectedValue, (value) {
      controller.text = value ?? "";
    });

    return TextFormField(
      controller: controller,
      readOnly: true,
      // Prevent manual typing
      onTap: () => showSearchDialog(label, items, selectedValue, controller),
      // Open search dialog
      decoration: InputDecoration(
        labelText: label,
        labelStyle: quicksandRegular.copyWith(
            fontSize: Dimensions.fontSizeFourteen),
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
        suffixIcon: Icon(
            Icons.arrow_drop_down, color: AppColor.green), // Dropdown icon
      ),
      validator: required ? (value) =>
      (value == null || value.isEmpty)
          ? "Please select $label"
          : null : null,
    );
  }

  void showSearchDialog(String label, List<String> items,
      RxnString selectedValue, TextEditingController controller) {
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
                  prefixIcon: Icon(Icons.search, color: AppColor.neviBlue,),
                  hintText: "Search...",
                  hintStyle: quicksandSemibold.copyWith(
                      fontSize: Dimensions.fontSizeSixteen,
                      color: AppColor.neviBlue),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1.5, color: AppColor.green),
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1.5, color: AppColor.neviBlue),
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
              Obx(() =>
                  Container(
                    height: 200,
                    child: ListView.separated(
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => Divider(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            filteredItems[index], style: quicksandRegular
                              .copyWith(fontSize: Dimensions.fontSizeFourteen,
                              color: AppColor.neviBlue),),
                          onTap: () {
                            selectedValue.value = filteredItems[index];
                            Get.back(); // Close dialog
                          },
                        );
                      },
                    ),
                  )),
              TextButton(
                onPressed: () => Get.back(),
                child: Text("CLOSE", style: quicksandSemibold.copyWith(
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
