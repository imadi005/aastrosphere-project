import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One of India's 22 scheduled (Eighth Schedule) languages, plus English.
class AppLanguage {
  final String code; // ISO 639-1 (or closest available) locale code
  final String englishName;
  final String nativeName;
  final bool available; // has a real translation shipped today

  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.available,
  });
}

/// All 22 official Indian languages + English. Only [available] ones are
/// actually translated right now (checked in this order of priority); the
/// rest show in the picker so users can see them, but fall back to English
/// until translated — never silently missing from the list.
const List<AppLanguage> kAppLanguages = [
  AppLanguage(code: 'en', englishName: 'English', nativeName: 'English', available: true),
  AppLanguage(code: 'hi', englishName: 'Hindi', nativeName: 'हिन्दी', available: true),
  AppLanguage(code: 'bn', englishName: 'Bengali', nativeName: 'বাংলা', available: true),
  AppLanguage(code: 'ta', englishName: 'Tamil', nativeName: 'தமிழ்', available: true),
  AppLanguage(code: 'te', englishName: 'Telugu', nativeName: 'తెలుగు', available: true),
  AppLanguage(code: 'mr', englishName: 'Marathi', nativeName: 'मराठी', available: true),
  AppLanguage(code: 'gu', englishName: 'Gujarati', nativeName: 'ગુજરાતી', available: true),
  AppLanguage(code: 'kn', englishName: 'Kannada', nativeName: 'ಕನ್ನಡ', available: false),
  AppLanguage(code: 'ml', englishName: 'Malayalam', nativeName: 'മലയാളം', available: false),
  AppLanguage(code: 'pa', englishName: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', available: false),
  AppLanguage(code: 'or', englishName: 'Odia', nativeName: 'ଓଡ଼ିଆ', available: false),
  AppLanguage(code: 'as', englishName: 'Assamese', nativeName: 'অসমীয়া', available: false),
  AppLanguage(code: 'ur', englishName: 'Urdu', nativeName: 'اردو', available: false),
  AppLanguage(code: 'sa', englishName: 'Sanskrit', nativeName: 'संस्कृतम्', available: false),
  AppLanguage(code: 'ks', englishName: 'Kashmiri', nativeName: 'کٲشُر', available: false),
  AppLanguage(code: 'sd', englishName: 'Sindhi', nativeName: 'سنڌي', available: false),
  AppLanguage(code: 'kok', englishName: 'Konkani', nativeName: 'कोंकणी', available: false),
  AppLanguage(code: 'ne', englishName: 'Nepali', nativeName: 'नेपाली', available: false),
  AppLanguage(code: 'mai', englishName: 'Maithili', nativeName: 'मैथिली', available: false),
  AppLanguage(code: 'doi', englishName: 'Dogri', nativeName: 'डोगरी', available: false),
  AppLanguage(code: 'mni', englishName: 'Manipuri', nativeName: 'ꯃꯤꯇꯩꯂꯣꯟ', available: false),
  AppLanguage(code: 'sat', englishName: 'Santali', nativeName: 'ᱥᱟᱱᱛᱟᱲᱤ', available: false),
  AppLanguage(code: 'brx', englishName: 'Bodo', nativeName: 'बड़ो', available: false),
];

const List<String> kShippedLocaleCodes = ['en', 'hi', 'bn', 'ta', 'te', 'mr', 'gu'];

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _load();
  }

  static const _key = 'app_locale';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && kShippedLocaleCodes.contains(code)) {
      state = Locale(code);
    }
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    // Untranslated languages fall back to English until shipped.
    final effective = kShippedLocaleCodes.contains(code) ? code : 'en';
    state = Locale(effective);
    await prefs.setString(_key, effective);
  }
}
