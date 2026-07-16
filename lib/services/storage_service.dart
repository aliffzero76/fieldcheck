import 'package:hive_flutter/hive_flutter.dart';
import '../models/check_in.dart';

/// Handles all local persistence for check-in records using Hive.
/// Wrapping Hive here means the rest of the app never talks to Hive
/// directly — makes it easy to swap for sqflite later if needed.
class StorageService {
  static const String boxName = 'check_ins';
  static Box<CheckIn>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CheckInAdapter());
    _box = await Hive.openBox<CheckIn>(boxName);
  }

  static Box<CheckIn> get _safeBox {
    final box = _box;
    if (box == null) {
      throw StateError('StorageService.init() must be called before use.');
    }
    return box;
  }

  static List<CheckIn> getAll() {
    final items = _safeBox.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<void> add(CheckIn checkIn) async {
    await _safeBox.put(checkIn.id, checkIn);
  }

  static Future<void> delete(String id) async {
    await _safeBox.delete(id);
  }

  static CheckIn? getById(String id) {
    return _safeBox.get(id);
  }
}
