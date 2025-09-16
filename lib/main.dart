import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:plant_diagnosis_app/utils/localization_helper.dart';
import '../db/database_helper.dart';

import 'l10n/app_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en');

  void _setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Diagnosis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Arial'),
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
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
              // ✅ زر الآفات والأمراض بدلاً من منتجاتنا
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



class PestsDiseasesPage extends StatefulWidget {
  @override
  _PestsDiseasesPageState createState() => _PestsDiseasesPageState();
}

class _PestsDiseasesPageState extends State<PestsDiseasesPage> {
  List<Map<String, dynamic>> _crops = [];
  List<Map<String, dynamic>> _diseases = [];
  int? _selectedCropId;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    final db = await DatabaseHelper.database;
    final crops = await db.query('crops');
	print("✅ Loaded crops: $crops");
    setState(() {
      _crops = crops;
    });
  }

  Future<void> _loadDiseases(int cropId) async {
    final db = await DatabaseHelper.database;
    final diseases =
        await db.query('diseases', where: 'crop_id = ?', whereArgs: [cropId]);
    setState(() {
      _selectedCropId = cropId;
      _diseases = diseases;
    });
  }

  void _openDiseaseDetails(Map<String, dynamic> disease) async {
    final db = await DatabaseHelper.database;
    final details = await db.query('disease_details',
        where: 'disease_id = ?', whereArgs: [disease['id']]);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiseaseDetailsPage(
          disease: disease,
          details: details,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الآفات والأمراض")),
      body: Column(
        children: [
          // 🔽 Dropdown لاختيار المحصول
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<int>(
              hint: const Text("اختر المحصول"),
              isExpanded: true,
              value: _selectedCropId,
              items: _crops
                  .map((crop) => DropdownMenuItem<int>(
                        value: crop['id'] as int,
                        child: Row(
                          children: [
                            if (crop['image'] != null)
                              Image.asset(
                                crop['image'],
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                            const SizedBox(width: 10),
                            Text(crop['name']),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  _loadDiseases(val);
                }
              },
            ),
          ),

          // 🦠 قائمة الأمراض
          Expanded(
            child: _diseases.isEmpty
                ? const Center(child: Text("اختر محصولاً لعرض الأمراض"))
                : ListView.builder(
                    itemCount: _diseases.length,
                    itemBuilder: (context, index) {
                      final disease = _diseases[index];
                      return GestureDetector(
                        onTap: () => _openDiseaseDetails(disease),
                        child: Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: disease['image'] != null
                                ? Image.asset(
                                    disease['image'],
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.bug_report,
                                    color: Colors.redAccent),
                            title: Text(disease['name']),
                            subtitle: Text(disease['stage'] ?? ""),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class DiseaseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> disease;
  final List<Map<String, dynamic>> details;

  const DiseaseDetailsPage(
      {Key? key, required this.disease, required this.details})
      : super(key: key);

  Widget _buildDetailSection(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = details.isNotEmpty ? details.first : {};

    return Scaffold(
      appBar: AppBar(title: Text(disease['name'] ?? "تفاصيل المرض")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (disease['image'] != null)
              Center(
                child: Image.asset(
                  disease['image'],
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            _buildDetailSection("الأعراض", detail['symptoms']),
            _buildDetailSection("الأسباب", detail['causes']),
            _buildDetailSection("الإجراءات الوقائية", detail['prevention']),
            _buildDetailSection("العلاج", detail['treatment']),
          ],
        ),
      ),
    );
  }
}

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
