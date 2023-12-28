import 'package:happy_belly_kitchen/controller/splash_controller.dart';
import 'package:happy_belly_kitchen/helper/route_helper.dart';
import 'package:happy_belly_kitchen/view/base/custom_snackbar.dart';
import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response) {
    if (response.statusCode == 401 || response.status.code == 401) {
      Get.toNamed(RouteHelper.login);
      Get.find<SplashController>().removeSharedData();
    } else {
      showCustomSnackBar(response.statusText!);
    }
  }
}
