import 'package:flutter/material.dart';

enum QuoteStatus {
  draft, // Brouillon - nouveau statut
  pending, // En attente
  accepted, // Accepté
  rejected, // Rejeté
  invoiced, // Facturé
}

extension QuoteStatusExtension on QuoteStatus {
  String toDisplayString() {
    switch (this) {
      case QuoteStatus.draft:
        return 'Brouillon';
      case QuoteStatus.pending:
        return 'En Attente';
      case QuoteStatus.accepted:
        return 'Accepté';
      case QuoteStatus.rejected:
        return 'Rejeté';
      case QuoteStatus.invoiced:
        return 'Facturé';
    }
  }

  Color toColor() {
    switch (this) {
      case QuoteStatus.draft:
        return Colors.grey.shade600; // Couleur pour brouillon
      case QuoteStatus.pending:
        return Colors.orange.shade700;
      case QuoteStatus.accepted:
        return Colors.green.shade700;
      case QuoteStatus.rejected:
        return Colors.red.shade700;
      case QuoteStatus.invoiced:
        return Colors.blue.shade700;
    }
  }
}

class Quote {
  final String id;
  final String clientName; // Reverted to client name string
  final String description;
  final double amount;
  final DateTime proposalDate; // Date de proposition
  final int validityDurationDays; // Durée de validité en jours
  final QuoteStatus status;

  Quote({
    required this.id,
    required this.clientName, // Updated constructor
    required this.description,
    required this.amount,
    required this.proposalDate,
    required this.validityDurationDays,
    this.status = QuoteStatus.draft, // Statut par défaut: Brouillon
  });

  // Méthode copyWith pour faciliter la création d'une nouvelle instance avec des champs modifiés
  Quote copyWith({
    String? id,
    String? clientName, // Updated copyWith
    String? description,
    double? amount,
    DateTime? proposalDate,
    int? validityDurationDays,
    QuoteStatus? status,
  }) {
    return Quote(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName, // Updated copyWith
      description: description ?? this.description,
      amount: amount ?? this.amount,
      proposalDate: proposalDate ?? this.proposalDate,
      validityDurationDays: validityDurationDays ?? this.validityDurationDays,
      status: status ?? this.status,
    );
  }
}
