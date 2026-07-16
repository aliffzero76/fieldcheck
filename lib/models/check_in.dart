import 'package:hive/hive.dart';

/// Data model for a single field check-in record.
class CheckIn {
  final String id;
  final String note;
  final String photoPath;
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime createdAt;

  CheckIn({
    required this.id,
    required this.note,
    required this.photoPath,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.createdAt,
  });
}

/// Manual Hive TypeAdapter — avoids needing build_runner code generation,
/// so the project runs with a plain `flutter pub get`.
class CheckInAdapter extends TypeAdapter<CheckIn> {
  @override
  final int typeId = 0;

  @override
  CheckIn read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckIn(
      id: fields[0] as String,
      note: fields[1] as String,
      photoPath: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      accuracy: fields[5] as double,
      createdAt: DateTime.parse(fields[6] as String),
    );
  }

  @override
  void write(BinaryWriter writer, CheckIn obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.note)
      ..writeByte(2)
      ..write(obj.photoPath)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.accuracy)
      ..writeByte(6)
      ..write(obj.createdAt.toIso8601String());
  }
}
