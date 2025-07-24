import 'package:flutter/material.dart';

enum UserRole { admin, manager, employee }

extension UserRoleExtension on UserRole {
  String toDisplayString() {
    switch (this) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.manager:
        return 'Manager';
      case UserRole.employee:
        return 'Employé';
    }
  }

  Color toColor() {
    switch (this) {
      case UserRole.admin:
        return Colors.red.shade700;
      case UserRole.manager:
        return Colors.blue.shade700;
      case UserRole.employee:
        return Colors.green.shade700;
    }
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
  });
}
