import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tk_logistics/features/screens/home/trip_history/update%20trip/rental/controller/update_rental_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../common/widgets/custom_outlined_button.dart';
import '../../../../../../../util/app_color.dart';
import '../../../../../../../util/dimensions.dart';
import '../../../../../../../util/styles.dart';
import '../controller/filed_picker_controller.dart';

class ProofOfDeliveryScreenRental extends StatelessWidget {
  final FilePickerController fileController = Get.put(FilePickerController());
  //final UpdateTmsController tripController = Get.find<UpdateTmsController>();
  final UpdateRentalController Controller = Get.find<UpdateRentalController>();

  final String tripId;

  ProofOfDeliveryScreenRental({Key? key})
      : tripId = Get.arguments?['tripId'] ?? '',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('Trip ID: $tripId');

    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.neviBlue,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, size: 22, color: AppColor.white),
        ),
        title: Text(
          "Proof of Delivery",
          style: quicksandBold.copyWith(
            fontSize: Dimensions.fontSizeEighteen,
            color: AppColor.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Dimensions.paddingSizeTwenty),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(Dimensions.paddingSizeFifteen),
                child: Obx(() {
                  final file = fileController.selectedFile.value;
                  final hasFile = file != null;
                  final tripPoD = Controller.tripPoD.value;
                  final hasTripPoD = tripPoD.isNotEmpty;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: hasFile
                            ? _buildFilePreview(file)
                            : _buildPlaceholderIcon(tripPoD),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasTripPoD)
                              GestureDetector(
                                onTap: () => openUrl(tripPoD),
                                child: Text(
                                  "View Proof of Delivery",
                                  style: quicksandBold.copyWith(
                                    fontSize: Dimensions.fontSizeSixteen,
                                    color: AppColor.neviBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            if (hasFile || hasTripPoD)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  hasTripPoD
                                      ? tripPoD.split('/').last
                                      : _getFileDisplayName(file!),
                                  style: quicksandSemibold.copyWith(
                                    fontSize: Dimensions.fontSizeFourteen,
                                    color: AppColor.grey3,
                                  ),
                                ),
                              ),
                            if (!hasFile && !hasTripPoD)
                              Text(
                                "No Proof of Delivery found",
                                style: quicksandBold.copyWith(
                                  fontSize: Dimensions.fontSizeSixteen,
                                  color: AppColor.neviBlue,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            Spacer(),
            CustomOutlinedButton(
              text: "Select File",
              width: double.infinity,
              onTap: _showFileSelectionDialog,
            ),
            SizedBox(height: 10),
            CustomOutlinedButton(
              text: "Upload",
              width: double.infinity,
              onTap: () async {
                final Controller = Get.find<UpdateRentalController>();
                await fileController.uploadFile(
                  tripId: Controller.tripId.value,
                  fetchTripDetails: Controller.fetchTripDetails,
                  isDataLoading: Controller.isDataLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(File file) {
    final fileExtension = file.path.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png'].contains(fileExtension);

    if (isImage) {
      return Image.file(
        file,
        height: 60,
        width: 80,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: 80,
        height: 60,
        color: AppColor.neviBlue.withOpacity(0.2),
        child: Icon(
          fileExtension == 'pdf' ? Icons.picture_as_pdf : Icons.insert_drive_file,
          size: 30,
          color: AppColor.neviBlue,
        ),
      );
    }
  }

  Widget _buildPlaceholderIcon(String tripPoD) {
    final isPdf = tripPoD.toLowerCase().endsWith('.pdf');
    return Container(
      width: 80,
      height: 60,
      color: AppColor.neviBlue.withOpacity(0.2),
      child: Icon(
        isPdf ? Icons.picture_as_pdf : Icons.photo,
        size: 30,
        color: AppColor.neviBlue,
      ),
    );
  }

  void _showFileSelectionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select File Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                fileController.pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                fileController.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text("Documents"),
              onTap: () {
                Get.back();
                fileController.pickDocument();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  String _getFileDisplayName(File file) {
    final fileName = file.path.split('/').last;
    final fileExtension = file.path.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(fileExtension);
    return isImage ? fileName : '$fileName (Document)';
  }
}
Future<void> openUrl(String url) async {
  final uri = Uri.parse(Uri.encodeFull(url));
  try {
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  } catch (e) {
    Get.snackbar("Error", "Could not open file: $e");
  }
}