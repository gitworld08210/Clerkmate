/// Simple two-language string table (Hindi + English) with a global toggle.
/// No external localization packages — just a map keyed by [Lang].
enum Lang { hi, en }

class S {
  final Lang lang;
  const S(this.lang);

  String _(String hi, String en) => lang == Lang.hi ? hi : en;

  // App
  String get appName => 'ClerkMate';
  String get namaste => _('Namaste!', 'Welcome!');
  String get language => _('Bhasha', 'Language');

  // Home menu
  String get makeSalaryBill => _('Salary Bill Banayein', 'Make Salary Bill');
  String get makeSalaryBillSub => _(
      'Present days daalein, auto-calculate hoke PDF ban jayega',
      'Enter present days, auto-calculated PDF is generated');
  String get formAutoFill => _('Form Auto-Fill (AI)', 'Form Auto-Fill (AI)');
  String get formAutoFillSub => _(
      'PDF/photo upload karein, AI details bhar ke saaf PDF banaye',
      'Upload a PDF/photo, AI fills details into a clean PDF');
  String get teachers => _('Teachers / Staff', 'Teachers / Staff');
  String get recordsSaved => _('record saved', 'records saved');
  String get schoolDetails =>
      _('Vidyalaya / School Details', 'School Details');
  String get notSetYet => _('Abhi set nahi hai', 'Not set yet');
  String get setSchoolHint => _(
      'School details set karein school section se',
      'Set school details from the school section');

  // Common buttons
  String get save => _('Save karein', 'Save');
  String get cancel => _('Cancel', 'Cancel');
  String get delete => _('Delete', 'Delete');
  String get add => _('Add', 'Add');
  String get share => _('Share', 'Share');
  String get settings => _('Settings', 'Settings');
  String get noName => _('(naam nahi)', '(no name)');

  // School fields
  String get schoolName => _('School / Vidyalaya ka naam', 'School Name');
  String get headMaster => _('Head Master / Principal', 'Head Master / Principal');
  String get diseCode => _('DISE / UDISE Code', 'DISE / UDISE Code');
  String get address => _('Pata / Address', 'Address');
  String get block => _('Block / Prakhand', 'Block');
  String get district => _('District / Zila', 'District');
  String get contact => _('Contact No', 'Contact No');
  String get schoolSaved =>
      _('School details save ho gaye', 'School details saved');

  // Teacher fields
  String get newTeacher => _('Naya Teacher', 'New Teacher');
  String get editTeacher => _('Edit Teacher', 'Edit Teacher');
  String get name => _('Naam / Name', 'Name');
  String get designation =>
      _('Designation (Teacher/Head Master)', 'Designation');
  String get govtRollNo => _('Govt. Roll No', 'Govt. Roll No');
  String get schoolRollNo => _('School Roll No', 'School Roll No');
  String get dob => _('DOB (dd/mm/yyyy)', 'DOB (dd/mm/yyyy)');
  String get doj => _('DOJ (dd/mm/yyyy)', 'DOJ (dd/mm/yyyy)');
  String get gradePay => _('Grade Pay', 'Grade Pay');
  String get basic => _('Basic Pay', 'Basic Pay');
  String get da => _('DA', 'DA');
  String get hra => _('HRA', 'HRA');
  String get medical => _('Medical', 'Medical');
  String get otherAllowance => _('Other Allowance', 'Other Allowance');
  String get gis => _('GIS', 'GIS');
  String get cpf => _('CPF', 'CPF');
  String get otherDeduction => _('Other Deduction', 'Other Deduction');
  String get bankAcNo => _('Bank A/C No', 'Bank A/C No');
  String get ifsc => _('IFSC', 'IFSC');
  String get bankName => _('Bank Name', 'Bank Name');
  String get basicDetails => _('Basic Details', 'Basic Details');
  String get earnings =>
      _('Earnings (poore month ki rakam)', 'Earnings (full month)');
  String get deductions => _('Deductions', 'Deductions');
  String get bankDetails => _('Bank Details', 'Bank Details');
  String get gross => _('Gross', 'Gross');
  String get netPay => _('Net Pay', 'Net Pay');
  String get noTeacherYet => _(
      'Abhi koi teacher add nahi kiya.\n"+" button dabakar add karein.',
      'No teachers added yet.\nTap "+" to add one.');
  String get deleteQ => _('Delete karein?', 'Delete?');
  String deleteMsg(String n) =>
      _('$n ka record delete ho jayega.', 'Record of $n will be deleted.');

  // Salary bill
  String get month => _('Month', 'Month');
  String get year => _('Year', 'Year');
  String get totalDays => _('Total Days', 'Total Days');
  String get presentDays => _('Present days', 'Present days');
  String get addTeachersFirst => _(
      'Pehle "Teachers" me staff add karein,\nphir salary bill ban payega.',
      'First add staff in "Teachers",\nthen the salary bill can be made.');
  String generatePdf(int n) =>
      _('PDF Banayein ($n staff)', 'Generate PDF ($n staff)');
  String get salaryBillPreview =>
      _('Salary Bill Preview', 'Salary Bill Preview');

  // Form fill
  String get step1Upload =>
      _('1. Form upload karein (PDF ya photo)', '1. Upload form (PDF or photo)');
  String get chooseFile => _('File choose karein', 'Choose file');
  String get step2Ai => _('2. AI se padhwaayein', '2. Read with AI');
  String get step3Check =>
      _('3. Values check/edit karein', '3. Check/edit values');
  String get cleanPdf => _('Saaf PDF', 'Clean PDF');
  String get excel => _('Excel', 'Excel');
  String get aiReading => _('AI form padh raha hai...', 'AI is reading...');
  String get aiDone => _(
      'Ho gaya! Neeche values check/edit karein.',
      'Done! Check/edit the values below.');
  String get uploadFirst =>
      _('Pehle koi PDF ya photo upload karein.', 'Upload a PDF or photo first.');
  String get aiUnavailable => _(
      'AI feature abhi available nahi hai.',
      'AI feature is not available right now.');

  // PDF language chooser
  String get pdfLanguageTitle =>
      _('PDF kis bhasha me chahiye?', 'PDF in which language?');
  String get pdfLanguageSub => _(
      'Salary bill / form ke labels PDF me is bhasha me aayenge.',
      'Labels in the generated PDF will be in this language.');
  String get hindi => 'हिंदी (Hindi)';
  String get english => 'English';

  // Auth / login
  String get loginTitle =>
      _('Apne account me login karein', 'Log in to your account');
  String get createAccount => _('Naya account banayein', 'Create a new account');
  String get email => _('Email', 'Email');
  String get password => _('Password', 'Password');
  String get login => _('Login', 'Log in');
  String get signUp => _('Sign Up', 'Sign up');
  String get noAccount =>
      _('Account nahi hai? Sign up karein', "No account? Sign up");
  String get haveAccount =>
      _('Pehle se account hai? Login karein', 'Have an account? Log in');
  String get logout => _('Logout', 'Log out');
  String get loginValidation => _(
      'Sahi email aur kam se kam 6 character ka password daalein.',
      'Enter a valid email and a password of at least 6 characters.');
  String get loginFailed => _('Login nahi hua', 'Login failed');
  String get signUpDone => _(
      'Account ban gaya! Ab login karein.',
      'Account created! You can log in now.');
  String get errEmailNotConfirmed => _(
      'Email verify nahi hui. Admin se account activate karwayein ya thodi der baad try karein.',
      'Email not confirmed yet. Ask the admin to activate your account, or try again shortly.');
  String get errInvalidCredentials => _(
      'Email ya password galat hai.', 'Wrong email or password.');
  String get errAlreadyRegistered => _(
      'Ye email pehle se registered hai. Login karein.',
      'This email is already registered. Please log in.');
}
