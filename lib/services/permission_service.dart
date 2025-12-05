import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  
  factory PermissionService() {
    return _instance;
  }
  
  PermissionService._internal();
  
  final _secureStorage = const FlutterSecureStorage();
  Map<String, dynamic>? _cachedUserData;

  //Charger les données utilisateur en cache
  Future<void> loadUserData() async {
    final userDataJson = await _secureStorage.read(key: 'dolibarr_user_data');
    if (userDataJson != null) {
      _cachedUserData = jsonDecode(userDataJson) as Map<String, dynamic>;
    }
  }

  //Vérifier les permissions de l'utilisateur
  bool hasPermission(String permission) {
    if (_cachedUserData == null) return false;
    
    //Récupérer les permissions de l'utilisateur depuis Dolibarr
    final permissions = _cachedUserData?['permissions'] as Map<String, dynamic>?;
    
    if (permissions == null) return false;
    
    return permissions[permission] == 1 || permissions[permission] == true;
  }

  //Vérifier si l'utilisateur est admin
  bool isAdmin() {
    if (_cachedUserData == null) return false;
    
    //Dans Dolibarr, l'administrateur a généralement admin = 1
    final admin = _cachedUserData?['admin'];
    return admin == 1 || admin == true;
  }

  //Récupérer le rôle de l'utilisateur
  String? getUserRole() {
    return _cachedUserData?['statut']?.toString();
  }

  //Récupérer l'ID utilisateur
  int? getUserId() {
    final id = _cachedUserData?['id'];
    return id is int ? id : int.tryParse(id.toString());
  }

  //Les permissions communes dans Dolibarr pour les factures
  bool canCreateInvoice() => hasPermission('facture_creer');
  bool canEditInvoice() => hasPermission('facture_modifier');
  bool canDeleteInvoice() => hasPermission('facture_supprimer');
  bool canViewInvoice() => hasPermission('facture_lire');

  //Les permissions pour les tiers
  bool canCreateThirdParty() => hasPermission('societe_creer');
  bool canEditThirdParty() => hasPermission('societe_modifier');
  bool canDeleteThirdParty() => hasPermission('societe_supprimer');
  bool canViewThirdParty() => hasPermission('societe_lire');

  //Les permissions pour les commandes
  bool canCreateCommand() => hasPermission('commande_creer');
  bool canEditCommand() => hasPermission('commande_modifier');
  bool canDeleteCommand() => hasPermission('commande_supprimer');
  bool canViewCommand() => hasPermission('commande_lire');

  //Les permissions pour les devis
  bool canCreateQuote() => hasPermission('propal_creer');
  bool canEditQuote() => hasPermission('propal_modifier');
  bool canDeleteQuote() => hasPermission('propal_supprimer');
  bool canViewQuote() => hasPermission('propal_lire');

  //Permission pour l'administration
  bool canAdminister() => hasPermission('admin');
}