import 'package:flutter/material.dart'; // Only for Color, remove if not needed for the actual model

enum TicketStatus { open, inProgress, resolved, closed, pending }

extension TicketStatusExtension on TicketStatus {
  String toDisplayString() {
    switch (this) {
      case TicketStatus.open:
        return 'Ouvert';
      case TicketStatus.inProgress:
        return 'En cours';
      case TicketStatus.resolved:
        return 'Résolu';
      case TicketStatus.closed:
        return 'Fermé';
      case TicketStatus.pending:
        return 'En attente';
      default:
        return 'Inconnu';
    }
  }

  Color toColor() {
    switch (this) {
      case TicketStatus.open:
        return Colors.blue.shade700;
      case TicketStatus.inProgress:
        return Colors.orange.shade700;
      case TicketStatus.resolved:
        return Colors.green.shade700;
      case TicketStatus.closed:
        return Colors.grey.shade700;
      case TicketStatus.pending:
        return Colors.purple.shade700;
      default:
        return Colors.black;
    }
  }
}

class Ticket {
  final String id;
  final String subject;
  final String description;
  final String requestType;
  final String severity;
  final String assignedTo;
  final TicketStatus status;
  final DateTime creationDate;
  final String? thirdParty; // Optional
  final String? contactAddress; // Optional

  Ticket({
    required this.id,
    required this.subject,
    required this.description,
    required this.requestType,
    required this.severity,
    required this.assignedTo,
    required this.status,
    required this.creationDate,
    this.thirdParty,
    this.contactAddress,
  });

  // Factory constructor for creating a Ticket from a map (e.g., from JSON)
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      subject: json['subject'],
      description: json['description'],
      requestType: json['requestType'],
      severity: json['severity'],
      assignedTo: json['assignedTo'],
      status: TicketStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TicketStatus.open, // Default if not found
      ),
      creationDate: DateTime.parse(json['creationDate']),
      thirdParty: json['thirdParty'],
      contactAddress: json['contactAddress'],
    );
  }

  // Method to convert a Ticket to a map (e.g., for sending to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'description': description,
      'requestType': requestType,
      'severity': severity,
      'assignedTo': assignedTo,
      'status': status.toString().split('.').last, // Convert enum to string
      'creationDate': creationDate.toIso8601String(),
      'thirdParty': thirdParty,
      'contactAddress': contactAddress,
    };
  }
}
