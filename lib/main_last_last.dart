import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter/services.dart';

// ================= Database Helper =================
class DatabaseHelper {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;
    if (kIsWeb) throw Exception("Web uses JSON, not SQLite");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "plantix_final.db");
    _db = await openDatabase(path, readOnly: true);
    return _db!;
  }

  // قراءة المحاصيل
  static Future<List<Map<String, dynamic>>> getCrops() async {
    if (kIsWeb) throw Exception("Use JSON on Web");
    final db = await getDatabase();
    return await db.query('crops');
  }

  // قراءة مراحل محصول معين
  static Future<List<Map<String, dynamic>>> getStagesByCrop(int cropId) async {
    if (kIsWeb) throw Exception("Use JSON on Web");
    final db = await getDatabase();
    return await db.query('stages', where: 'crop_id = ?', whereArgs: [cropId]);
  }

  // قراءة الأمراض لكل مرحلة
  static Future<List<Map<String, dynamic>>> getDiseasesByCropAndStage(
      int cropId, int stageId) async {
    if (kIsWeb) throw Exception("Use JSON on Web");
    final db = await getDatabase();
    final result = await db.rawQuery('''
      SELECT d.id, d.name, d.default_image
      FROM diseases d
      JOIN disease_stages ds ON ds.disease_id = d.id
      WHERE ds.stage_id = ? AND ds.crop_id = ?
    ''', [stageId, cropId]);
    return result;
  }

  // ================== JSON Loader for Web ==================
  static Map<int, dynamic> _jsonData = {};
  static Future<void> loadJson(String assetPath) async {
    if (!kIsWeb) return;
    final data = await rootBundle.loadString(assetPath);
    final list = json.decode(data) as List<dynamic>;
    _jsonData.clear();
    for (var crop in list) {
      _jsonData[crop['id']] = crop;
    }
  }

  static Future<List<Map<String, dynamic>>> getCropsFromJson() async {
    return _jsonData.values
        .map((c) => {'id': c['id'], 'name': c['name']})
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getStagesByCropFromJson(int cropId) async {
    final crop = _jsonData[cropId];
    if (crop == null) return [];
    final stages = crop['stages'] as List<dynamic>;
    return stages.map((s) => {'id': s['id'], 'name': s['name'], 'diseases': s['diseases']}).toList();
  }

  static Future<List<Map<String, dynamic>>> getDiseasesByCropAndStageFromJson(
      int cropId, int stageId) async {
    final stages = await getStagesByCropFromJson(cropId);
    final stage = stages.firstWhere((s) => s['id'] == stageId, orElse: () => {});
    if (stage.isEmpty) return [];
    final diseases = stage['diseases'] as List<dynamic>;
    return diseases.map((d) => {
          'id': d['id'],
          'name': d['name'],
          'default_image': d['default_image'],
          'symptoms': d['symptoms'],
          'cause': d['cause'],
          'preventive_measures': (d['preventive_measures'] as List<dynamic>).join(", "),
          'chemical_treatment': d['chemical_treatment'],
          'alternative_treatment': d['alternative_treatment'],
        }).toList();
  }
}

// ================== Main App ==================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await DatabaseHelper.loadJson("assets/plant_relational.json");
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en');
  void _setLocale(Locale locale) => setState(() => _locale = locale);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Diagnosis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Arial'),
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

// ================== Splash Screen ==================
class SplashScreen extends StatelessWidget {
  final Function(Locale) onLocaleChange;
  SplashScreen({required this.onLocaleChange});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 120),
              SizedBox(height: 30),
              Text(
                t.welcomeText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DiagnosisPage()));
                },
                child: Text(t.diagnosePlant),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ExpertsPage()));
                },
                child: Text(t.contactExperts),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PestsDiseasesPage()));
                },
                child: Text("الآفات والأمراض"),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AwarenessPage()));
                },
                child: Text(t.awarenessGuide),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(t.changeLanguage),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text('English'),
                            onTap: () {
                              onLocaleChange(Locale('en'));
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('العربية'),
                            onTap: () {
                              onLocaleChange(Locale('ar'));
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Text(t.changeLanguage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== Diagnosis Page (unchanged) ==================
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

// ================== Experts Page ==================
class ExpertsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.experts)),
      body: Center(
        child: Text(t.expertsPlaceholder, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

// ================== Pests & Diseases Page ==================
class PestsDiseasesPage extends StatefulWidget {
  const PestsDiseasesPage({Key? key}) : super(key: key);
  @override
  State<PestsDiseasesPage> createState() => _PestsDiseasesPageState();
}

class _PestsDiseasesPageState extends State<PestsDiseasesPage> {
  List<Map<String, dynamic>> crops = [];
  int? selectedCropId;
  List<Map<String, dynamic>> stages = [];
  Map<int, List<Map<String, dynamic>>> stageDiseases = {};

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
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

    for (var stage in data) {
      final diseases = kIsWeb
          ? await DatabaseHelper.getDiseasesByCropAndStageFromJson(cropId, stage['id'])
          : await DatabaseHelper.getDiseasesByCropAndStage(cropId, stage['id']);
      setState(() => stageDiseases[stage['id']] = diseases);
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
              itemBuilder: (context, index) {
                final crop = crops[index];
                return ListTile(
                  leading: const Icon(Icons.grass, color: Colors.green),
                  title: Text(crop['name']),
                  selected: selectedCropId == crop['id'],
                  onTap: () {
                    setState(() => selectedCropId = crop['id']);
                    _loadStages(crop['id']);
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
                    children: stages.map((stage) {
                      final diseases = stageDiseases[stage['id']] ?? [];
                      return ExpansionTile(
                        title: Text("مرحلة: ${stage['name']}"),
                        children: diseases.isEmpty
                            ? [const ListTile(title: Text("لا توجد أمراض في هذه المرحلة"))]
                            : diseases.map((disease) {
                                return Card(
                                  margin: const EdgeInsets.all(8),
                                  child: ListTile(
                                    leading: disease['default_image'] != null
                                    ? Image.asset(
                                     "assets/disease_images/${disease['default_image']}",
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                                 )
                                     : const Icon(Icons.bug_report),

                                    title: Text(disease['name'] ?? ""),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DiseaseDetailsPage(
                                              disease: disease, details: disease),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ================== Disease Details ==================
class DiseaseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> disease;
  final Map<String, dynamic> details;

  const DiseaseDetailsPage({Key? key, required this.disease, required this.details})
      : super(key: key);

  Widget _buildDetailSection(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14)),
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

            const SizedBox(height: 16),
            _buildDetailSection("الأعراض", disease['symptoms']),
            _buildDetailSection("الأسباب", disease['cause']),
            _buildDetailSection("الإجراءات الوقائية", disease['preventive_measures']),
            _buildDetailSection("المكافحة الكيميائية", disease['chemical_treatment']),
            _buildDetailSection("المكافحة العضوية", disease['alternative_treatment']),
          ],
        ),
      ),
    );
  }
}

// ================== Awareness Page (unchanged) ==================
class AwarenessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.awarenessGuide)),
      body: Center(child: Text("صفحة التوعية")), // يمكنك إعادة المحتوى الأصلي هنا
    );
  }
}
