import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class DiseaseDetailPage extends StatefulWidget {
  final int diseaseId;
  const DiseaseDetailPage({Key? key, required this.diseaseId}) : super(key: key);

  @override
  State<DiseaseDetailPage> createState() => _DiseaseDetailPageState();
}

class _DiseaseDetailPageState extends State<DiseaseDetailPage> {
  Map<String, dynamic>? disease;

  @override
  void initState() {
    super.initState();
    _loadDisease();
  }

  Future<void> _loadDisease() async {
    final data = await DatabaseHelper.getDiseaseDetails(widget.diseaseId);
    setState(() {
      disease = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (disease == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(disease!['name'] ?? "تفاصيل المرض")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (disease!['default_image'] != null)
              Center(
                child: Image.network(
                  "https://plantix.net/images/${disease!['default_image']}",
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text("الأعراض:", style: Theme.of(context).textTheme.titleMedium),
            Text(disease!['symptoms'] ?? ""),
            const Divider(),

            Text("التوصيات:", style: Theme.of(context).textTheme.titleMedium),
            if (disease!['alternative_treatment'] != null)
              Text("المكافحة العضوية:\n${disease!['alternative_treatment']}"),
            if (disease!['chemical_treatment'] != null)
              Text("المكافحة الكيميائية:\n${disease!['chemical_treatment']}"),
            const Divider(),

            Text("سبب المرض:", style: Theme.of(context).textTheme.titleMedium),
            Text(disease!['cause'] ?? ""),
            const Divider(),

            Text("إجراءات وقائية:", style: Theme.of(context).textTheme.titleMedium),
            Text(disease!['preventive_measures'] ?? ""),
          ],
        ),
      ),
    );
  }
}
