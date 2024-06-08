import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:permission_and_appcycle/main.dart';
import 'package:permission_and_appcycle/widgets/custom_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionProvider {
  static PermissionStatus locationPermission = PermissionStatus.denied;
  static bool isServiceOn = false;
  static DialogRoute? permissionDialogRoute;

  static Future<void> handleLocationPermission() async {
    isServiceOn = await Permission.location.serviceStatus.isEnabled;
    locationPermission = await Permission.location.status;
    if (isServiceOn) {
      switch (locationPermission) {
        case PermissionStatus.permanentlyDenied:
          permissionDialogRoute = myCustomDialogRoute(
              title: "Location Service",
              text:
                  "To use navigation, please allow location usage in settings.",
              buttonText: "Go To Settings",
              onPressed: () {
                Navigator.of(globalNavigatorKey.currentContext!).pop();
                openAppSettings();
              });
          Navigator.of(globalNavigatorKey.currentContext!)
              .push(permissionDialogRoute!);
        case PermissionStatus.denied:
          Permission.location.request().then((value) {
            locationPermission = value;
          });
          break;
        default:
      }
    } else {
      permissionDialogRoute = myCustomDialogRoute(
          title: "Location Service",
          text: "To use navigation, please turn location service on.",
          buttonText: Platform.isAndroid ? "Turn It On" : "Ok",
          onPressed: () {
            Navigator.of(globalNavigatorKey.currentContext!).pop();
            if (Platform.isAndroid) {
              const AndroidIntent intent =
                  AndroidIntent(action: 'android.settings.LOCATION_SOURCE_SETTINGS');
              intent.launch();
            } else {
              // TODO: ios integration
            }
          });
      Navigator.of(globalNavigatorKey.currentContext!).push(permissionDialogRoute!);
    }
  }
}
