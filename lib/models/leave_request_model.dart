import 'package:flutter/material.dart';

// Enum pour le type de congé (si pas déjà défini dans LeaveRequestPage)
enum LeaveType {
  paid, // Congé payé
  unpaid, // Congé sans solde
  sick, // Arrêt maladie
  maternity, // Congé maternité
  paternity, // Congé paternité
  other, // Autre
}

// Extension pour faciliter l'affichage des noms de type de congé (si pas déjà défini)
extension LeaveTypeExtension on LeaveType {
  String toDisplayString() {
    switch (this) {
      case LeaveType.paid:
        return 'Congé Payé';
      case LeaveType.unpaid:
        return 'Congé Sans Solde';
      case LeaveType.sick:
        return 'Arrêt Maladie';
      case LeaveType.maternity:
        return 'Congé Maternité';
      case LeaveType.paternity:
        return 'Congé Paternité';
      case LeaveType.other:
        return 'Autre';
    }
  }

  // Ajout d'une couleur associée pour la visualisation
  Color toColor() {
    switch (this) {
      case LeaveType.paid:
        return Colors.green.shade700;
      case LeaveType.unpaid:
        return Colors.orange.shade700;
      case LeaveType.sick:
        return Colors.blue.shade700;
      case LeaveType.maternity:
        return Colors.purple.shade700;
      case LeaveType.paternity:
        return Colors.teal.shade700;
      case LeaveType.other:
        return Colors.grey.shade700;
    }
  }
}

// Enum pour le statut de la demande de congé
enum LeaveStatus {
  pending, // En attente
  approved, // Approuvé
  rejected, // Rejeté
  cancelled, // Annulé
}

extension LeaveStatusExtension on LeaveStatus {
  String toDisplayString() {
    switch (this) {
      case LeaveStatus.pending:
        return 'En attente';
      case LeaveStatus.approved:
        return 'Approuvé';
      case LeaveStatus.rejected:
        return 'Rejeté';
      case LeaveStatus.cancelled:
        return 'Annulé';
    }
  }

  Color toColor() {
    switch (this) {
      case LeaveStatus.pending:
        return Colors.orange.shade600;
      case LeaveStatus.approved:
        return Colors.green.shade600;
      case LeaveStatus.rejected:
        return Colors.red.shade600;
      case LeaveStatus.cancelled:
        return Colors.grey.shade600;
    }
  }
}

class LeaveRequest {
  final String id;
  final String employeeName; // Qui demande le congé
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final DateTime requestDate; // Date de la demande
  final LeaveStatus status;
  final String? contactInfo; // Infos de contact pendant le congé
  final String? rejectionReason; // Raison du rejet si applicable

  LeaveRequest({
    required this.id,
    required this.employeeName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.requestDate,
    this.status = LeaveStatus.pending, // Statut par défaut
    this.contactInfo,
    this.rejectionReason,
  });

  // Helper to get number of days
  int get numberOfDays {
    return endDate.difference(startDate).inDays + 1;
  }
}
