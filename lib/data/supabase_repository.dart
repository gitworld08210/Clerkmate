import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/teacher.dart';
import '../models/school_info.dart';

/// Cloud data access via Supabase. Every row is scoped to the logged-in user
/// by RLS on the server; we also set user_id explicitly on insert.
class SupabaseRepository {
  final SupabaseClient _c = Supabase.instance.client;

  String? get _uid => _c.auth.currentUser?.id;

  // ---------------- Teachers ----------------

  Future<List<Teacher>> getTeachers() async {
    final rows = await _c
        .from('clerkmate_teachers')
        .select()
        .order('name', ascending: true);
    return (rows as List)
        .map((r) => _teacherFromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertTeacher(Teacher t) async {
    final data = _teacherToRow(t)..['user_id'] = _uid;
    if (t.serverId == null) {
      await _c.from('clerkmate_teachers').insert(data);
    } else {
      await _c
          .from('clerkmate_teachers')
          .update(data)
          .eq('id', t.serverId as Object);
    }
  }

  Future<void> deleteTeacher(String serverId) async {
    await _c.from('clerkmate_teachers').delete().eq('id', serverId);
  }

  // ---------------- School info ----------------

  Future<SchoolInfo> getSchoolInfo() async {
    final rows = await _c.from('clerkmate_schools').select().limit(1);
    final list = rows as List;
    if (list.isEmpty) return SchoolInfo();
    return _schoolFromRow(list.first as Map<String, dynamic>);
  }

  Future<void> saveSchoolInfo(SchoolInfo info) async {
    final existing = await _c.from('clerkmate_schools').select('id').limit(1);
    final data = _schoolToRow(info)..['user_id'] = _uid;
    if ((existing as List).isEmpty) {
      await _c.from('clerkmate_schools').insert(data);
    } else {
      final id = (existing.first as Map)['id'];
      await _c.from('clerkmate_schools').update(data).eq('id', id as Object);
    }
  }

  // ---------------- Mappers (snake_case DB <-> model) ----------------

  Teacher _teacherFromRow(Map<String, dynamic> m) => Teacher(
        serverId: m['id'] as String?,
        name: (m['name'] ?? '') as String,
        designation: (m['designation'] ?? '') as String,
        govtRollNo: (m['govt_roll_no'] ?? '') as String,
        schoolRollNo: (m['school_roll_no'] ?? '') as String,
        dob: (m['dob'] ?? '') as String,
        doj: (m['doj'] ?? '') as String,
        gradePay: (m['grade_pay'] ?? '') as String,
        basic: _d(m['basic']),
        da: _d(m['da']),
        hra: _d(m['hra']),
        medical: _d(m['medical']),
        otherAllowance: _d(m['other_allowance']),
        gis: _d(m['gis']),
        cpf: _d(m['cpf']),
        otherDeduction: _d(m['other_deduction']),
        bankAcNo: (m['bank_ac_no'] ?? '') as String,
        ifsc: (m['ifsc'] ?? '') as String,
        bankName: (m['bank_name'] ?? '') as String,
      );

  Map<String, dynamic> _teacherToRow(Teacher t) => {
        'name': t.name,
        'designation': t.designation,
        'govt_roll_no': t.govtRollNo,
        'school_roll_no': t.schoolRollNo,
        'dob': t.dob,
        'doj': t.doj,
        'grade_pay': t.gradePay,
        'basic': t.basic,
        'da': t.da,
        'hra': t.hra,
        'medical': t.medical,
        'other_allowance': t.otherAllowance,
        'gis': t.gis,
        'cpf': t.cpf,
        'other_deduction': t.otherDeduction,
        'bank_ac_no': t.bankAcNo,
        'ifsc': t.ifsc,
        'bank_name': t.bankName,
      };

  SchoolInfo _schoolFromRow(Map<String, dynamic> m) => SchoolInfo(
        name: (m['name'] ?? '') as String,
        address: (m['address'] ?? '') as String,
        diseCode: (m['dise_code'] ?? '') as String,
        headMaster: (m['head_master'] ?? '') as String,
        block: (m['block'] ?? '') as String,
        district: (m['district'] ?? '') as String,
        contact: (m['contact'] ?? '') as String,
      );

  Map<String, dynamic> _schoolToRow(SchoolInfo s) => {
        'name': s.name,
        'address': s.address,
        'dise_code': s.diseCode,
        'head_master': s.headMaster,
        'block': s.block,
        'district': s.district,
        'contact': s.contact,
      };

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
