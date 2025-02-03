import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:happy_belly_kitchen/controller/order_controller.dart';
import 'package:happy_belly_kitchen/util/app_constants.dart';
import 'package:happy_belly_kitchen/view/base/notification_dialog.dart';
import 'package:happy_belly_kitchen/view/screens/order/order_details_screen.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'responsive_helper.dart';

class NotificationHelper {
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    // Create the Android Notification Channel with custom sound
    const AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      'efood_channel', // Same as channel ID used in AndroidNotificationDetails
      'efood notifications',
      description: 'efood notification channel',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound(
          'notification_sound'), // Custom sound
    );

    // Register the channel with the platform
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    // Initialize the Flutter Local Notifications plugin
    const AndroidInitializationSettings androidInitialize =
        AndroidInitializationSettings('notification_icon');
    const DarwinInitializationSettings iOSInitialize =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse? notificationResponse) async {
        try {
          if (notificationResponse?.payload != null) {
            // Handle the notification tap action
          }
        } catch (e) {
          // Handle errors
        }
      },
    );

    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Get.find<OrderController>().getOrderList(1);
      Get.dialog(NotificationDialog(
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          orderId: int.parse(message.notification!.body!)));
    });

    // Handle messages when the app is opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Get.find<OrderController>().getOrderList(1);
      try {
        if (message.notification!.body!.isNotEmpty) {
          if (ResponsiveHelper.isMobile(Get.context)) {
            Get.to(OrderDetailsScreen(
                orderId: int.parse(message.notification!.body!)));
          } else {
            Get.find<OrderController>()
                .updateOrderStatusTabs(OrderStatusTabs.confirmed);
            Get.find<OrderController>().orderStatusUpdate(
                int.parse(message.notification!.body!), 'confirm');
            Get.find<OrderController>().setOrderIdForOrderDetails(
                int.parse(message.notification!.body!), 'confirm', '');
            Get.find<OrderController>()
                .getOrderDetails(int.parse(message.notification!.body!));
          }
        }
      } catch (e) {
        // Handle errors
      }
    });
  }

  static Future<void> showNotification(RemoteMessage message,
      FlutterLocalNotificationsPlugin fln, bool data) async {
    String? title;
    String? body;
    String? orderID;
    String? image;

    if (data) {
      title = message.data['title'];
      body = message.data['body'];
      orderID = message.data['order_id'];
      image = (message.data['image'] != null &&
              message.data['image'].isNotEmpty)
          ? message.data['image'].startsWith('http')
              ? message.data['image']
              : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}'
          : null;
    } else {
      title = message.notification?.title;
      body = message.notification?.body;
      orderID = message.notification?.titleLocKey;
      if (GetPlatform.isAndroid) {
        image = (message.notification?.android?.imageUrl != null &&
                message.notification!.android!.imageUrl!.isNotEmpty)
            ? message.notification!.android!.imageUrl!.startsWith('http')
                ? message.notification!.android!.imageUrl
                : '${AppConstants.baseUrl}/storage/app/public/notification/${message.notification!.android!.imageUrl}'
            : null;
      } else if (GetPlatform.isIOS) {
        image = (message.notification?.apple?.imageUrl != null &&
                message.notification!.apple!.imageUrl!.isNotEmpty)
            ? message.notification!.apple!.imageUrl!.startsWith('http')
                ? message.notification?.apple?.imageUrl
                : '${AppConstants.baseUrl}/storage/app/public/notification/${message.notification?.apple?.imageUrl}'
            : null;
      }
    }

    if (image != null && image.isNotEmpty) {
      try {
        await showBigPictureNotificationHiddenLargeIcon(
            title, body, orderID, image, fln);
      } catch (e) {
        await showBigTextNotification(title, body, orderID, fln);
      }
    } else {
      await showBigTextNotification(title, body, orderID, fln);
    }
  }

  static Future<void> showBigTextNotification(String? title, String? body,
      String? orderID, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body!,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'efood_channel', // Same channel ID as in the initialization method
      'efood notifications',
      importance: Importance.max,
      styleInformation: bigTextStyleInformation,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound(
          'notification_sound'), // Custom sound
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(
      String? title,
      String? body,
      String? orderID,
      String image,
      FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath =
        await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: body,
      htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'efood_channel', // Same channel ID as in the initialization method
      'efood notifications',
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      priority: Priority.max,
      playSound: true,
      styleInformation: bigPictureStyleInformation,
      importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound(
          'notification_sound'), // Custom sound
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  debugPrint(
      "onBackground: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
}
