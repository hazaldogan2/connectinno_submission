import 'package:hive_flutter/hive_flutter.dart';
import 'note.dart';

class LocalStorage {
  static const boxName = 'notes_box';
  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
  }

  // Cache: tüm notlar
  Future<void> saveAll(List<Note> notes) async =>
      _box.put('all_notes', notes.map((n) => n.toJson()).toList());

  List<Note> loadAll() {
    final data = _box.get('all_notes');
    if (data is List) {
      return data
          .map((e) => Note.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  // Pending ops queue
  Future<void> enqueue(Map<String, dynamic> op) async {
    final List list =
    _box.get('pending_ops', defaultValue: <Map<String, dynamic>>[]);
    list.add(op);
    await _box.put('pending_ops', list);
  }

  List<Map<String, dynamic>> pending() {
    final List list =
    _box.get('pending_ops', defaultValue: <Map<String, dynamic>>[]);
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> clearPending() async =>
      _box.put('pending_ops', <Map<String, dynamic>>[]);
}
