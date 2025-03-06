import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tk_logistics/common/widgets/custom_outlined_button.dart';

import '../../../../../../util/app_color.dart';
import '../../../../../../util/dimensions.dart';
import '../../../../../../util/styles.dart';
import '../controller/filed_picker_controller.dart';

class ProofOfDeliveryScreen extends StatelessWidget {
  final FilePickerController fileController = Get.put(FilePickerController());

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
            "Proof of Document",
            style: quicksandBold.copyWith(
                fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
          )),
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeTwenty,vertical: Dimensions.paddingSizeTwenty),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeFifteen,vertical: Dimensions.paddingSizeFifteen),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12), // Adjust for round edges
                        child: fileController.image.value != null
                            ? Image.file(
                          fileController.image.value!,
                          height: 60,
                          width: 80,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 80,
                          height: 60,
                          color: AppColor.neviBlue.withOpacity(0.2),  // Placeholder background
                          child: Icon(Icons.photo, size: 30, color: AppColor.neviBlue),
                        ),
                      );
                    }),
                    SizedBox(width: 15,),
                    Obx(() => Expanded(
                      child: Text(
                        "${fileController.selectedFileName.value}",
                        style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeSixteen, color: AppColor.neviBlue),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            Spacer(),
            CustomOutlinedButton(
              text: "Select File",
              width: double.infinity,
              onTap: (){
                Get.dialog(
                    AlertDialog(
                      title: const Text('Select Image Source'),
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
                            leading: Icon(Icons.insert_drive_file),
                            title: Text("Documents"),
                            onTap: () async {
                              Get.back();
                              await fileController.pickDocument();
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
                    )
                );
              },
            ),
          ],

        ),
      )
    );
  }
}
