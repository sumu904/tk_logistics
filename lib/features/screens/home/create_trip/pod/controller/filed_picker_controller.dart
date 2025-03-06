import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerController extends GetxController {
  var selectedFileName = "No file selected".obs;
  var selectedFiles = <File>[].obs;
  Rx<File?> image = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();



  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      image.value = File(pickedFile.path);
      selectedFileName.value = pickedFile.name;
    }
    else {
      selectedFileName.value = "No image selected";
    }
  }

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      selectedFileName.value = result.files.single.name;
      selectedFiles.add(File(result.files.single.path!));
    } else {
      selectedFileName.value = "No document selected";
    }
  }
}