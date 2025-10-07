import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;   // ✅ استيراد path مع alias
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'utils/localization_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// ================= Database Helper =================
class DatabaseHelper {
  static Database? _db;

  // ✅ اللغة الحالية
  static String appLanguageCode = 'en'; // الافتراضي
  static bool get isArabic => appLanguageCode == 'ar';

  // ✅ الأعمدة حسب اللغة
  static String get nameCol => isArabic ? 'name' : 'name_en';
  static String get symptomsCol => isArabic ? 'symptoms' : 'symptoms_en';
  static String get causeCol => isArabic ? 'cause' : 'cause_en';
  static String get preventiveCol =>
      isArabic ? 'preventive_measures' : 'preventive_measures_en';
  static String get chemicalCol =>
      isArabic ? 'chemical_treatment' : 'chemical_treatment_en';
  static String get alternativeCol =>
      isArabic ? 'alternative_treatment' : 'alternative_treatment_en';

  // ✅ قاعدة البيانات (للهاتف والويندوز)
  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;
    if (kIsWeb) throw Exception("Web uses JSON, not SQLite");

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = p.join(documentsDirectory.path, "plantix_final.db");

    // 📌 إذا ما كان الملف موجود انسخه من assets
    bool exists = await File(path).exists();
    if (!exists) {
      print("📌 نسخ قاعدة البيانات من assets لأول مرة...");
      ByteData data = await rootBundle.load("assets/plantix_final.db");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(path, readOnly: true);
    return _db!;
  }

  // ✅ قراءة المحاصيل
  static Future<List<Map<String, dynamic>>> getCrops() async {
    if (kIsWeb) throw Exception("Use JSON on Web");
    final db = await getDatabase();
    return await db.query(
      'crops',
      columns: ['id', nameCol + ' as name', 'name_en'],
    );
  }

 // ✅ قراءة المراحل حسب المحصول (مع علاقة جدول الربط)
static Future<List<Map<String, dynamic>>> getStagesByCrop(int cropId) async {
  final db = await getDatabase();
  return await db.rawQuery('''
    SELECT DISTINCT s.id, s.$nameCol AS name
    FROM stages s
    JOIN disease_crop_stage dcs ON dcs.stage_id = s.id
    WHERE dcs.crop_id = ?
    ORDER BY s.id
  ''', [cropId]);
}

// ✅ قراءة الأمراض حسب المحصول والمرحلة (كما هي لكن منضبطة)
static Future<List<Map<String, dynamic>>> getDiseasesByCropAndStage(
    int cropId, int stageId) async {
  final db = await getDatabase();
  return await db.rawQuery('''
    SELECT DISTINCT d.id,
           d.$nameCol AS name,
           d.default_image,
           d.$symptomsCol AS symptoms,
           d.$causeCol AS cause,
           d.$preventiveCol AS preventive_measures,
           d.$chemicalCol AS chemical_treatment,
           d.$alternativeCol AS alternative_treatment
    FROM diseases d
    JOIN disease_crop_stage ds ON ds.disease_id = d.id
    WHERE ds.stage_id = ? AND ds.crop_id = ?
  ''', [stageId, cropId]);
}

  // ================= Web JSON =================
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

  // ✅ المحاصيل من JSON
  static Future<List<Map<String, dynamic>>> getCropsFromJson() async {
    return _jsonData.values.map((c) => {
          'id': c['id'],
          'name': isArabic ? c['name'] : c['name_en'],
          'name_en': c['name_en'],
        }).toList();
  }

  // ✅ المراحل من JSON
  static Future<List<Map<String, dynamic>>> getStagesByCropFromJson(
      int cropId) async {
    final crop = _jsonData[cropId];
    if (crop == null) return [];
    final stages = crop['stages'] as List<dynamic>;
    return stages.map((s) => {
          'id': s['id'],
          'name': isArabic ? s['name'] : s['name_en'],
          'diseases': s['diseases'],
        }).toList();
  }

  // ✅ الأمراض من JSON
  static Future<List<Map<String, dynamic>>> getDiseasesByCropAndStageFromJson(
      int cropId, int stageId) async {
    final stages = await getStagesByCropFromJson(cropId);
    final stage =
        stages.firstWhere((s) => s['id'] == stageId, orElse: () => {});
    if (stage.isEmpty) return [];
    final diseases = stage['diseases'] as List<dynamic>;
    return diseases.map((d) => {
          'id': d['id'],
          'name': isArabic ? d['name'] : d['name_en'],
          'default_image': d['default_image'],
          'symptoms': isArabic ? d['symptoms'] : d['symptoms_en'],
          'cause': isArabic ? d['cause'] : d['cause_en'],
          'preventive_measures': (isArabic
                  ? d['preventive_measures']
                  : d['preventive_measures_en'])
              .join(", "),
          'chemical_treatment':
              isArabic ? d['chemical_treatment'] : d['chemical_treatment_en'],
          'alternative_treatment': isArabic
              ? d['alternative_treatment']
              : d['alternative_treatment_en'],
        }).toList();
  }
}

// ================== Main App ==================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await DatabaseHelper.loadJson("assets/plant_relational.json");
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  void _setLocale(Locale locale) {
  setState(() {
    _locale = locale;
    DatabaseHelper.appLanguageCode = locale.languageCode; // هنا التحديث
  });
}


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

    // ✅ Logo Animation
    _logoController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation =
        CurvedAnimation(parent: _logoController, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoController.forward();

    // ✅ Buttons Animation
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
            backgroundColor: Colors.green[200], // ✅ لون موحّد
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
            colors: [Color(0xFFE8F5E9), Color(0xFFFFFFFF)], // 🌿 خلفية مريحة
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
                    // ✅ Logo
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset("assets/logo.png", fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ✅ Welcome text
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

                    // ✅ Buttons with slide animation
                    _buildAnimatedButton(
                      text: t.diagnosePlant,
                      icon: Icons.search,
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => DiagnosisPage()));
                      },
                      animation: _slideAnimations[0],
                    ),
                    _buildAnimatedButton(
                      text: t.contactExperts,
                      icon: Icons.person,
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ExpertsPage()));
                      },
                      animation: _slideAnimations[1],
                    ),
                    _buildAnimatedButton(
                      text: t.pestsDiseases, // ✅ مترجم بدل النص الثابت
                      icon: Icons.bug_report,
                      onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PestsDiseasesPage()),
                        );
                        },
                      animation: _slideAnimations[2],
                    ),

                    _buildAnimatedButton(
                      text: t.awarenessGuide,
                      icon: Icons.menu_book,
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => AwarenessPage()));
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

  // 📌 اختيار صورة
  Future<void> pickImage() async {
  // 📌 الحالة الخاصة بالويب والويندوز: اختيار صورة من الملفات (وليس الكاميرا)
  if (kIsWeb || Platform.isWindows) {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (kIsWeb)
          _webImage = bytes;
        else
          _imageFile = File(pickedFile.path);
      });
      await diagnosePlant(bytes, pickedFile.name);
    }
  } 
  // 📱 الموبايل: التقاط صورة بالكاميرا
  else {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() => _imageFile = file);
      await diagnosePlant(await file.readAsBytes(), pickedFile.name);
    }
  }
}

  // 📌 API
  Future<void> diagnosePlant(Uint8List imageBytes, String filename) async {
    final uri = Uri.parse('https://mohashaher-backend-fastapi.hf.space/predict'); // عدّل الرابط
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
		print("📌 Status: ${response.statusCode}");
        print("📌 Response: $respStr");
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
    } catch (e, stacktrace) {
      print("❌ Error: $e");
      print("📌 Stacktrace: $stacktrace");
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
                // زر اختيار صورة
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

                // صورة مختارة
                if (_imageFile != null || _webImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, height: 220, fit: BoxFit.cover)
                        : Image.memory(_webImage!, height: 220, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 20),

                // تحميل
                if (_loading) const CircularProgressIndicator(color: Colors.green),

                // النتائج
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
  const ExpertsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.experts)),
      body: Center(child: Text(t.expertsPlaceholder)),
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
    print("📌 Crops Loaded: $data"); // ← تحقق
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
          ? await DatabaseHelper.getDiseasesByCropAndStageFromJson(
              cropId, stage['id'])
          : await DatabaseHelper.getDiseasesByCropAndStage(
              cropId, stage['id']);
      setState(() => stageDiseases[stage['id']] = diseases);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // ✅ الترجمة

    return Scaffold(
      appBar: AppBar(title: Text(t.pestsDiseases)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔽 القائمة المنسدلة للمحاصيل
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: t.selectCrop,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: selectedCropId,
              items: crops.map((crop) {
                final imageName = crop['name_en']?.toString().toLowerCase() ?? '';
                // ✅ عرض اسم المحصول حسب اللغة
                final cropName = Localizations.localeOf(context).languageCode == 'ar'
                    ? crop['name']
                    : crop['name_en'] ?? crop['name'];

                return DropdownMenuItem<int>(
                  value: crop['id'],
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/plantix_icons/$imageName.jpg',
                        width: 32,
                        height: 32,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported, size: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(cropName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedCropId = value);
                  _loadStages(value);
                }
              },
            ),
            const SizedBox(height: 20),

            // 📌 عرض المراحل والأمراض
            Expanded(
              child: selectedCropId == null
                  ? Center(child: Text(t.noCropSelected))
                  : ListView(
                      children: stages.map((stage) {
                        final diseases = stageDiseases[stage['id']] ?? [];
                        return ExpansionTile(
                          title: Text("${t.stage}: ${stage['name']}"),
                          children: diseases.isEmpty
                              ? [ListTile(title: Text(t.noDiseases))]
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
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(Icons.bug_report),
                                            )
                                          : const Icon(Icons.bug_report),
                                      title: Text(disease['name'] ?? ""),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DiseaseDetailsPage(
                                              disease: disease,
                                              details: disease,
                                            ),
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
      ),
    );
  }
}

// ================== Disease Details ==================
class DiseaseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> disease;
  final Map<String, dynamic> details;

  const DiseaseDetailsPage({
    Key? key,
    required this.disease,
    required this.details,
  }) : super(key: key);

  Widget _buildDetailSection(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(disease['name'] ?? t.diseaseDetails),
      ),
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
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
            const SizedBox(height: 16),
            _buildDetailSection(t.symptoms, disease['symptoms']),
            _buildDetailSection(t.cause, disease['cause']),
            _buildDetailSection(
                t.preventiveMeasures, disease['preventive_measures']),
            _buildDetailSection(
                t.chemicalTreatment, disease['chemical_treatment']),
            _buildDetailSection(
                t.alternativeTreatment, disease['alternative_treatment']),
          ],
        ),
      ),
    );
  }
}

// ================== Awareness Page ==================
class AwarenessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.awarenessGuide)),
      body: const Center(child: Text("صفحة التوعية")),
    );
  }
}
