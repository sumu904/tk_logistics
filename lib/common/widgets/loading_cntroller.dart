
import 'package:get/get.dart';

class LoadingController extends GetxController {
  var isLoading = false.obs;
  var isCreatingTrip = false.obs;
  var isUpdatingTrip = false.obs;
  var isClosingTrip = false.obs;
  var isPrintingChallan = false.obs;
  var isSubmitting = false.obs;
  var isCompleting = false.obs;

  /// General loader for custom actions
  Future<void> runWithLoader({
    required RxBool loader,
    required Future<void> Function() action,
  }) async {
    loader.value = true;
    try {
      await action();
    } finally {
      loader.value = false;
    }
  }
}

