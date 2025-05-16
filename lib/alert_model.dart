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
  String photos;
  @HiveField(4)
  String video;
  @HiveField(5)
  String message;
  
  Alert({
    required this.emergencyId,
    required this.dateTime, 
    required this.locationUrl,
    required this.photos,
    required this.video,
    required this.message,
    });
}