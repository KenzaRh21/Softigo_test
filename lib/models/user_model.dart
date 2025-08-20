// lib/models/user_model.dart

class User {
  final int? id;
  final String? civilityCode;
  final String lastname;
  final String firstname;
  final String login;
  final String password;
  final String? gender;
  final int? employee;
  final int? fkUser;
  final int? fkUserExpenseValidator;
  final int? fkUserHolidayValidator;
  final String? dateStartValidity;
  final String? dateEndValidity;
  final String? apiKey;
  final String? address;
  final String? zipcode;
  final String? town;
  final int? countryId;
  final int? stateId;
  final String? officePhone;
  final String? userMobile;
  final String? officeFax;
  final String? email;
  final String? accountancyCode;
  final String? color;
  final String? usercatsMultiselect;
  final String? signature;
  final String? notePublic;
  final String? notePrivate;
  final String? job;
  final String? thm;
  final String? tjm;
  final String? salary;
  final String? weeklyHours;
  final String? dateEmployment;
  final String? dateEmploymentEnd;
  final String? dateOfBirth;

  User({
    this.id,
    this.civilityCode,
    required this.lastname,
    required this.firstname,
    required this.login,
    required this.password,
    this.gender,
    this.employee,
    this.fkUser,
    this.fkUserExpenseValidator,
    this.fkUserHolidayValidator,
    this.dateStartValidity,
    this.dateEndValidity,
    this.apiKey,
    this.address,
    this.zipcode,
    this.town,
    this.countryId,
    this.stateId,
    this.officePhone,
    this.userMobile,
    this.officeFax,
    this.email,
    this.accountancyCode,
    this.color,
    this.usercatsMultiselect,
    this.signature,
    this.notePublic,
    this.notePrivate,
    this.job,
    this.thm,
    this.tjm,
    this.salary,
    this.weeklyHours,
    this.dateEmployment,
    this.dateEmploymentEnd,
    this.dateOfBirth,
  });
  String get fullName => '$firstname $lastname';

  Map<String, dynamic> toJson() {
    return {
      'civility_code': civilityCode,
      'lastname': lastname,
      'firstname': firstname,
      'login': login,
      'password': password,
      'gender': gender,
      'employee': employee,
      'fk_user': fkUser,
      'fk_user_expense_validator': fkUserExpenseValidator,
      'fk_user_holiday_validator': fkUserHolidayValidator,
      'datestartvalidity': dateStartValidity,
      'dateendvalidity': dateEndValidity,
      'address': address,
      'zipcode': zipcode,
      'town': town,
      'country_id': countryId,
      'state_id': stateId,
      'office_phone': officePhone,
      'user_mobile': userMobile,
      'email': email,
      'accountancy_code': accountancyCode,
      'job': job,
      'salary': salary,
      'weeklyhours': weeklyHours,
      'dateemployment': dateEmployment,
      'dateemploymentend': dateEmploymentEnd,
      'dateofbirth': dateOfBirth,
    };
  }
}
