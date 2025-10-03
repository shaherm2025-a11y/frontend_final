import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'pages/pests_diseases_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Diagnosis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Arial'),
      home: PestsDiseasesPage(), // التطبيق يفتح مباشرة على صفحة الآفات والأمراض
    );
  }
}
