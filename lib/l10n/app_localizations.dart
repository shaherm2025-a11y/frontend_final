import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @welcomeText.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Plant Diagnosis App!'**
  String get welcomeText;

  /// No description provided for @diagnosePlant.
  ///
  /// In en, this message translates to:
  /// **'Diagnose Plant'**
  String get diagnosePlant;

  /// No description provided for @contactExperts.
  ///
  /// In en, this message translates to:
  /// **'Contact Experts'**
  String get contactExperts;

  /// No description provided for @ourProducts.
  ///
  /// In en, this message translates to:
  /// **'Our Products'**
  String get ourProducts;

  /// No description provided for @awarenessGuide.
  ///
  /// In en, this message translates to:
  /// **'Agricultural Awareness'**
  String get awarenessGuide;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @plantDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Plant Diagnosis'**
  String get plantDiagnosis;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select an image'**
  String get selectImage;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get result;

  /// No description provided for @treatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get treatment;

  /// No description provided for @experts.
  ///
  /// In en, this message translates to:
  /// **'Experts'**
  String get experts;

  /// No description provided for @expertsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Expert support will be available soon.'**
  String get expertsPlaceholder;

  /// No description provided for @productsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Products list coming soon.'**
  String get productsPlaceholder;

  /// No description provided for @awarenessPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Awareness content will be added.'**
  String get awarenessPlaceholder;

  /// No description provided for @basicFarming.
  ///
  /// In en, this message translates to:
  /// **'Basic Farming'**
  String get basicFarming;

  /// No description provided for @soilAdvice.
  ///
  /// In en, this message translates to:
  /// **'• Choose the right soil: Test every 2 years.'**
  String get soilAdvice;

  /// No description provided for @sunAdvice.
  ///
  /// In en, this message translates to:
  /// **'• Ensure sunlight exposure: 6-8 hours daily.'**
  String get sunAdvice;

  /// No description provided for @wateringAdvice.
  ///
  /// In en, this message translates to:
  /// **'• Water regularly: When top 2–3 cm of soil is dry.'**
  String get wateringAdvice;

  /// No description provided for @diseasePrevention.
  ///
  /// In en, this message translates to:
  /// **'Plant Disease Prevention'**
  String get diseasePrevention;

  /// No description provided for @toolSanitation.
  ///
  /// In en, this message translates to:
  /// **'• Disinfect tools before planting.'**
  String get toolSanitation;

  /// No description provided for @cropRotation.
  ///
  /// In en, this message translates to:
  /// **'• Practice crop rotation yearly.'**
  String get cropRotation;

  /// No description provided for @seedSelection.
  ///
  /// In en, this message translates to:
  /// **'• Use certified healthy seeds.'**
  String get seedSelection;

  /// No description provided for @naturalPestControl.
  ///
  /// In en, this message translates to:
  /// **'Natural Pest Control'**
  String get naturalPestControl;

  /// No description provided for @plantRepellents.
  ///
  /// In en, this message translates to:
  /// **'• Grow pest-repelling plants (e.g., mint, basil).'**
  String get plantRepellents;

  /// No description provided for @organicSprays.
  ///
  /// In en, this message translates to:
  /// **'• Use organic sprays like neem oil.'**
  String get organicSprays;

  /// No description provided for @beneficialInsects.
  ///
  /// In en, this message translates to:
  /// **'• Encourage beneficial insects (e.g., ladybugs).'**
  String get beneficialInsects;

  /// No description provided for @commonDiseases.
  ///
  /// In en, this message translates to:
  /// **'Common Plant Diseases and Treatment'**
  String get commonDiseases;

  /// No description provided for @disease.
  ///
  /// In en, this message translates to:
  /// **'Disease'**
  String get disease;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @seasonalTips.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Farming Tips'**
  String get seasonalTips;

  /// No description provided for @spring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get spring;

  /// No description provided for @summer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get summer;

  /// No description provided for @autumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get autumn;

  /// No description provided for @winter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get winter;

  /// No description provided for @spring1.
  ///
  /// In en, this message translates to:
  /// **'Prune flowering plants.'**
  String get spring1;

  /// No description provided for @spring2.
  ///
  /// In en, this message translates to:
  /// **'Add organic compost.'**
  String get spring2;

  /// No description provided for @summer1.
  ///
  /// In en, this message translates to:
  /// **'Water early in the morning.'**
  String get summer1;

  /// No description provided for @summer2.
  ///
  /// In en, this message translates to:
  /// **'Use mulch to retain moisture.'**
  String get summer2;

  /// No description provided for @autumn1.
  ///
  /// In en, this message translates to:
  /// **'Plant winter crops.'**
  String get autumn1;

  /// No description provided for @autumn2.
  ///
  /// In en, this message translates to:
  /// **'Clean up old crop residues.'**
  String get autumn2;

  /// No description provided for @winter1.
  ///
  /// In en, this message translates to:
  /// **'Protect sensitive plants with greenhouses.'**
  String get winter1;

  /// No description provided for @winter2.
  ///
  /// In en, this message translates to:
  /// **'Reduce watering to avoid root rot.'**
  String get winter2;

  /// No description provided for @resources.
  ///
  /// In en, this message translates to:
  /// **'Trusted Resources'**
  String get resources;

  /// No description provided for @youtubeChannels.
  ///
  /// In en, this message translates to:
  /// **'• YouTube channels: \'Garden Answer\', \'Epic Gardening\''**
  String get youtubeChannels;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @contactExpertsInfo.
  ///
  /// In en, this message translates to:
  /// **'• Use the \'Contact Experts\' feature in the app.'**
  String get contactExpertsInfo;

  /// No description provided for @powderyMildew.
  ///
  /// In en, this message translates to:
  /// **'Powdery mildew'**
  String get powderyMildew;

  /// No description provided for @powderyMildewSymptoms.
  ///
  /// In en, this message translates to:
  /// **'White layer on leaves'**
  String get powderyMildewSymptoms;

  /// No description provided for @powderyMildewTreatment.
  ///
  /// In en, this message translates to:
  /// **'Good ventilation + sulfur spray'**
  String get powderyMildewTreatment;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @pick_camera.
  ///
  /// In en, this message translates to:
  /// **'Pick from Camera'**
  String get pick_camera;

  /// No description provided for @lateBlight.
  ///
  /// In en, this message translates to:
  /// **'Late blight'**
  String get lateBlight;

  /// No description provided for @lateBlightSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Black spots on tomatoes'**
  String get lateBlightSymptoms;

  /// No description provided for @lateBlightTreatment.
  ///
  /// In en, this message translates to:
  /// **'Copper fungicide + remove infected'**
  String get lateBlightTreatment;

  /// No description provided for @rootRot.
  ///
  /// In en, this message translates to:
  /// **'Root rot'**
  String get rootRot;

  /// No description provided for @rootRotSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Yellowing and gradual death'**
  String get rootRotSymptoms;

  /// No description provided for @rootRotTreatment.
  ///
  /// In en, this message translates to:
  /// **'Improve drainage + reduce watering'**
  String get rootRotTreatment;

  /// No description provided for @aphids.
  ///
  /// In en, this message translates to:
  /// **'Aphids'**
  String get aphids;

  /// No description provided for @aphidsSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Small insects sucking sap'**
  String get aphidsSymptoms;

  /// No description provided for @aphidsTreatment.
  ///
  /// In en, this message translates to:
  /// **'Neem spray + soap water'**
  String get aphidsTreatment;

  /// No description provided for @apple_scab.
  ///
  /// In en, this message translates to:
  /// **'Apple Scab'**
  String get apple_scab;

  /// No description provided for @apple_scab_treatment.
  ///
  /// In en, this message translates to:
  /// **'Use resistant varieties, apply fungicides, and prune infected leaves.'**
  String get apple_scab_treatment;

  /// No description provided for @apple_black_rot.
  ///
  /// In en, this message translates to:
  /// **'Apple Black Rot'**
  String get apple_black_rot;

  /// No description provided for @apple_black_rot_treatment.
  ///
  /// In en, this message translates to:
  /// **'Remove mummified fruit, apply fungicides, and improve air circulation.'**
  String get apple_black_rot_treatment;

  /// No description provided for @apple_cedar_apple_rust.
  ///
  /// In en, this message translates to:
  /// **'Apple Cedar Rust'**
  String get apple_cedar_apple_rust;

  /// No description provided for @apple_cedar_apple_rust_treatment.
  ///
  /// In en, this message translates to:
  /// **'Remove nearby cedar trees, use resistant cultivars, and apply fungicides.'**
  String get apple_cedar_apple_rust_treatment;

  /// No description provided for @apple_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Apple'**
  String get apple_healthy;

  /// No description provided for @blueberry_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Blueberry'**
  String get blueberry_healthy;

  /// No description provided for @cherry_powdery_mildew.
  ///
  /// In en, this message translates to:
  /// **'Cherry Powdery Mildew'**
  String get cherry_powdery_mildew;

  /// No description provided for @cherry_powdery_mildew_treatment.
  ///
  /// In en, this message translates to:
  /// **'Apply sulfur-based fungicides, prune affected parts, and ensure proper spacing.'**
  String get cherry_powdery_mildew_treatment;

  /// No description provided for @cherry_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Cherry'**
  String get cherry_healthy;

  /// No description provided for @corn_gray_leaf_spot.
  ///
  /// In en, this message translates to:
  /// **'Corn Gray Leaf Spot'**
  String get corn_gray_leaf_spot;

  /// No description provided for @corn_gray_leaf_spot_treatment.
  ///
  /// In en, this message translates to:
  /// **'Use resistant hybrids, rotate crops, and apply fungicides.'**
  String get corn_gray_leaf_spot_treatment;

  /// No description provided for @corn_common_rust.
  ///
  /// In en, this message translates to:
  /// **'Corn Common Rust'**
  String get corn_common_rust;

  /// No description provided for @corn_common_rust_treatment.
  ///
  /// In en, this message translates to:
  /// **'Plant resistant varieties, monitor crops, and apply fungicides if severe.'**
  String get corn_common_rust_treatment;

  /// No description provided for @corn_northern_leaf_blight.
  ///
  /// In en, this message translates to:
  /// **'Corn Northern Leaf Blight'**
  String get corn_northern_leaf_blight;

  /// No description provided for @corn_northern_leaf_blight_treatment.
  ///
  /// In en, this message translates to:
  /// **'Rotate crops, apply fungicides, and avoid continuous corn planting.'**
  String get corn_northern_leaf_blight_treatment;

  /// No description provided for @corn_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Corn'**
  String get corn_healthy;

  /// No description provided for @grape_black_rot.
  ///
  /// In en, this message translates to:
  /// **'Grape Black Rot'**
  String get grape_black_rot;

  /// No description provided for @grape_black_rot_treatment.
  ///
  /// In en, this message translates to:
  /// **'Remove infected parts, apply fungicides, and ensure good ventilation.'**
  String get grape_black_rot_treatment;

  /// No description provided for @grape_esca.
  ///
  /// In en, this message translates to:
  /// **'Grape Esca (Black Measles)'**
  String get grape_esca;

  /// No description provided for @grape_esca_treatment.
  ///
  /// In en, this message translates to:
  /// **'Prune infected vines, avoid wounding, and remove diseased plants.'**
  String get grape_esca_treatment;

  /// No description provided for @grape_leaf_blight.
  ///
  /// In en, this message translates to:
  /// **'Grape Leaf Blight'**
  String get grape_leaf_blight;

  /// No description provided for @grape_leaf_blight_treatment.
  ///
  /// In en, this message translates to:
  /// **'Use fungicides and remove infected leaves.'**
  String get grape_leaf_blight_treatment;

  /// No description provided for @grape_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Grape'**
  String get grape_healthy;

  /// No description provided for @peach_bacterial_spot.
  ///
  /// In en, this message translates to:
  /// **'Peach Bacterial Spot'**
  String get peach_bacterial_spot;

  /// No description provided for @peach_bacterial_spot_treatment.
  ///
  /// In en, this message translates to:
  /// **'Apply copper sprays and use resistant varieties.'**
  String get peach_bacterial_spot_treatment;

  /// No description provided for @peach_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Peach'**
  String get peach_healthy;

  /// No description provided for @potato_early_blight.
  ///
  /// In en, this message translates to:
  /// **'Potato Early Blight'**
  String get potato_early_blight;

  /// No description provided for @potato_early_blight_treatment.
  ///
  /// In en, this message translates to:
  /// **'Use resistant varieties, rotate crops, and apply fungicides.'**
  String get potato_early_blight_treatment;

  /// No description provided for @potato_late_blight.
  ///
  /// In en, this message translates to:
  /// **'Potato Late Blight'**
  String get potato_late_blight;

  /// No description provided for @potato_late_blight_treatment.
  ///
  /// In en, this message translates to:
  /// **'Destroy infected plants, avoid overhead watering, and apply fungicides.'**
  String get potato_late_blight_treatment;

  /// No description provided for @potato_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Potato'**
  String get potato_healthy;

  /// No description provided for @pepper_bacterial_spot.
  ///
  /// In en, this message translates to:
  /// **'Pepper Bacterial Spot'**
  String get pepper_bacterial_spot;

  /// No description provided for @pepper_bacterial_spot_treatment.
  ///
  /// In en, this message translates to:
  /// **'Use certified seeds, apply copper fungicides, and avoid overhead watering.'**
  String get pepper_bacterial_spot_treatment;

  /// No description provided for @pepper_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Pepper'**
  String get pepper_healthy;

  /// No description provided for @tomato_bacterial_spot.
  ///
  /// In en, this message translates to:
  /// **'Tomato Bacterial Spot'**
  String get tomato_bacterial_spot;

  /// No description provided for @tomato_bacterial_spot_treatment.
  ///
  /// In en, this message translates to:
  /// **'Use resistant varieties, rotate crops, and apply copper fungicides.'**
  String get tomato_bacterial_spot_treatment;

  /// No description provided for @tomato_early_blight.
  ///
  /// In en, this message translates to:
  /// **'Tomato Early Blight'**
  String get tomato_early_blight;

  /// No description provided for @tomato_early_blight_treatment.
  ///
  /// In en, this message translates to:
  /// **'Remove infected leaves, rotate crops, and apply fungicides.'**
  String get tomato_early_blight_treatment;

  /// No description provided for @tomato_late_blight.
  ///
  /// In en, this message translates to:
  /// **'Tomato Late Blight'**
  String get tomato_late_blight;

  /// No description provided for @tomato_late_blight_treatment.
  ///
  /// In en, this message translates to:
  /// **'Destroy infected plants and apply fungicides.'**
  String get tomato_late_blight_treatment;

  /// No description provided for @tomato_leaf_mold.
  ///
  /// In en, this message translates to:
  /// **'Tomato Leaf Mold'**
  String get tomato_leaf_mold;

  /// No description provided for @tomato_leaf_mold_treatment.
  ///
  /// In en, this message translates to:
  /// **'Provide ventilation, avoid overhead watering, and use fungicides.'**
  String get tomato_leaf_mold_treatment;

  /// No description provided for @tomato_septoria_leaf_spot.
  ///
  /// In en, this message translates to:
  /// **'Tomato Septoria Leaf Spot'**
  String get tomato_septoria_leaf_spot;

  /// No description provided for @tomato_septoria_leaf_spot_treatment.
  ///
  /// In en, this message translates to:
  /// **'Rotate crops, remove infected leaves, and apply fungicides.'**
  String get tomato_septoria_leaf_spot_treatment;

  /// No description provided for @tomato_spider_mites.
  ///
  /// In en, this message translates to:
  /// **'Tomato Spider Mites'**
  String get tomato_spider_mites;

  /// No description provided for @tomato_spider_mites_treatment.
  ///
  /// In en, this message translates to:
  /// **'Spray miticides, encourage natural predators, and irrigate properly.'**
  String get tomato_spider_mites_treatment;

  /// No description provided for @tomato_target_spot.
  ///
  /// In en, this message translates to:
  /// **'Tomato Target Spot'**
  String get tomato_target_spot;

  /// No description provided for @tomato_target_spot_treatment.
  ///
  /// In en, this message translates to:
  /// **'Use fungicides and remove infected plant debris.'**
  String get tomato_target_spot_treatment;

  /// No description provided for @tomato_yellow_leaf_curl.
  ///
  /// In en, this message translates to:
  /// **'Tomato Yellow Leaf Curl Virus'**
  String get tomato_yellow_leaf_curl;

  /// No description provided for @tomato_yellow_leaf_curl_treatment.
  ///
  /// In en, this message translates to:
  /// **'Control whiteflies, use resistant varieties, and apply neem oil.'**
  String get tomato_yellow_leaf_curl_treatment;

  /// No description provided for @tomato_mosaic_virus.
  ///
  /// In en, this message translates to:
  /// **'Tomato Mosaic Virus'**
  String get tomato_mosaic_virus;

  /// No description provided for @tomato_mosaic_virus_treatment.
  ///
  /// In en, this message translates to:
  /// **'Remove infected plants, disinfect tools, and control aphids.'**
  String get tomato_mosaic_virus_treatment;

  /// No description provided for @tomato_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Tomato'**
  String get tomato_healthy;

  /// No description provided for @squash_powdery_mildew.
  ///
  /// In en, this message translates to:
  /// **'Squash Powdery Mildew'**
  String get squash_powdery_mildew;

  /// No description provided for @squash_powdery_mildew_treatment.
  ///
  /// In en, this message translates to:
  /// **'Apply fungicides, use resistant varieties, and avoid dense planting.'**
  String get squash_powdery_mildew_treatment;

  /// No description provided for @orange_hlb.
  ///
  /// In en, this message translates to:
  /// **'Orange Citrus Greening (HLB)'**
  String get orange_hlb;

  /// No description provided for @orange_hlb_treatment.
  ///
  /// In en, this message translates to:
  /// **'Control psyllid insects, remove infected trees, and use resistant rootstocks.'**
  String get orange_hlb_treatment;

  /// No description provided for @strawberry_leaf_scorch.
  ///
  /// In en, this message translates to:
  /// **'Strawberry Leaf Scorch'**
  String get strawberry_leaf_scorch;

  /// No description provided for @strawberry_leaf_scorch_treatment.
  ///
  /// In en, this message translates to:
  /// **'Remove infected leaves, irrigate properly, and apply fungicides.'**
  String get strawberry_leaf_scorch_treatment;

  /// No description provided for @strawberry_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Strawberry'**
  String get strawberry_healthy;

  /// No description provided for @soybean_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Soybean'**
  String get soybean_healthy;

  /// No description provided for @raspberry_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Raspberry'**
  String get raspberry_healthy;

  /// No description provided for @diagnosis_failed.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis failed.'**
  String get diagnosis_failed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
