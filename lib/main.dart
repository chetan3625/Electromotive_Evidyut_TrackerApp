import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'db.dart';
import 'sync.dart';
import 'evidyutHomePage.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initService();
  runApp(MaterialApp(home: Evidyut(), debugShowCheckedModeBanner: false));
}

Future<void> initService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      initialNotificationTitle: 'Evidyut Sync',
      initialNotificationContent: 'Tracking Location...',
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  await Firebase.initializeApp();
  final syncService = SyncService();

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await syncService.handleLocationSync(
          position.latitude.toString(),
          position.longitude.toString()
      );

      service.invoke('location_update', {
        'lat': position.latitude,
        'lng': position.longitude,
      });
    } catch (e) {
      print("Background Error: $e");
    }
  });}