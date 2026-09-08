import 'dart:typed_data';

import 'package:excel/excel.dart';

class ExcelService {
  /// Two-column (Field / Value) sheet from extracted form fields.
  static Uint8List buildFieldsSheet(Map<String, String> fields) {
    final excel = Excel.createExcel();
    final sheet = excel['Form Data'];
    excel.delete('Sheet1');

    sheet.appendRow([
      TextCellValue('Field'),
      TextCellValue('Value'),
    ]);
    fields.forEach((k, v) {
      sheet.appendRow([TextCellValue(k), TextCellValue(v)]);
    });

    final bytes = excel.encode();
    return Uint8List.fromList(bytes ?? []);
  }
}
