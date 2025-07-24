// lib/models/third_party.dart

class ThirdParty {
  final String id; // This is the field that needs to be in the constructor
  String name;
  String type; // e.g., 'Client', 'Prospect', 'Fournisseur'
  String code;
  String? taxId; // NIF / SIRET
  String? parentCompany;
  String? phone;
  String? email;
  String? contactPerson;
  String? contactRole;
  String? address;
  String? notes;
  List<ThirdPartyActivity>? activities;

  ThirdParty({
    required this.id, // <--- MAKE SURE 'id' IS DEFINED HERE AS A REQUIRED NAMED PARAMETER
    required this.name,
    required this.type,
    required this.code,
    this.taxId,
    this.parentCompany,
    this.phone,
    this.email,
    this.contactPerson,
    this.contactRole,
    this.address,
    this.notes,
    this.activities,
  });

  // You might also have a copyWith method, which should also include 'id'
  ThirdParty copyWith({
    String? id,
    String? name,
    String? type,
    String? code,
    String? taxId,
    String? parentCompany,
    String? phone,
    String? email,
    String? contactPerson,
    String? contactRole,
    String? address,
    String? notes,
    List<ThirdPartyActivity>? activities,
  }) {
    return ThirdParty(
      id: id ?? this.id, // <--- Make sure 'id' is handled here too
      name: name ?? this.name,
      type: type ?? this.type,
      code: code ?? this.code,
      taxId: taxId ?? this.taxId,
      parentCompany: parentCompany ?? this.parentCompany,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      contactPerson: contactPerson ?? this.contactPerson,
      contactRole: contactRole ?? this.contactRole,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      activities: activities ?? this.activities,
    );
  }
}

class ThirdPartyActivity {
  final DateTime date;
  final String type; // e.g., 'Appel', 'Email', 'Réunion', 'Note'
  final String description;

  ThirdPartyActivity({
    required this.date,
    required this.type,
    required this.description,
  });
}
