import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 0)
class Profile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? bloodType;

  @HiveField(2)
  String medicalConditions;

  @HiveField(3)
  String vehicleInfo;

  Profile({
    required this.name,
    this.bloodType,
    required this.medicalConditions,
    required this.vehicleInfo,
  });
}
