class ThirdParty {
  final String id;
  final String name;
  final String? codeClient; // code_client
  final String? address;
  final String? zipcode;
  final String? town;
  final String? phone;
  final String? email;
  final String? tvaIntra; // tva_intra
  final int? typentId; // typent_id
  final String? status; // '1' or '0'
  final int? codeAuto; // code_auto
  final int? countryId; // country_id
  final int? stateId; // state_id
  final int? assujtvaValue; // assujtva_value
  final int? effectifId; // effectif_id
  final int? formeJuridiqueCode; // forme_juridique_code
  final double? capital;
  final int? condReglementId; // cond_reglement_id
  final int? incotermId; // incoterm_id
  final int? custcatsMultiselect; // custcats_multiselect
  final int? suppcatsMultiselect; // suppcats_multiselect
  final int? parentCompanyId; // parent_company_id
  final int? commercialMultiselect; // commercial_multiselect
  final List<int>? commercial;

  // Champs supplémentaires souvent renvoyés par l'API GET
  final String? client; // '1' if client, '0' otherwise
  final String? fournisseur; // '1' if fournisseur, '0' otherwise

  ThirdParty({
    required this.id,
    required this.name,
    this.codeClient,
    this.address,
    this.zipcode,
    this.town,
    this.phone,
    this.email,
    this.tvaIntra,
    this.typentId,
    this.status,
    this.codeAuto,
    this.countryId,
    this.stateId,
    this.assujtvaValue,
    this.effectifId,
    this.formeJuridiqueCode,
    this.capital,
    this.condReglementId,
    this.incotermId,
    this.custcatsMultiselect,
    this.suppcatsMultiselect,
    this.parentCompanyId,
    this.commercialMultiselect,
    this.commercial,
    this.client,
    this.fournisseur,
  });

  factory ThirdParty.fromJson(Map<String, dynamic> json) {
    return ThirdParty(
      id: json['id'].toString(),
      name: json['name'] as String,
      codeClient: json['code_client'] as String?,
      address: json['address'] as String?,
      zipcode: json['zipcode'] as String?,
      town: json['town'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      tvaIntra: json['tva_intra'] as String?,
      typentId: json['typent_id'] is String
          ? int.tryParse(json['typent_id'])
          : json['typent_id'] as int?,
      status: json['status'].toString(),
      codeAuto: json['code_auto'] is String
          ? int.tryParse(json['code_auto'])
          : json['code_auto'] as int?,
      countryId: json['country_id'] is String
          ? int.tryParse(json['country_id'])
          : json['country_id'] as int?,
      stateId: json['state_id'] is String
          ? int.tryParse(json['state_id'])
          : json['state_id'] as int?,
      assujtvaValue: json['assujtva_value'] is String
          ? int.tryParse(json['assujtva_value'])
          : json['assujtva_value'] as int?,
      effectifId: json['effectif_id'] is String
          ? int.tryParse(json['effectif_id'])
          : json['effectif_id'] as int?,
      formeJuridiqueCode: json['forme_juridique_code'] is String
          ? int.tryParse(json['forme_juridique_code'])
          : json['forme_juridique_code'] as int?,
      capital: json['capital'] is String
          ? double.tryParse(json['capital'])
          : json['capital'] as double?,
      condReglementId: json['cond_reglement_id'] is String
          ? int.tryParse(json['cond_reglement_id'])
          : json['cond_reglement_id'] as int?,
      incotermId: json['incoterm_id'] is String
          ? int.tryParse(json['incoterm_id'])
          : json['incoterm_id'] as int?,
      custcatsMultiselect: json['custcats_multiselect'] is String
          ? int.tryParse(json['custcats_multiselect'])
          : json['custcats_multiselect'] as int?,
      suppcatsMultiselect: json['suppcats_multiselect'] is String
          ? int.tryParse(json['suppcats_multiselect'])
          : json['suppcats_multiselect'] as int?,
      parentCompanyId: json['parent_company_id'] is String
          ? int.tryParse(json['parent_company_id'])
          : json['parent_company_id'] as int?,
      commercialMultiselect: json['commercial_multiselect'] is String
          ? int.tryParse(json['commercial_multiselect'])
          : json['commercial_multiselect'] as int?,
      commercial: (json['commercial'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      client: json['client'].toString(),
      fournisseur: json['fournisseur'].toString(),
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
