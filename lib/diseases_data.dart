import 'main.dart';

//
// ✅ الطماطم
//
final tomatoDiseases = {
  "الشتلات": [
    DiseaseModel(
      name: "الذبول الفطري",
      image: "assets/images/tomato_wilt.png",
      symptoms: ["اصفرار الأوراق السفلية", "ذبول تدريجي", "تلون الأوعية الناقلة بني"],
      causes: ["فطر Fusarium oxysporum"],
      prevention: ["زراعة أصناف مقاومة", "تعقيم التربة", "تجنب الري الزائد"],
      treatment: ["مبيدات فطرية جهازية (بنوميل، كاربندازيم)"],
    ),
  ],
  "النمو": [
    DiseaseModel(
      name: "البياض الدقيقي",
      image: "assets/images/tomato_powder.png",
      symptoms: ["بقع بيضاء مسحوقية", "ضعف النمو", "جفاف الأوراق"],
      causes: ["فطر Oidium lycopersici"],
      prevention: ["زراعة متباعدة", "تهوية جيدة"],
      treatment: ["رش الكبريت الميكروني", "مبيدات فطرية مثل بافستين"],
    ),
  ],
  "الإزهار": [
    DiseaseModel(
      name: "لفحة الأوراق المبكرة",
      image: "assets/images/tomato_early_blight.png",
      symptoms: ["بقع دائرية بنية", "هالات صفراء حول البقع"],
      causes: ["فطر Alternaria solani"],
      prevention: ["تجنب كثافة الزراعة", "رش وقائي"],
      treatment: ["مبيدات نحاسية", "مانكوزيب"],
    ),
  ],
  "الإثمار": [
    DiseaseModel(
      name: "العفن الطري البكتيري",
      image: "assets/images/tomato_soft_rot.png",
      symptoms: ["عفن رطب على الثمار", "رائحة كريهة"],
      causes: ["بكتيريا Erwinia carotovora"],
      prevention: ["تجنب الجروح", "التخزين الجيد"],
      treatment: ["إزالة الثمار المصابة", "استخدام مبيدات بكتيرية"],
    ),
  ],
};

//
// ✅ البطاطس
//
final potatoDiseases = {
  "النمو": [
    DiseaseModel(
      name: "اللفحة المتأخرة",
      image: "assets/images/potato_blight.png",
      symptoms: ["بقع بنية على الأوراق", "عفن الدرنات"],
      causes: ["فطر Phytophthora infestans"],
      prevention: ["استخدام أصناف مقاومة", "تجنب الري الغزير"],
      treatment: ["مبيدات نحاسية (أوكسي كلوريد النحاس)", "مانكوزيب"],
    ),
  ],
  "الحصاد": [
    DiseaseModel(
      name: "العفن الجاف",
      image: "assets/images/potato_dry_rot.png",
      symptoms: ["جفاف وتعفن داخلي للدرنات"],
      causes: ["فطر Fusarium spp."],
      prevention: ["تخزين في مكان جاف وبارد", "تجنب الجروح"],
      treatment: ["معاملة الدرنات بالمطهرات الفطرية"],
    ),
  ],
};

//
// ✅ القمح
//
final wheatDiseases = {
  "النمو": [
    DiseaseModel(
      name: "الصدأ الأصفر",
      image: "assets/images/yellow_rust.png",
      symptoms: ["خطوط صفراء على الأوراق", "ضعف النمو"],
      causes: ["فطر Puccinia striiformis"],
      prevention: ["زراعة أصناف مقاومة", "عدم الزراعة في مواعيد متأخرة"],
      treatment: ["رش مبيدات جهازية مثل تيبوكونازول"],
    ),
    DiseaseModel(
      name: "البياض الدقيقي",
      image: "assets/images/wheat_powder.png",
      symptoms: ["بقع بيضاء مسحوقية على الأوراق"],
      causes: ["فطر Blumeria graminis"],
      prevention: ["زراعة أصناف مقاومة", "تهوية جيدة"],
      treatment: ["مبيدات فطرية جهازية"],
    ),
  ],
};

//
// ✅ الذرة
//
final maizeDiseases = {
  "النمو": [
    DiseaseModel(
      name: "الصدأ الشائع",
      image: "assets/images/maize_rust.png",
      symptoms: ["بقع برتقالية/بنية على الأوراق"],
      causes: ["فطر Puccinia sorghi"],
      prevention: ["زراعة أصناف مقاومة"],
      treatment: ["رش مبيدات فطرية نحاسية"],
    ),
  ],
};

//
// ✅ الخيار
//
final cucumberDiseases = {
  "النمو": [
    DiseaseModel(
      name: "البياض الزغبي",
      image: "assets/images/cucumber_downy.png",
      symptoms: ["بقع صفراء على الأوراق", "طبقة رمادية على السطح السفلي"],
      causes: ["فطر Pseudoperonospora cubensis"],
      prevention: ["زراعة متباعدة", "تهوية جيدة"],
      treatment: ["مبيدات فطرية مثل مانكوزيب"],
    ),
  ],
};

//
// ✅ الفلفل
//
final pepperDiseases = {
  "النمو": [
    DiseaseModel(
      name: "تبقع الأوراق البكتيري",
      image: "assets/images/pepper_leaf_spot.png",
      symptoms: ["بقع صغيرة مائية على الأوراق", "تتحول لبنية"],
      causes: ["بكتيريا Xanthomonas campestris"],
      prevention: ["استخدام بذور نظيفة", "تجنب الري بالرش"],
      treatment: ["رش مبيدات نحاسية"],
    ),
  ],
};

//
// ✅ التفاح
//
final appleDiseases = {
  "الإزهار": [
    DiseaseModel(
      name: "لفحة النار البكتيرية",
      image: "assets/images/apple_fire_blight.png",
      symptoms: ["ذبول الأزهار", "تحول الفروع للون الأسود"],
      causes: ["بكتيريا Erwinia amylovora"],
      prevention: ["تقليم الأجزاء المصابة", "تجنب زيادة التسميد النيتروجيني"],
      treatment: ["رش ستربتومايسين"],
    ),
  ],
};

//
// ✅ العنب
//
final grapeDiseases = {
  "النمو": [
    DiseaseModel(
      name: "البياض الزغبي",
      image: "assets/images/grape_downy.png",
      symptoms: ["بقع صفراء على السطح العلوي", "زغب أبيض أسفل الورقة"],
      causes: ["فطر Plasmopara viticola"],
      prevention: ["زراعة جيدة التهوية", "رش وقائي"],
      treatment: ["مبيدات نحاسية"],
    ),
  ],
};

//
// ✅ الفراولة
//
final strawberryDiseases = {
  "النمو": [
    DiseaseModel(
      name: "العفن الرمادي",
      image: "assets/images/strawberry_grey_mold.png",
      symptoms: ["عفن رمادي على الثمار", "تعفن الأزهار"],
      causes: ["فطر Botrytis cinerea"],
      prevention: ["تحسين التهوية", "تجنب الري بالرش"],
      treatment: ["مبيدات فطرية مثل روفراكس"],
    ),
  ],
};

//
// ✅ الأرز
//
final riceDiseases = {
  "النمو": [
    DiseaseModel(
      name: "لفحة الأرز",
      image: "assets/images/rice_blast.png",
      symptoms: ["بقع بيضاوية بنية على الأوراق"],
      causes: ["فطر Magnaporthe oryzae"],
      prevention: ["زراعة أصناف مقاومة", "إدارة مياه جيدة"],
      treatment: ["مبيدات فطرية جهازية مثل تريازول"],
    ),
  ],
};
