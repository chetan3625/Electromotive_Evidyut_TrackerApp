import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart'; // Intl import kara
import 'db.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> handleLocationSync(String lat, String lng) async {
    var connectivity = await Connectivity().checkConnectivity();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy hh:mm:ss a').format(now);

    if (connectivity.contains(ConnectivityResult.mobile) ||
        connectivity.contains(ConnectivityResult.wifi)) {

      print("Online: Syncing with time $formattedDate");

      try {
        await syncOfflineData();

        await _firestore.collection('Users').add({
          'Latitude': lat,
          'Longitude': lng,
          'TimeStamp': formattedDate, // Shuddha format madhe
        });
        print("Firestore Sync Success");
      } catch (e) {
        print("Firestore Error: $e");
        await LocationDatabase.instance.insertLocation(lat, lng, formattedDate);
      }
    } else {
      print("Offline: Saving to SQLite with time $formattedDate");
      await LocationDatabase.instance.insertLocation(lat, lng, formattedDate);
    }
  }

  Future<void> syncOfflineData() async {
    final data = await LocationDatabase.instance.getAllLocations();
    if (data.isNotEmpty) {
      for (var row in data) {
        try {
          await _firestore.collection('Users').add({
            'Latitude': row['latitude'],
            'Longitude': row['longitude'],
            'TimeStamp': row['timestamp'] // Local DB madhla format as-is jail
          });
          await LocationDatabase.instance.deleteLocation(row['id']);
        } catch (e) {
          print("Individual Sync Error: $e");
        }
      }
      print("Local DB Cleared after sync.");
    }
  }
}