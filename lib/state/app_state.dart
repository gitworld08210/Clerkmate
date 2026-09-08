import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../data/supabase_repository.dart';
import '../l10n/strings.dart';
import '../models/teacher.dart';
import '../models/school_info.dart';

/// Central app state: auth, language, teacher list and school info (cloud).
class AppState extends ChangeNotifier {
  final _repo = SupabaseRepository();
  final _auth = Supabase.instance.client.auth;

  List<Teacher> teachers = [];
  SchoolInfo school = SchoolInfo();
  Lang lang = Lang.hi; // Hindi by default
  bool loading = false;
  bool dataLoaded = false;

  static const _kLang = 'app_lang';

  S get s => S(lang);

  bool get isLoggedIn => _auth.currentUser != null;
  String get userEmail => _auth.currentUser?.email ?? '';

  bool get aiEnabled => AppConfig.geminiApiKey.isNotEmpty;
  String get geminiApiKey => AppConfig.geminiApiKey;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    lang = prefs.getString(_kLang) == 'en' ? Lang.en : Lang.hi;
    // React to login / logout automatically.
    _auth.onAuthStateChange.listen((event) {
      if (event.session != null) {
        loadData();
      } else {
        teachers = [];
        school = SchoolInfo();
        dataLoaded = false;
        notifyListeners();
      }
    });
    if (isLoggedIn) await loadData();
    notifyListeners();
  }

  // ---------------- Auth ----------------

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithPassword(email: email.trim(), password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _auth.signUp(email: email.trim(), password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ---------------- Data ----------------

  Future<void> loadData() async {
    loading = true;
    notifyListeners();
    try {
      teachers = await _repo.getTeachers();
      school = await _repo.getSchoolInfo();
      dataLoaded = true;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLanguage() async {
    lang = lang == Lang.hi ? Lang.en : Lang.hi;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLang, lang == Lang.en ? 'en' : 'hi');
    notifyListeners();
  }

  Future<void> saveTeacher(Teacher t) async {
    await _repo.upsertTeacher(t);
    teachers = await _repo.getTeachers();
    notifyListeners();
  }

  Future<void> deleteTeacher(String serverId) async {
    await _repo.deleteTeacher(serverId);
    teachers = await _repo.getTeachers();
    notifyListeners();
  }

  Future<void> saveSchool(SchoolInfo info) async {
    await _repo.saveSchoolInfo(info);
    school = await _repo.getSchoolInfo();
    notifyListeners();
  }
}
