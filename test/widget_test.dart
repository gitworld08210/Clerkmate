// Basic unit tests for ClerkMate.
import 'package:flutter_test/flutter_test.dart';

import 'package:clerkmate/models/teacher.dart';

void main() {
  test('Teacher net pay calculates correctly', () {
    final t = Teacher(
      basic: 30000,
      da: 15000,
      hra: 3000,
      gis: 500,
      cpf: 4000,
    );
    expect(t.grossEarnings, 48000);
    expect(t.totalDeductions, 4500);
    expect(t.netPay, 43500);
  });

  test('Teacher copy preserves values', () {
    final t = Teacher(serverId: 'abc', name: 'Ram', basic: 100);
    final c = t.copy();
    expect(c.serverId, 'abc');
    expect(c.name, 'Ram');
    expect(c.basic, 100);
  });
}
