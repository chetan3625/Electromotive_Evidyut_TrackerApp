class LocationModel {
  final int? id;
  final String latitude;
  final String longitude;
  final String timestamp;

  LocationModel({this.id, required this.latitude, required this.longitude, required this.timestamp});

  // SQLite साठी रूपांतर
  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude, 'timestamp': timestamp};
  }

  Map<String, dynamic> toFirestore() {
    return {'Latitude': latitude, 'Longitude': longitude, 'TimeStamp': timestamp};
  }
}