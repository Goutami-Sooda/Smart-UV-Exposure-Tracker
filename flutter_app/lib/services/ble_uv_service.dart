import 'dart:async';
import 'package:flareline/models/exposure_model.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BLEUVService {
  static const String deviceName = 'ESP32'; // Change this if needed
  static Guid serviceUUID = Guid("0000181A-0000-1000-8000-00805F9B34FB");
  static Guid charUUID = Guid("00002A76-0000-1000-8000-00805F9B34FB");

  BluetoothDevice? device;
  BluetoothCharacteristic? characteristic;
  StreamSubscription<List<int>>? notificationSubscription;

  Future<void> connectAndListenForUV() async {
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      final scanResults = await FlutterBluePlus.scanResults.first;
      final result = scanResults.firstWhere(
        (r) => r.device.name == deviceName,
        orElse: () => throw Exception("ESP32 not found"),
      );

      device = result.device;
      await FlutterBluePlus.stopScan();

      await device!.connect(autoConnect: false);
      final services = await device!.discoverServices();
      for (var service in services) {
        if (service.uuid == serviceUUID) {
          for (var char in service.characteristics) {
            if (char.uuid == charUUID) {
              characteristic = char;

              await char.setNotifyValue(true);
              notificationSubscription = char.value.listen((value) {
                double uvIndex = _parseUVIndex(value);
                print("Received UV index: $uvIndex");
                _updateFirebase(uvIndex);
              });

              return; // Done
            }
          }
        }
      }

      throw Exception("Characteristic not found");

    } catch (e) {
      print("BLE error: $e");
    }
  }

  double _parseUVIndex(List<int> value) {
    if (value.length < 2) return 0.0;
    return value[0] + value[1] / 10.0;
  }

  Future<void> _updateFirebase(double uvIndex) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final now = DateTime.now();

  // Create an ExposureModel instance
  final exposure = ExposureModel(
    uid: user.uid,
    date: now,
    uvIndex: uvIndex,
    exposureTime: 0, // Initially 0; update later if you track duration
    timestamp: now,
  );

  // Write current UV index for real-time UI use
  await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
    'currentUVIndex': uvIndex,
    'lastExposureDuration': 0,
  });

  // Add this exposure entry to subcollection `uvData`
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('uvData')
      .doc(now.toIso8601String())
      .set(exposure.toJson());
}

  Future<void> disconnect() async {
    await notificationSubscription?.cancel();
    await characteristic?.setNotifyValue(false);
    if (device != null) await device!.disconnect();
  }
}
