/// A teacher / staff member. Salary components are the monthly full amounts;
/// present-day proration is calculated at bill-generation time.
class Teacher {
  /// Supabase uuid primary key (null for a new, unsaved teacher).
  String? serverId;
  String name;
  String designation; // Teacher / Head Master etc.
  String govtRollNo;
  String schoolRollNo;
  String dob; // Date of birth (dd/MM/yyyy)
  String doj; // Date of joining (dd/MM/yyyy)
  String gradePay;

  // Earnings (full month)
  double basic;
  double da; // Dearness Allowance
  double hra; // House Rent Allowance
  double medical;
  double otherAllowance;

  // Deductions (full month)
  double gis; // Group Insurance Scheme
  double cpf; // Contributory Provident Fund
  double otherDeduction;

  // Bank
  String bankAcNo;
  String ifsc;
  String bankName;

  Teacher({
    this.serverId,
    this.name = '',
    this.designation = '',
    this.govtRollNo = '',
    this.schoolRollNo = '',
    this.dob = '',
    this.doj = '',
    this.gradePay = '',
    this.basic = 0,
    this.da = 0,
    this.hra = 0,
    this.medical = 0,
    this.otherAllowance = 0,
    this.gis = 0,
    this.cpf = 0,
    this.otherDeduction = 0,
    this.bankAcNo = '',
    this.ifsc = '',
    this.bankName = '',
  });

  double get grossEarnings => basic + da + hra + medical + otherAllowance;

  double get totalDeductions => gis + cpf + otherDeduction;

  double get netPay => grossEarnings - totalDeductions;

  /// Local copy for editing without touching the original instance.
  Teacher copy() => Teacher(
        serverId: serverId,
        name: name,
        designation: designation,
        govtRollNo: govtRollNo,
        schoolRollNo: schoolRollNo,
        dob: dob,
        doj: doj,
        gradePay: gradePay,
        basic: basic,
        da: da,
        hra: hra,
        medical: medical,
        otherAllowance: otherAllowance,
        gis: gis,
        cpf: cpf,
        otherDeduction: otherDeduction,
        bankAcNo: bankAcNo,
        ifsc: ifsc,
        bankName: bankName,
      );
}
