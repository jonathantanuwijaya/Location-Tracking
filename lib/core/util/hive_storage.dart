import 'dart:developer';
import 'package:hive/hive.dart';

class HiveStorage {
  static const String boxName = 'TRACKING-BOX';
  Box? _box;

  Future<T?> get<T>(String key) async {
    try {
      final box = await _getBox;
      return box.get(key) as T?;
    } catch (e, st) {
      log('Error getting value from Hive: $e\n$st');
      return null;
    }
  }

  Future<void> insert(String key, dynamic value) async {
    try {
      final box = await _getBox;
      await box.put(key, value);
    } catch (e, st) {
      log('Error inserting value to Hive: $e\n$st');
    }
  }

  Future<void> remove(String key) async {
    try {
      final box = await _getBox;
      await box.delete(key);
    } catch (e, st) {
      log('Error removing value from Hive: $e\n$st');
    }
  }

  Future<void> removeAll() async {
    try {
      final box = await _getBox;
      await box.deleteFromDisk();
    } catch (e, st) {
      log('Error removing all values from Hive: $e\n$st');
    }
  }

  Future<void> clearAll() async {
    try {
      final box = await _getBox;
      await box.clear();
    } catch (e, st) {
      log('Error clearing all values from Hive: $e\n$st');
    }
  }

  Future<void> close() async {
    try {
      if (_box?.isOpen ?? false) {
        await _box!.close();
      }
    } catch (e, st) {
      log('Error closing Hive box: $e\n$st');
    }
  }

  Future<Box> get _getBox async {
    try {
      if (_box == null || !(_box?.isOpen ?? false)) {
        _box = await Hive.openBox(boxName);
      }
      return _box!;
    } catch (e) {
      log('Error opening Hive box: $e');
      rethrow;
    }
  }
}
