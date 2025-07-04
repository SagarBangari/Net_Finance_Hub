import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/widgets.dart';

Future<void> backgroundHandler(RemoteMessage message, String m) async {
  log("message received! $m  ${message.notification!.title}");
}

class NotificationService {

  static Future<void> initialize() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
    if(settings.authorizationStatus == AuthorizationStatus.authorized) {
      
      String? token = await FirebaseMessaging.instance.getToken();
      if(token != null) {
        log(token);
      }

      FirebaseMessaging.onBackgroundMessage(backgroundHandler as BackgroundMessageHandler);

      log("Notifications Initialized!");
    }
  }

}

