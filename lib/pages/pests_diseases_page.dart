import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class PestsDiseasesPage extends StatefulWidget {
  const PestsDiseasesPage({Key? key}) : super(key: key);

  @override
  _PestsDiseasesPageState createState() => _PestsDiseasesPageState();
}

class _PestsDiseasesPageState extends State<PestsDiseasesPage> {
  late Future<List<Map<String, dynamic>>> _cropsFuture;
  int? _selectedCropId;
  List<Map<String, dynamic>> _stages = [];

  @override
  void initState() {
    super.initState();
    _cropsFuture = DatabaseHelper.instance.getCrops();
  }

  Future<void> _loadStages(int cropId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT s.id, s.name 
      FROM stages s
      INNER JOIN disease_crop_stage dcs ON dcs.stage_id = s.id
      WHERE dcs.crop_id = ?
    ''', [cropId]);

    setState(() {
      _selectedCropId = cropId;
      _stages = results;
    });
  }

  Future<List<Map<String, dynamic>>> _loadDiseases(int cropId, int stageId) async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery('''
      SELECT d.*
      FROM diseases d
      INNER JOIN disease_crop_stage dcs ON dcs.disease_id = d.id
      WHERE dcs.crop_id = ? AND dcs.stage_id = ?
    ''', [cropId, stageId]);
  }

  void _openDiseaseDetails(Map<String, dynamic> disease) async {
    final details =
        await DatabaseHelper.instance.getDiseaseDetails(disease['id'] as int);

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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _cropsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final crops = snapshot.data!;
                if (crops.isEmpty) {
                  return const Text("لا توجد محاصيل في قاعدة البيانات");
                }
                return DropdownButton<int>(
                  hint: const Text("اختر المحصول"),
                  isExpanded: true,
                  value: _selectedCropId,
                  items: crops
                      .map((crop) => DropdownMenuItem<int>(
                            value: crop['id'] as int,
                            child: Row(
                              children: [
                                if (crop['image'] != null)
                                  Image.network(
                                    crop['image'],
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, _, __) =>
                                        const Icon(Icons.image_not_supported),
                                  ),
                                const SizedBox(width: 10),
                                Text(crop['name']),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _loadStages(val);
                    }
                  },
                );
              },
            ),
          ),

          // 📌 قائمة المراحل + الأمراض
          Expanded(
            child: _selectedCropId == null
                ? const Center(child: Text("اختر محصولاً لعرض الأمراض"))
                : ListView.builder(
                    itemCount: _stages.length,
                    itemBuilder: (context, index) {
                      final stage = _stages[index];
                      return ExpansionTile(
                        title: Text(stage['name']),
                        children: [
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _loadDiseases(
                                _selectedCropId!, stage['id'] as int),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final diseases = snapshot.data!;
                              if (diseases.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("لا توجد أمراض في هذه المرحلة"),
                                );
                              }
                              return Column(
                                children: diseases.map((disease) {
                                  return GestureDetector(
                                    onTap: () => _openDiseaseDetails(disease),
                                    child: Card(
                                      margin: const EdgeInsets.all(8),
                                      child: ListTile(
                                        leading: disease['default_image'] != null
                                            ? Image.network(
                                                disease['default_image'],
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                                errorBuilder: (ctx, _, __) =>
                                                    const Icon(Icons.bug_report,
                                                        color: Colors.redAccent),
                                              )
                                            : const Icon(Icons.bug_report,
                                                color: Colors.redAccent),
                                        title: Text(disease['name']),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
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
            if (disease['default_image'] != null)
              Center(
                child: Image.network(
                  disease['default_image'],
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
            const SizedBox(height: 16),
            _buildDetailSection("الأعراض", detail['symptoms']),
            _buildDetailSection("الأسباب", detail['cause']),
            _buildDetailSection("الإجراءات الوقائية", detail['preventive_measures']),
            _buildDetailSection("المكافحة العضوية", detail['alternative_treatment']),
            _buildDetailSection("المكافحة الكيميائية", detail['chemical_treatment']),
          ],
        ),
      ),
    );
  }
}
