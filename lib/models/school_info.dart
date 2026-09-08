/// School / Vidyalaya information used across forms and salary bills.
class SchoolInfo {
  String name; // School name / Vidyalaya ka naam
  String address; // Pata
  String diseCode; // DISE / UDISE code
  String headMaster; // Head Master / Principal
  String block;
  String district;
  String contact;

  SchoolInfo({
    this.name = '',
    this.address = '',
    this.diseCode = '',
    this.headMaster = '',
    this.block = '',
    this.district = '',
    this.contact = '',
  });

  SchoolInfo copy() => SchoolInfo(
        name: name,
        address: address,
        diseCode: diseCode,
        headMaster: headMaster,
        block: block,
        district: district,
        contact: contact,
      );
}
