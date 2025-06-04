import 'package:hive/hive.dart';

part 'alert_model.g.dart';

@HiveType(typeId: 2)
class Alert extends HiveObject {
  @HiveField(0)
  DateTime emergencyId;

  @HiveField(1)
  String dateTime;

  @HiveField(2)
  String locationUrl;

  @HiveField(3)
  List<String> photos;

  @HiveField(4)
  String message;

  @HiveField(5)
  String batteryLevel;

  @HiveField(6)
  double latitude;

  @HiveField(7)
  double longitude;

  Alert({
    required this.emergencyId,
    required this.dateTime,
    required this.locationUrl,
    required this.photos,
    required this.message,
    required this.batteryLevel,
    required this.latitude,
    required this.longitude,
  });
}
