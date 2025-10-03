import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'dart:io';
import 'cached_network_image.dart'; // استورد الكلاس الذي أنشأناه

class PestsDiseasesPage extends StatefulWidget {
  @override
  _PestsDiseasesPageState createState() => _PestsDiseasesPageState();
}

class _PestsDiseasesPageState extends State<PestsDiseasesPage> {
  List<Map<String, dynamic>> _crops = [];
  List<Map<String, dynamic>> _stages = [];
  Map<int, List<Map<String, dynamic>>> _diseasesByStage = {};
  int? _selectedCropId;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    final db = await DatabaseHelper.database;
    final crops = await db.query('crops');
    setState(() => _crops = crops);
  }

  Future<void> _loadStagesAndDiseases(int cropId) async {
    final db = await DatabaseHelper.database;

    // تحميل كل المراحل
    final stages = await db.query('stages');

    // تحميل الأمراض حسب مرحلة
    Map<int, List<Map<String, dynamic>>> diseasesByStage = {};
    for (var stage in stages) {
      final diseases = await db.rawQuery('''
        SELECT d.*
        FROM diseases d
        JOIN disease_crop_stage dcs ON d.id = dcs.disease_id
        WHERE dcs.crop_id = ? AND dcs.stage_id = ?
      ''', [cropId, stage['id']]);

      diseasesByStage[stage['id']] = diseases;
    }

    setState(() {
      _selectedCropId = cropId;
      _stages = stages;
      _diseasesByStage = diseasesByStage;
    });
  }

  void _openDiseaseDetails(Map<String, dynamic> disease) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiseaseDetailsPage(disease: disease),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الآفات والأمراض")),
      body: Column(
        children: [
          // Dropdown لاختيار المحصول
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<int>(
              hint: const Text("اختر المحصول"),
              isExpanded: true,
              value: _selectedCropId,
              items: _crops.map((crop) {
                return DropdownMenuItem<int>(
                  value: crop['id'] as int,
                  child: Row(
                    children: [
                      if (crop['default_image'] != null)
                        CachedNetworkImage(
                          url: crop['default_image'],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(width: 10),
                      Text(crop['name']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) _loadStagesAndDiseases(val);
              },
            ),
          ),

          // قائمة المراحل والأمراض
          Expanded(
            child: _selectedCropId == null
                ? const Center(child: Text("اختر محصولاً لعرض المراحل والأمراض"))
                : ListView.builder(
                    itemCount: _stages.length,
                    itemBuilder: (context, index) {
                      final stage = _stages[index];
                      final diseases = _diseasesByStage[stage['id']] ?? [];
                      return ExpansionTile(
                        title: Text(stage['name']),
                        children: diseases.map((disease) {
                          return GestureDetector(
                            onTap: () => _openDiseaseDetails(disease),
                            child: Card(
                              margin: const EdgeInsets.all(8),
                              child: ListTile(
                                leading: disease['default_image'] != null
                                    ? CachedNetworkImage(
                                        url: disease['default_image'],
                                        width: 50,
                                        height: 50,
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
          ),
        ],
      ),
    );
  }
}

// صفحة تفاصيل المرض
class DiseaseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> disease;
  const DiseaseDetailsPage({Key? key, required this.disease}) : super(key: key);

  Widget _buildDetail(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                child: CachedNetworkImage(
                  url: disease['default_image'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            _buildDetail("الأعراض", disease['symptoms']),
            _buildDetail("سبب المرض", disease['cause']),
            _buildDetail("الإجراءات الوقائية", disease['preventive_measures']),
            _buildDetail("العلاج الكيميائي", disease['chemical_treatment']),
            _buildDetail("العلاج البديل", disease['alternative_treatment']),
          ],
        ),
      ),
    );
  }
}
