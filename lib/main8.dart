import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'utils/localization_helper.dart';
import 'package:file_picker/file_picker.dart';

// ================= Database Helper =================
class DatabaseHelper {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;
    if (kIsWeb) throw Exception("Web uses JSON, not SQLite");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = p.join(documentsDirectory.path, "plantix_final.db");
    _db = await openDatabase(path, readOnly: true);
    return _db!;
  }

  /// ✅ المحاصيل حسب اللغة
  static Future<List<Map<String, dynamic>>> getCrops(BuildContext context) async {
    if (kIsWeb) throw Exception("Use JSON on Web");
    final db = await getDatabase();
    final lang = Localizations.localeOf(context).languageCode;
    final col = lang == 'ar' ? 'name' : 'name_en';
    final crops =
        await db.rawQuery('SELECT id, $col as name, name, name_en FROM crops');
    return crops;
  }

  /// ✅ المراحل حسب اللغة
  static Future<List<Map<String, dynamic>>> getStagesByCrop(
      BuildContext context, int cropId) async {
    final db = await getDatabase();
    final lang = Localizations.localeOf(context).languageCode;
    final col = lang == 'ar' ? 'name' : 'name_en';
    return await db.rawQuery(
        'SELECT id, $col as name, name, name_en FROM stages WHERE crop_id = ?',
        [cropId]);
  }

  /// ✅ الأمراض حسب اللغة
  static Future<List<Map<String, dynamic>>> getDiseasesByCropAndStage(
      BuildContext context, int cropId, int stageId) async {
    final db = await getDatabase();
    final lang = Localizations.localeOf(context).languageCode;
    final col = lang == 'ar' ? 'name' : 'name_en';
    return await db.rawQuery('''
      SELECT d.id, d.$col as name, d.name, d.name_en, d.default_image,
             d.symptoms, d.cause, d.preventive_measures,
             d.chemical_treatment, d.alternative_treatment
      FROM diseases d
      JOIN disease_stages ds ON ds.disease_id = d.id
      WHERE ds.stage_id = ? AND ds.crop_id = ?
    ''', [stageId, cropId]);
  }

  // ✅ JSON Loader للويب
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

  static Future<List<Map<String, dynamic>>> getCropsFromJson(
      BuildContext context) async {
    final lang = Localizations.localeOf(context).languageCode;
    return _jsonData.values
        .map((c) => {
              'id': c['id'],
              'name': lang == 'ar' ? c['name'] : c['name_en'] ?? c['name'],
              'name': c['name'],
              'name_en': c['name_en']
            })
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getStagesByCropFromJson(
      BuildContext context, int cropId) async {
    final crop = _jsonData[cropId];
    if (crop == null) return [];
    final lang = Localizations.localeOf(context).languageCode;
    final stages = crop['stages'] as List<dynamic>;
    return stages
        .map((s) => {
              'id': s['id'],
              'name': lang == 'ar' ? s['name'] : s['name_en'] ?? s['name'],
              'diseases': s['diseases']
            })
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getDiseasesByCropAndStageFromJson(
      BuildContext context, int cropId, int stageId) async {
    final stages = await getStagesByCropFromJson(context, cropId);
    final stage =
        stages.firstWhere((s) => s['id'] == stageId, orElse: () => {});
    if (stage.isEmpty) return [];
    final lang = Localizations.localeOf(context).languageCode;
    final diseases = stage['diseases'] as List<dynamic>;
    return diseases
        .map((d) => {
              'id': d['id'],
              'name': lang == 'ar' ? d['name'] : d['name_en'] ?? d['name'],
              'default_image': d['default_image'],
              'symptoms': d['symptoms'],
              'cause': d['cause'],
              'preventive_measures':
                  (d['preventive_measures'] as List<dynamic>).join(", "),
              'chemical_treatment': d['chemical_treatment'],
              'alternative_treatment': d['alternative_treatment'],
            })
        .toList();
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
  Locale _locale = const Locale('en');
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
class SplashScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  const SplashScreen({required this.onLocaleChange, Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  late AnimationController _buttonsController;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _logoController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation =
        CurvedAnimation(parent: _logoController, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoController.forward();
    _buttonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideAnimations = List.generate(5, (index) {
      final start = index * 0.1;
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _buttonsController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });
    _buttonsController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedButton(
      {required String text,
      required IconData icon,
      required VoidCallback onPressed,
      required Animation<Offset> animation}) {
    return SlideTransition(
      position: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[200],
            foregroundColor: Colors.black87,
            minimumSize: const Size(double.infinity, 55),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(text, style: const TextStyle(fontSize: 17)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child:
                            Image.asset("assets/logo.png", fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      t.welcomeText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 35),
                    _buildAnimatedButton(
                      text: t.diagnosePlant,
                      icon: Icons.search,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DiagnosisPage()));
                      },
                      animation: _slideAnimations[0],
                    ),
                    _buildAnimatedButton(
                      text: t.contactExperts,
                      icon: Icons.person,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ExpertsPage()));
                      },
                      animation: _slideAnimations[1],
                    ),
                    _buildAnimatedButton(
                      text: t.pestsDiseases,
                      icon: Icons.bug_report,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PestsDiseasesPage()),
                        );
                      },
                      animation: _slideAnimations[2],
                    ),
                    _buildAnimatedButton(
                      text: t.awarenessGuide,
                      icon: Icons.menu_book,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AwarenessPage()));
                      },
                      animation: _slideAnimations[3],
                    ),
                    _buildAnimatedButton(
                      text: t.changeLanguage,
                      icon: Icons.language,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(t.changeLanguage),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.language),
                                  title: const Text('English'),
                                  onTap: () {
                                    widget.onLocaleChange(const Locale('en'));
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.language),
                                  title: const Text('العربية'),
                                  onTap: () {
                                    widget.onLocaleChange(const Locale('ar'));
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      animation: _slideAnimations[4],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================== Diagnosis Page ==================
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
    final uri = Uri.parse(
        'https://mohashaher-backend-fastapi.hf.space/predict'); 
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
          _treatment =
              diseaseId != null ? diseaseMap["${diseaseId}_treatment"] : null;
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
                        ? Image.file(_imageFile!,
                            height: 220, fit: BoxFit.cover)
                        : Image.memory(_webImage!,
                            height: 220, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 20),
                if (_loading)
                  const CircularProgressIndicator(color: Colors.green),
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
                                  color: _disease!
                                          .toLowerCase()
                                          .contains("error")
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
  const ExpertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.contactExperts),
        backgroundColor: Colors.green[700],
      ),
      body: const Center(
        child: Text("👨‍🌾 Coming soon: Experts contact page"),
      ),
    );
  }
}

// ================== Pests & Diseases Page ==================
class PestsDiseasesPage extends StatelessWidget {
  const PestsDiseasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.pestsDiseases),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: kIsWeb
            ? DatabaseHelper.getCropsFromJson(context)
            : DatabaseHelper.getCrops(context),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final crops = snapshot.data!;
          return ListView.builder(
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final crop = crops[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(crop['name']),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final stages = kIsWeb
                        ? await DatabaseHelper.getStagesByCropFromJson(
                            context, crop['id'])
                        : await DatabaseHelper.getStagesByCrop(
                            context, crop['id']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StagesPage(crop: crop, stages: stages),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StagesPage extends StatelessWidget {
  final Map<String, dynamic> crop;
  final List<Map<String, dynamic>> stages;

  const StagesPage({super.key, required this.crop, required this.stages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(crop['name']),
        backgroundColor: Colors.green[700],
      ),
      body: ListView.builder(
        itemCount: stages.length,
        itemBuilder: (context, index) {
          final stage = stages[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(stage['name']),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final diseases = kIsWeb
                    ? await DatabaseHelper.getDiseasesByCropAndStageFromJson(
                        context, crop['id'], stage['id'])
                    : await DatabaseHelper.getDiseasesByCropAndStage(
                        context, crop['id'], stage['id']);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiseasesPage(
                      crop: crop,
                      stage: stage,
                      diseases: diseases,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DiseasesPage extends StatelessWidget {
  final Map<String, dynamic> crop;
  final Map<String, dynamic> stage;
  final List<Map<String, dynamic>> diseases;

  const DiseasesPage(
      {super.key,
      required this.crop,
      required this.stage,
      required this.diseases});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${crop['name']} - ${stage['name']}"),
        backgroundColor: Colors.green[700],
      ),
      body: ListView.builder(
        itemCount: diseases.length,
        itemBuilder: (context, index) {
          final disease = diseases[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: disease['default_image'] != null
                  ? Image.network(
                      disease['default_image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.bug_report, color: Colors.red),
              title: Text(disease['name']),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiseaseDetailsPage(disease: disease),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ================== Disease Details Page ==================
class DiseaseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> disease;
  const DiseaseDetailsPage({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(disease['name']),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (disease['default_image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(disease['default_image'],
                    height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text("${loc.symptoms}: ${disease['symptoms'] ?? ''}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("${loc.cause}: ${disease['cause'] ?? ''}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("${loc.preventiveMeasures}: ${disease['preventive_measures'] ?? ''}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("${loc.chemicalTreatment}: ${disease['chemical_treatment'] ?? ''}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("${loc.alternativeTreatment}: ${disease['alternative_treatment'] ?? ''}",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ================== Awareness Page ==================
class AwarenessPage extends StatelessWidget {
  const AwarenessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.awarenessGuide),
        backgroundColor: Colors.green[700],
      ),
      body: const Center(
        child: Text("📘 Awareness guide will be added soon"),
      ),
    );
  }
}
