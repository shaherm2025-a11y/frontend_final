import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
   final path = join(dbPath, 'plantix_final.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // إنشاء الجداول
        await db.execute('''
          CREATE TABLE crops (
            id INTEGER PRIMARY KEY,
            name TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE stages (
            id INTEGER PRIMARY KEY,
            name TEXT,
            crop_id INTEGER,
            FOREIGN KEY (crop_id) REFERENCES crops (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE diseases (
            id INTEGER PRIMARY KEY,
            name TEXT,
            symptoms TEXT,
            cause TEXT,
            preventive_measures TEXT,
            chemical_treatment TEXT,
            alternative_treatment TEXT,
            default_image TEXT,
            crop_id INTEGER,
            stage_id INTEGER,
            FOREIGN KEY (crop_id) REFERENCES crops (id),
            FOREIGN KEY (stage_id) REFERENCES stages (id)
          )
        ''');
      },
    );
  }

  /// تحميل البيانات من JSON وإدخالها في قاعدة البيانات (مرة وحدة)
  static Future<void> importDataFromJson() async {
    final db = await database;

    // تحميل JSON من assets
    final String response =
        await rootBundle.loadString('assets/plant_relational.json');
    final data = json.decode(response);

    for (var crop in data['crops']) {
      await db.insert('crops', {'id': crop['id'], 'name': crop['name']},
          conflictAlgorithm: ConflictAlgorithm.replace);

      for (var stage in crop['stages']) {
        await db.insert(
            'stages',
            {
              'id': stage['id'],
              'name': stage['name'],
              'crop_id': crop['id']
            },
            conflictAlgorithm: ConflictAlgorithm.replace);

        for (var disease in stage['diseases']) {
          await db.insert(
              'diseases',
              {
                'id': disease['id'],
                'name': disease['name'],
                'symptoms': disease['symptoms'],
                'cause': disease['cause'],
                'preventive_measures': disease['preventive_measures'],
                'chemical_treatment': disease['chemical_treatment'],
                'alternative_treatment': disease['alternative_treatment'],
                'default_image': disease['default_image'],
                'crop_id': crop['id'],
                'stage_id': stage['id']
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    }
  }

  static Future<List<Map<String, dynamic>>> getCrops() async {
    final db = await database;
    return await db.query('crops');
  }

  static Future<List<Map<String, dynamic>>> getStagesByCrop(int cropId) async {
    final db = await database;
    return await db.query('stages', where: 'crop_id = ?', whereArgs: [cropId]);
  }

  static Future<List<Map<String, dynamic>>> getDiseasesByCropAndStage(
      int cropId, int stageId) async {
    final db = await database;
    return await db.query('diseases',
        where: 'crop_id = ? AND stage_id = ?', whereArgs: [cropId, stageId]);
  }
}
