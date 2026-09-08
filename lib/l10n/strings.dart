/// Two-language string table: proper English + proper Hindi (Devanagari).
/// A global toggle switches between them. No Hinglish.
enum Lang { hi, en }

class S {
  final Lang lang;
  const S(this.lang);

  String _(String hi, String en) => lang == Lang.hi ? hi : en;

  // App
  String get appName => 'ClerkMate';
  String get namaste => _('स्वागत है!', 'Welcome!');
  String get language => _('भाषा', 'Language');
  String get dashboard => _('डैशबोर्ड', 'Dashboard');

  // Home menu
  String get makeSalaryBill => _('वेतन बिल बनाएँ', 'Salary Bill');
  String get makeSalaryBillSub => _(
      'उपस्थिति दिन भरें, बिल अपने आप बनकर PDF तैयार',
      'Enter present days — auto-calculated PDF');
  String get formAutoFill => _('फॉर्म भरें', 'Fill a Form');
  String get formAutoFillSub => _(
      'फॉर्म भरें, विवरण अपने आप जुड़े, साफ़ PDF पाएँ',
      'Fill a form with saved details, export a clean PDF');
  String get teachers => _('शिक्षक / कर्मचारी', 'Teachers / Staff');
  String get recordsSaved => _('रिकॉर्ड सेव', 'saved');
  String get schoolDetails => _('विद्यालय विवरण', 'School Details');
  String get notSetYet => _('अभी सेट नहीं है', 'Not set yet');
  String get setSchoolHint => _(
      'विद्यालय अनुभाग से विद्यालय का विवरण भरें',
      'Add your school details to get started');

  // Common buttons
  String get save => _('सेव करें', 'Save');
  String get cancel => _('रद्द करें', 'Cancel');
  String get delete => _('हटाएँ', 'Delete');
  String get add => _('जोड़ें', 'Add');
  String get share => _('शेयर करें', 'Share');
  String get settings => _('सेटिंग्स', 'Settings');
  String get noName => _('(नाम नहीं)', '(no name)');

  // School fields
  String get schoolName => _('विद्यालय का नाम', 'School Name');
  String get headMaster => _('प्रधानाध्यापक', 'Head Master / Principal');
  String get diseCode => _('DISE / UDISE कोड', 'DISE / UDISE Code');
  String get address => _('पता', 'Address');
  String get block => _('प्रखंड / ब्लॉक', 'Block');
  String get district => _('ज़िला', 'District');
  String get contact => _('संपर्क नंबर', 'Contact No.');
  String get schoolSaved =>
      _('विद्यालय विवरण सेव हो गया', 'School details saved');

  // Teacher fields
  String get newTeacher => _('नया शिक्षक', 'New Teacher');
  String get editTeacher => _('शिक्षक संपादित करें', 'Edit Teacher');
  String get name => _('नाम', 'Name');
  String get designation => _('पदनाम', 'Designation');
  String get govtRollNo => _('सरकारी रोल नं.', 'Govt. Roll No.');
  String get schoolRollNo => _('विद्यालय रोल नं.', 'School Roll No.');
  String get dob => _('जन्म तिथि (dd/mm/yyyy)', 'Date of Birth (dd/mm/yyyy)');
  String get doj =>
      _('नियुक्ति तिथि (dd/mm/yyyy)', 'Date of Joining (dd/mm/yyyy)');
  String get gradePay => _('ग्रेड पे', 'Grade Pay');
  String get basic => _('मूल वेतन', 'Basic Pay');
  String get da => _('महंगाई भत्ता (DA)', 'DA');
  String get hra => _('मकान भत्ता (HRA)', 'HRA');
  String get medical => _('चिकित्सा भत्ता', 'Medical');
  String get otherAllowance => _('अन्य भत्ता', 'Other Allowance');
  String get gis => _('GIS कटौती', 'GIS');
  String get cpf => _('CPF कटौती', 'CPF');
  String get otherDeduction => _('अन्य कटौती', 'Other Deduction');
  String get bankAcNo => _('बैंक खाता नं.', 'Bank A/C No.');
  String get ifsc => _('IFSC कोड', 'IFSC');
  String get bankName => _('बैंक का नाम', 'Bank Name');
  String get basicDetails => _('मूल विवरण', 'Basic Details');
  String get earnings => _('आय (पूरे माह की)', 'Earnings (full month)');
  String get deductions => _('कटौती', 'Deductions');
  String get bankDetails => _('बैंक विवरण', 'Bank Details');
  String get gross => _('कुल आय', 'Gross');
  String get netPay => _('शुद्ध वेतन', 'Net Pay');
  String get noTeacherYet => _(
      'अभी कोई शिक्षक नहीं जोड़ा गया।\nजोड़ने के लिए "+" दबाएँ।',
      'No teachers added yet.\nTap "+" to add one.');
  String get deleteQ => _('हटाएँ?', 'Delete?');
  String deleteMsg(String n) =>
      _('$n का रिकॉर्ड हट जाएगा।', 'The record of $n will be deleted.');

  // Salary bill
  String get month => _('माह', 'Month');
  String get year => _('वर्ष', 'Year');
  String get totalDays => _('कुल दिन', 'Total Days');
  String get presentDays => _('उपस्थित दिन', 'Present days');
  String get addTeachersFirst => _(
      'पहले "शिक्षक" में कर्मचारी जोड़ें,\nफिर वेतन बिल बनेगा।',
      'Add staff under "Teachers" first,\nthen you can create the salary bill.');
  String generatePdf(int n) =>
      _('PDF बनाएँ ($n)', 'Generate PDF ($n)');
  String get salaryBillPreview => _('वेतन बिल — प्रीव्यू', 'Salary Bill Preview');

  // Form fill
  String get selectFormType => _('फॉर्म का प्रकार चुनें', 'Select form type');
  String get formFields => _('फॉर्म के विवरण', 'Form details');
  String get autoFilledNote => _(
      'विवरण विद्यालय/शिक्षक डेटा से अपने आप भर गए हैं। ज़रूरत हो तो बदलें।',
      'Fields were auto-filled from your saved data. Edit if needed.');
  String get addField => _('नया विवरण जोड़ें', 'Add a field');
  String get fieldLabel => _('विवरण का नाम', 'Field label');
  String get value => _('मान', 'Value');
  String get exportPdf => _('साफ़ PDF बनाएँ', 'Export clean PDF');
  String get exportExcel => _('Excel बनाएँ', 'Export Excel');
  String get useAi => _('AI से फॉर्म पढ़ें (वैकल्पिक)', 'Read a form with AI (optional)');
  String get chooseFile => _('फ़ाइल चुनें', 'Choose file');
  String get readWithAi => _('AI से पढ़ें', 'Read with AI');
  String get aiReading => _('AI फॉर्म पढ़ रहा है...', 'AI is reading the form...');
  String get aiDone => _(
      'हो गया! नीचे विवरण जाँचें/बदलें।',
      'Done — review and edit the fields below.');
  String get uploadFirst =>
      _('पहले कोई PDF या फोटो चुनें।', 'Choose a PDF or photo first.');
  String get aiUnavailable => _(
      'AI सुविधा अभी उपलब्ध नहीं है। आप विवरण मैन्युअल रूप से भर सकते हैं।',
      'AI is not enabled. You can still fill the form manually.');

  // PDF language chooser
  String get pdfLanguageTitle =>
      _('PDF किस भाषा में चाहिए?', 'PDF in which language?');
  String get pdfLanguageSub => _(
      'बने हुए PDF के लेबल इसी भाषा में आएँगे।',
      'Labels in the generated PDF will use this language.');
  String get hindi => 'हिंदी';
  String get english => 'English';

  // Auth / login
  String get loginTitle => _('अपने खाते में लॉग इन करें', 'Sign in to your account');
  String get createAccount => _('नया खाता बनाएँ', 'Create a new account');
  String get email => _('ईमेल', 'Email');
  String get password => _('पासवर्ड', 'Password');
  String get login => _('लॉग इन', 'Sign In');
  String get signUp => _('साइन अप', 'Sign Up');
  String get noAccount => _('खाता नहीं है? साइन अप करें', "Don't have an account? Sign up");
  String get haveAccount => _('पहले से खाता है? लॉग इन करें', 'Already have an account? Sign in');
  String get logout => _('लॉग आउट', 'Log out');
  String get loginValidation => _(
      'सही ईमेल और कम से कम 6 अक्षर का पासवर्ड भरें।',
      'Enter a valid email and a password of at least 6 characters.');
  String get loginFailed => _('लॉग इन नहीं हुआ', 'Sign in failed');
  String get signUpDone =>
      _('खाता बन गया! अब लॉग इन करें।', 'Account created — you can sign in now.');
  String get errEmailNotConfirmed => _(
      'ईमेल अभी सत्यापित नहीं है। एडमिन से खाता सक्रिय करवाएँ या कुछ देर बाद पुनः प्रयास करें।',
      'Your email is not confirmed yet. Ask the admin to activate your account, or try again shortly.');
  String get errInvalidCredentials =>
      _('ईमेल या पासवर्ड ग़लत है।', 'Wrong email or password.');
  String get errAlreadyRegistered => _(
      'यह ईमेल पहले से पंजीकृत है। लॉग इन करें।',
      'This email is already registered. Please sign in.');
  String get appTagline => _(
      'विद्यालय लिपिक का डिजिटल सहायक',
      'The digital assistant for school clerks');
}
