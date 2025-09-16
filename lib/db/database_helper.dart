import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openPrepopulatedDb();
    return _db!;
  }

  static Future<Database> _openPrepopulatedDb() async {
    if (kIsWeb) {
      // ✅ استخدام sqflite_common_ffi_web على الويب
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase("plantix_diseases.db");
    } else {
      // ✅ على أندرويد/iOS: نسخ قاعدة البيانات من assets
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, "plantix_diseases.db");

      final exists = await databaseExists(path);

      if (!exists) {
        // نسخ DB من assets عند أول تشغيل
        ByteData data = await rootBundle.load("assets/db/plantix_diseases.db");
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      }

      return await openDatabase(path, readOnly: false);
    }
  }
}
