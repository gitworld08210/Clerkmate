/// Build-time / app configuration.
class AppConfig {
  // Supabase project (Oneleven) — used for login + cloud database.
  static const String supabaseUrl = 'https://xyuzzjwmpyckuhtiygpk.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_57Xuez2QU5tHLbXhVnqi7w_Bhy-Jvmz';

  /// Optional Gemini API key for the AI form-fill feature. Not asked from the
  /// user; provide at build time with:
  ///   flutter build apk --dart-define=GEMINI_API_KEY=your_key
  /// If empty, the AI feature is hidden and everything else works.
  static const String geminiApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
}
