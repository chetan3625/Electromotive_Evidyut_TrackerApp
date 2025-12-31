import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Evidyut extends StatefulWidget {
  @override
  _EvidyutState createState() => _EvidyutState();
}

class _EvidyutState extends State<Evidyut> {
  GoogleMapController? _mapController;
  LatLng _currentPos = const LatLng(20.5937, 78.9629);
  bool isRunning = false;
  StreamSubscription? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
    _listenToBackgroundUpdates();
  }

  Future<void> _setInitialLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPos = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPos, 15),
    );
  }

  void _listenToBackgroundUpdates() {
    _locationSubscription = FlutterBackgroundService().on('location_update').listen((event) {
      if (event != null && mounted) {
        setState(() {
          _currentPos = LatLng(event['lat'], event['lng']);
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentPos),
        );
      }
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Evidyut Tracker")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentPos, zoom: 15),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) => _mapController = controller,
            markers: {
              Marker(
                markerId: const MarkerId("me"),
                position: _currentPos,
                infoWindow: const InfoWindow(title: "तुमचे स्थान"),
              )
            },
          ),
          Positioned(
            bottom: 50, left: 50, right: 50,
            child: ElevatedButton(
              onPressed: () async {
                var service = FlutterBackgroundService();
                bool running = await service.isRunning();
                if (running) {
                  service.invoke("stopService");
                } else {
                  service.startService();
                }
                setState(() => isRunning = !running);
              },
              child: Text(isRunning ? "STOP" : "START"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isRunning ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}