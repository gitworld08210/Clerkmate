import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Wraps Google Gemini REST API for extracting structured field data
/// from an uploaded form (image or PDF).
class GeminiService {
  final String apiKey;
  GeminiService(this.apiKey);

  // Vision-capable model that also reads PDFs.
  static const _model = 'gemini-1.5-flash';

  bool get hasKey => apiKey.trim().isNotEmpty;

  /// Sends a form document + a list of field labels we want to detect.
  /// Returns a map of {fieldLabel: extractedValue}. Gemini is asked to be
  /// smart about synonyms (Vidyalaya == School Name, Head Master == Principal).
  Future<Map<String, String>> extractFields({
    required Uint8List fileBytes,
    required String mimeType,
    required List<String> wantedFields,
  }) async {
    if (!hasKey) {
      throw Exception('Gemini API key set nahi hai. Settings me daalein.');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey',
    );

    final prompt = '''
You are helping a school clerk read an official Indian school form (may be in
Hindi or English, printed or handwritten). Identify the value for each of the
following logical fields. Be smart about synonyms and translations, for example:
- "School Name" also matches "Vidyalaya", "विद्यालय".
- "Principal" also matches "Head Master", "प्रधानाध्यापक", "HM".
- "Employee Name" matches "Teacher's Name", "शिक्षक का नाम".
- "Account Number" matches "A/C No", "Bank A/C".

Fields to extract: ${wantedFields.join(', ')}.

Return ONLY a JSON object mapping each field label exactly as given to its
detected string value. If a field is not present, use an empty string.
No markdown, no explanation, just JSON.
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Encode(fileBytes),
              }
            },
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
        'response_mime_type': 'application/json',
      }
    });

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (resp.statusCode != 200) {
      throw Exception('Gemini error ${resp.statusCode}: ${resp.body}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('AI se koi jawab nahi mila.');
    }
    final text = candidates[0]['content']['parts'][0]['text'] as String;

    final Map<String, dynamic> parsed = _safeParse(text);
    return parsed.map((k, v) => MapEntry(k, (v ?? '').toString()));
  }

  Map<String, dynamic> _safeParse(String text) {
    var t = text.trim();
    // Strip code fences if the model added them anyway.
    if (t.startsWith('```')) {
      t = t.replaceAll(RegExp(r'^```(json)?'), '').replaceAll(RegExp(r'```$'), '').trim();
    }
    try {
      return jsonDecode(t) as Map<String, dynamic>;
    } catch (_) {
      // Try to find the first {...} block.
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(t);
      if (match != null) {
        return jsonDecode(match.group(0)!) as Map<String, dynamic>;
      }
      throw Exception('AI ka jawab samajh nahi aaya: $text');
    }
  }
}
