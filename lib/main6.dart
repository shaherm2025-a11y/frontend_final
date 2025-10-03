import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'l10n/app_localizations.dart';

// =============================== MAIN ===============================
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  void _setLocale(Locale locale) => setState(() => _locale = locale);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Diagnosis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      locale: _locale,
      supportedLocales: const [Locale('en', ''), Locale('ar', '')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(onLocaleChange: _setLocale),
    );
  }
}

// =============================== SPLASH SCREEN ===============================
class SplashScreen extends StatelessWidget {
  final Function(Locale) onLocaleChange;
  const SplashScreen({required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 120),
              const SizedBox(height: 30),
              const Text('مرحباً بك في تطبيق تشخيص أمراض النبات',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              ElevatedButton(
                child: const Text("التشخيص"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DiagnosisPage()),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                child: const Text("الآفات والأمراض"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PestsDiseasesPage()),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                child: const Text("التوعية الزراعية"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AwarenessPage()),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                child: const Text("التواصل مع الخبراء"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ExpertsPage()),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("تغيير اللغة"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('English'),
                            onTap: () {
                              onLocaleChange(const Locale('en'));
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text('العربية'),
                            onTap: () {
                              onLocaleChange(const Locale('ar'));
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text("تغيير اللغة"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================== DATABASE HELPER ===============================
class DatabaseHelper {
  static Database? _db;
  static Map<int, dynamic> _jsonData = {};
  static Map<int, dynamic> _cropsArData = {};

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;
    if (kIsWeb) throw Exception("Web uses JSON, not SQLite");
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, "plantix_final.db");
    _db = await openDatabase(path, readOnly: true);
    return _db!;
  }

  static Future<List<Map<String, dynamic>>> getCrops() async {
    final db = await getDatabase();
    return await db.query('crops');
  }

  static Future<List<Map<String, dynamic>>> getStagesByCrop(int cropId) async {
    final db = await getDatabase();
    return await db.query('stages', where: 'crop_id = ?', whereArgs: [cropId]);
  }

  static Future<List<Map<String, dynamic>>> getDiseasesByCropAndStage(
      int cropId, int stageId) async {
    final db = await getDatabase();
    return await db.rawQuery('''
      SELECT d.id,d.name,d.default_image
      FROM diseases d
      JOIN disease_stages ds ON ds.disease_id=d.id
      WHERE ds.stage_id=? AND ds.crop_id=?
    ''', [stageId, cropId]);
  }

  static Future<void> loadJson() async {
    if (!kIsWeb) return;
    final data = json.decode(await rootBundle.loadString("assets/diseases_all.json"));
    for (var c in data) _jsonData[c['id']] = c;
    final cropsAr = json.decode(await rootBundle.loadString("assets/crops_ar.json"));
    for (var c in cropsAr) _cropsArData[c['id']] = c;
  }

  static Future<List<Map<String, dynamic>>> getCropsFromJson() async {
    return _jsonData.values.map((c) {
      final ar = _cropsArData[c['id']];
      return {'id': c['id'], 'name': c['name'], 'name_en': ar?['name_en'] ?? ''};
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> getStagesByCropFromJson(int cropId) async {
    final crop = _jsonData[cropId];
    final stages = crop['stages'] as List;
    return stages.map((s) => {'id': s['id'], 'name': s['name'], 'diseases': s['diseases']}).toList();
  }

  static Future<List<Map<String, dynamic>>> getDiseasesByCropAndStageFromJson(
      int cropId, int stageId) async {
    final stages = await getStagesByCropFromJson(cropId);
    final st = stages.firstWhere((s) => s['id'] == stageId, orElse: () => {});
    if (st.isEmpty) return [];
    final dis = st['diseases'] as List;
    return dis.map((d) => {
      'id': d['id'],
      'name': d['name'],
      'default_image': d['default_image'],
      'symptoms': d['symptoms'],
      'cause': d['cause'],
      'preventive_measures': (d['preventive_measures'] as List).join(", "),
      'chemical_treatment': d['chemical_treatment'],
      'alternative_treatment': d['alternative_treatment'],
    }).toList();
  }
}

// =============================== PESTS & DISEASES PAGE ===============================
class PestsDiseasesPage extends StatefulWidget {
  const PestsDiseasesPage({Key? key}) : super(key: key);
  @override
  State<PestsDiseasesPage> createState() => _PestsDiseasesPageState();
}

class _PestsDiseasesPageState extends State<PestsDiseasesPage> {
  List<Map<String, dynamic>> crops = [];
  List<Map<String, dynamic>> stages = [];
  Map<int, List<Map<String, dynamic>>> stageDiseases = {};
  int? selectedCropId;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    if (kIsWeb) await DatabaseHelper.loadJson();
    final data = kIsWeb
        ? await DatabaseHelper.getCropsFromJson()
        : await DatabaseHelper.getCrops();
    setState(() => crops = data);
  }

  Future<void> _loadStages(int cropId) async {
    final data = kIsWeb
        ? await DatabaseHelper.getStagesByCropFromJson(cropId)
        : await DatabaseHelper.getStagesByCrop(cropId);
    setState(() {
      stages = data;
      stageDiseases.clear();
    });
    for (var s in data) {
      final dis = kIsWeb
          ? await DatabaseHelper.getDiseasesByCropAndStageFromJson(cropId, s['id'])
          : await DatabaseHelper.getDiseasesByCropAndStage(cropId, s['id']);
      setState(() => stageDiseases[s['id']] = dis);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الآفات والأمراض")),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: crops.length,
              itemBuilder: (_, i) {
                final c = crops[i];
                return ListTile(
                  leading: Image.asset(
                    "assets/plantix_icons/${c['name_en']}.png",
                    width: 40, height: 40,
                    errorBuilder: (_, __, ___) => const Icon(Icons.grass),
                  ),
                  title: Text(c['name']),
                  selected: selectedCropId == c['id'],
                  onTap: () {
                    setState(() => selectedCropId = c['id']);
                    _loadStages(c['id']);
                  },
                );
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: selectedCropId == null
                ? const Center(child: Text("اختر محصولاً من القائمة"))
                : ListView(
                    children: stages.map((st) {
                      final dis = stageDiseases[st['id']] ?? [];
                      return ExpansionTile(
                        title: Text("مرحلة: ${st['name']}"),
                        children: dis.isEmpty
                            ? [const ListTile(title: Text("لا توجد أمراض"))]
                            : dis.map((d) => Card(
                                  child: ListTile(
                                    leading: d['default_image'] != null
                                        ? Image.asset(
                                            "assets/disease_images/${d['default_image']}",
                                            width: 50, height: 50, fit: BoxFit.cover)
                                        : const Icon(Icons.bug_report),
                                    title: Text(d['name'] ?? ""),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DiseaseDetailsPage(disease: d),
                                      ),
                                    ),
                                  ),
                                )).toList(),
                      );
                    }).toList(),
                  ),
          )
        ],
      ),
    );
  }
}

class DiseaseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> disease;
  const DiseaseDetailsPage({Key? key, required this.disease}) : super(key: key);

  Widget _section(String title, String? text) {
    if (text == null || text.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(disease['name'] ?? "تفاصيل المرض")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (disease['default_image'] != null)
              Center(
                child: Image.asset(
                  "assets/disease_images/${disease['default_image']}",
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            _section("الأعراض", disease['symptoms']),
            _section("الأسباب", disease['cause']),
            _section("الإجراءات الوقائية", disease['preventive_measures']),
            _section("المكافحة الكيميائية", disease['chemical_treatment']),
            _section("المكافحة العضوية", disease['alternative_treatment']),
          ],
        ),
      ),
    );
  }
}

// =============================== AWARENESS PAGE ===============================

class AwarenessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.awarenessGuide)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTile(
            icon: Icons.eco,
            title: t.basicFarming,
            imagePath: 'assets/images/soil.jpg',
            content: [
              t.soilAdvice,
              t.sunAdvice,
              t.wateringAdvice,
            ],
          ),
          _buildTile(
            icon: Icons.shield,
            title: t.diseasePrevention,
            imagePath: 'assets/images/protection.jpg',
            content: [
              t.toolSanitation,
              t.cropRotation,
              t.seedSelection,
            ],
          ),
          _buildTile(
            icon: Icons.bug_report,
            title: t.naturalPestControl,
            imagePath: 'assets/images/pests.jpg',
            content: [
              t.plantRepellents,
              t.organicSprays,
              t.beneficialInsects,
            ],
          ),
          _buildTileWithWidget(
            icon: Icons.medical_information,
            title: t.commonDiseases,
            imagePath: 'assets/images/diseases.jpg',
            child: _diseaseTable(t),
          ),
          _buildTileWithWidget(
            icon: Icons.calendar_month,
            title: t.seasonalTips,
            imagePath: 'assets/images/seasons.jpg',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subSection('🌸 ${t.spring}', [t.spring1, t.spring2]),
                _subSection('☀️ ${t.summer}', [t.summer1, t.summer2]),
                _subSection('🍂 ${t.autumn}', [t.autumn1, t.autumn2]),
                _subSection('❄️ ${t.winter}', [t.winter1, t.winter2]),
              ],
            ),
          ),
          _buildTile(
            icon: Icons.menu_book,
            title: t.resources,
            imagePath: 'assets/images/books.jpg',
            content: [
              'FAO: https://www.fao.org',
              'PlantVillage: https://plantvillage.psu.edu',
              t.youtubeChannels,
            ],
          ),
          _buildTile(
            icon: Icons.support_agent,
            title: t.needHelp,
            imagePath: 'assets/images/support.jpg',
            content: [t.contactExpertsInfo],
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String imagePath,
    required List<String> content,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: [
        const SizedBox(height: 8),
        Image.asset(imagePath, height: 150, fit: BoxFit.cover),
        const SizedBox(height: 8),
        ...content.map((item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(item, style: const TextStyle(fontSize: 16)),
            )),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTileWithWidget({
    required IconData icon,
    required String title,
    required String imagePath,
    required Widget child,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: [
        const SizedBox(height: 8),
        Image.asset(imagePath, height: 150, fit: BoxFit.cover),
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: child),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _subSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $item', style: const TextStyle(fontSize: 15)),
              )),
        ],
      ),
    );
  }

  Widget _diseaseTable(AppLocalizations t) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FractionColumnWidth(0.25),
        1: FractionColumnWidth(0.35),
        2: FractionColumnWidth(0.4),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFDEFDE0)),
          children: [
            _tableCell(t.disease),
            _tableCell(t.symptoms),
            _tableCell(t.treatment),
          ],
        ),
        _diseaseRow('البياض الدقيقي', 'طبقة بيضاء على الأوراق', 'تهوية جيدة + رش بالكبريت'),
        _diseaseRow('اللفحة المتأخرة', 'بقع سوداء على الطماطم', 'مبيد نحاسي + إزالة المصاب'),
        _diseaseRow('التعفن الجذري', 'اصفرار وموت تدريجي', 'تحسين التصريف + تقليل الري'),
        _diseaseRow('المن', 'حشرات صغيرة تمتص العصارة', 'بخاخ النيم + ماء وصابون'),
      ],
    );
  }

  TableRow _diseaseRow(String a, String b, String c) {
    return TableRow(
      children: [
        _tableCell(a),
        _tableCell(b),
        _tableCell(c),
      ],
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: const TextStyle(fontSize: 15)),
    );
  }
}



// =============================== DIAGNOSIS PAGE ===============================
class DiagnosisPage extends StatefulWidget {
  const DiagnosisPage({Key? key}) : super(key: key);

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  File? _imageFile;
  Uint8List? _webImage;
  String? _disease;
  String? _treatment;
  double? _confidence;

  final picker = ImagePicker();
  bool _loading = false;

  Future<void> pickImage() async {
    if (kIsWeb) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _webImage = bytes);
        await diagnosePlant(bytes, pickedFile.name);
      }
    } else {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() => _imageFile = file);
        await diagnosePlant(await file.readAsBytes(), pickedFile.name);
      }
    }
  }

  Future<void> diagnosePlant(Uint8List imageBytes, String filename) async {
    final uri = Uri.parse('https://mohashaher-backend-fastapi.hf.space/predict');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: filename,
    ));

    setState(() => _loading = true);

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = json.decode(respStr);
        final diseaseId = data['disease_id'] as String?;
        final conf = (data['confidence'] as num?)?.toDouble();
        final diseaseMap = LocalizationHelper.getDiseaseMap(context);
        setState(() {
          _confidence = conf;
          _disease = diseaseId != null ? diseaseMap[diseaseId] : null;
          _treatment = diseaseId != null ? diseaseMap["${diseaseId}_treatment"] : null;
        });
      } else {
        setState(() {
          _disease = "Error: ${response.statusCode}";
          _treatment = null;
          _confidence = null;
        });
      }
    } catch (e) {
      setState(() {
        _disease = "Error: $e";
        _treatment = null;
        _confidence = null;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(loc.diagnosePlant),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    minimumSize: Size(isWide ? 250 : double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: pickImage,
                  icon: const Icon(Icons.add_a_photo, size: 22),
                  label: Text(
                    loc.selectImage,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                if (_imageFile != null || _webImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, height: 220, fit: BoxFit.cover)
                        : Image.memory(_webImage!, height: 220, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 20),
                if (_loading) const CircularProgressIndicator(color: Colors.green),
                if (_disease != null && !_loading)
                  Card(
                    color: Colors.green[50],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${loc.result}: $_disease",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _disease!.toLowerCase().contains("error")
                                      ? Colors.red
                                      : Colors.green[800])),
                          const SizedBox(height: 10),
                          if (_confidence != null)
                            Text(
                              "${(_confidence!).toStringAsFixed(1)}% ${loc.confidence}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                          const SizedBox(height: 10),
                          if (_treatment != null)
                            Text("${loc.treatment}: $_treatment",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================== EXPERTS PAGE ===============================
class ExpertsPage extends StatelessWidget {
  const ExpertsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // هذه الصفحة توضح الفكرة فقط (تواصل مع الخبراء)
    return Scaffold(
      appBar: AppBar(title: const Text("التواصل مع الخبراء")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.support_agent, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text("تواصل مع خبرائنا عبر واجهة خاصة", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
