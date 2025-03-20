import 'package:hive/hive.dart';

class HiveStorage {
  static const String boxName = 'TRACKING-BOX';
  Box? _box;

  Future<T?> get<T>(String key) async {
    final box = await _getBox;
    return box.get(key) as T?;
  }

  Future<Map<String, dynamic>?> getMap(String key) async {
    final box = await _getBox;
    final data = box.get(key);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  Future<void> insert(String key, dynamic value) async {
    final box = await _getBox;
    await box.put(key, value);
  }

  Future<void> remove(String key) async {
    final box = await _getBox;
    await box.delete(key);
  }

  Future<void> removeAll() async {
    final box = await _getBox;
    await box.deleteFromDisk();
  }

  Future<void> clearAll() async {
    final box = await _getBox;
    await box.clear();
  }

  Future<void> close() async {
    if (_box?.isOpen ?? false) {
      await _box!.close();
    }
  }

  Future<Box> get _getBox async {
    if (_box == null || !(_box?.isOpen ?? false)) {
      _box = await Hive.openBox(boxName);
    }
    return _box!;
  }
}
