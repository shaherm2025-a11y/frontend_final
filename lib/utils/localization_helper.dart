import 'package:flutter/widgets.dart';
import 'package:plant_diagnosis_app/l10n/app_localizations.dart';

class LocalizationHelper {
  static Map<String, String> getDiseaseMap(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return {
      // 🍏 Apple
      "Apple___Apple_scab": loc.apple_scab,
      "Apple___Apple_scab_treatment": loc.apple_scab_treatment,
      "Apple___apple_black_rot": loc.apple_black_rot,
      "Apple___apple_black_rot_treatment": loc.apple_black_rot_treatment,
      "Apple___apple_cedar_apple_rust": loc.apple_cedar_apple_rust,
      "Apple___apple_cedar_apple_rust_treatment": loc.apple_cedar_apple_rust_treatment,
      "Apple___apple_healthy": loc.apple_healthy,

      // 🫐 Blueberry
      "Blueberry___healthy": loc.blueberry_healthy,

      // 🍒 Cherry
      "Cherry_(including_sour)___Powdery_mildew": loc.cherry_powdery_mildew,
      "Cherry_(including_sour)___Powdery_mildew_treatment": loc.cherry_powdery_mildew_treatment,
      "Cherry_(including_sour)___healthy": loc.cherry_healthy,

      // 🌽 Corn (maize)
      "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot": loc.corn_gray_leaf_spot,
      "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot_treatment": loc.corn_gray_leaf_spot_treatment,
      "Corn_(maize)___Common_rust": loc.corn_common_rust,
      "Corn_(maize)___Common_rust_treatment": loc.corn_common_rust_treatment,
      "Corn_(maize)___Northern_Leaf_Blight": loc.corn_northern_leaf_blight,
      "Corn_(maize)___Northern_Leaf_Blight_treatment": loc.corn_northern_leaf_blight_treatment,
      "Corn_(maize)___healthy": loc.corn_healthy,

      // 🍇 Grape
      "Grape___Black_rot": loc.grape_black_rot,
      "Grape___Black_rot_treatment": loc.grape_black_rot_treatment,
      "Grape___Esca_(Black_Measles)": loc.grape_esca,
      "Grape___Esca_(Black_Measles)_treatment": loc.grape_esca_treatment,
      "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)": loc.grape_leaf_blight,
      "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)_treatment": loc.grape_leaf_blight_treatment,
      "Grape___healthy": loc.grape_healthy,

      // 🍑 Peach
      "Peach___Bacterial_spot": loc.peach_bacterial_spot,
      "Peach___Bacterial_spot_treatment": loc.peach_bacterial_spot_treatment,
      "Peach___healthy": loc.peach_healthy,

      // 🥔 Potato
      "Potato___Early_blight": loc.potato_early_blight,
      "Potato___Early_blight_treatment": loc.potato_early_blight_treatment,
      "Potato___Late_blight": loc.potato_late_blight,
      "Potato___Late_blight_treatment": loc.potato_late_blight_treatment,
      "Potato___healthy": loc.potato_healthy,

      // 🌶️ Pepper bell
      "Pepper,_bell___Bacterial_spot": loc.pepper_bacterial_spot,
      "Pepper,_bell___Bacterial_spot_treatment": loc.pepper_bacterial_spot_treatment,
      "Pepper,_bell___healthy": loc.pepper_healthy,

      // 🍅 Tomato
      "Tomato___Bacterial_spot": loc.tomato_bacterial_spot,
      "Tomato___Bacterial_spot_treatment": loc.tomato_bacterial_spot_treatment,
      "Tomato___Early_blight": loc.tomato_early_blight,
      "Tomato___Early_blight_treatment": loc.tomato_early_blight_treatment,
      "Tomato___Late_blight": loc.tomato_late_blight,
      "Tomato___Late_blight_treatment": loc.tomato_late_blight_treatment,
      "Tomato___Leaf_Mold": loc.tomato_leaf_mold,
      "Tomato___Leaf_Mold_treatment": loc.tomato_leaf_mold_treatment,
      "Tomato___Septoria_leaf_spot": loc.tomato_septoria_leaf_spot,
      "Tomato___Septoria_leaf_spot_treatment": loc.tomato_septoria_leaf_spot_treatment,
      "Tomato___Spider_mites Two-spotted_spider_mite": loc.tomato_spider_mites,
      "Tomato___Spider_mites Two-spotted_spider_mite_treatment": loc.tomato_spider_mites_treatment,
      "Tomato___Target_Spot": loc.tomato_target_spot,
      "Tomato___Target_Spot_treatment": loc.tomato_target_spot_treatment,
      "Tomato___Tomato_Yellow_Leaf_Curl_Virus": loc.tomato_yellow_leaf_curl,
      "Tomato___Tomato_Yellow_Leaf_Curl_Virus_treatment": loc.tomato_yellow_leaf_curl_treatment,
      "Tomato___Tomato_mosaic_virus": loc.tomato_mosaic_virus,
      "Tomato___Tomato_mosaic_virus_treatment": loc.tomato_mosaic_virus_treatment,
      "Tomato___healthy": loc.tomato_healthy,

      // 🎃 Squash
      "Squash___Powdery_mildew": loc.squash_powdery_mildew,
      "Squash___Powdery_mildew_treatment": loc.squash_powdery_mildew_treatment,

      // 🍊 Orange
      "Orange___Haunglongbing_(Citrus_greening)": loc.orange_hlb,
      "Orange___Haunglongbing_(Citrus_greening)_treatment": loc.orange_hlb_treatment,

      // 🍓 Strawberry
      "Strawberry___Leaf_scorch": loc.strawberry_leaf_scorch,
      "Strawberry___Leaf_scorch_treatment": loc.strawberry_leaf_scorch_treatment,
      "Strawberry___healthy": loc.strawberry_healthy,

      // 🌱 Soybean
      "Soybean___healthy": loc.soybean_healthy,

      // 🍇 Raspberry
      "Raspberry___healthy": loc.raspberry_healthy,
    };
  }
}
