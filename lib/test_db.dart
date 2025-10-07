import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TestDBPage(),
  ));
}

class TestDBPage extends StatefulWidget {
  const TestDBPage({super.key});

  @override
  State<TestDBPage> createState() => _TestDBPageState();
}

class _TestDBPageState extends State<TestDBPage> {
  List<Map<String, dynamic>> crops = [];

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<Database> _openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, "plantix_final.db");

    // انسخ القاعدة من assets إذا مش موجودة
    if (!File(path).existsSync()) {
      ByteData data = await rootBundle.load("assets/plantix_final.db");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(path, readOnly: true);
  }

  Future<void> _loadCrops() async {
    final db = await _openDB();
    final data = await db.query("crops", columns: ["id", "name", "name_en"]);
    setState(() => crops = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("اختبار قاعدة البيانات")),
      body: crops.isEmpty
          ? const Center(child: Text("🚫 لا توجد محاصيل في قاعدة البيانات"))
          : ListView.builder(
              itemCount: crops.length,
              itemBuilder: (context, index) {
                final crop = crops[index];
                return ListTile(
                  title: Text("🌱 ${crop['name']}"),
                  subtitle: Text("EN: ${crop['name_en']}"),
                );
              },
            ),
    );
  }
}
