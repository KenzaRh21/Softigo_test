// lib/pages/factures_page.dart
import 'package:flutter/material.dart'; // Only import necessary for basic Flutter widgets

class FacturesPage extends StatelessWidget {
  const FacturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Your app's primary background color, or just white/light grey
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Factures (Simple Test)',
          style: TextStyle(color: Colors.white), // Title text color
        ),
        centerTitle: true,
        // Your app's main theme color for the AppBar
        backgroundColor: const Color(0xFF133F7B),
        elevation: 0, // No shadow for simplicity
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: Color(0xFF133F7B), // Icon color
            ),
            SizedBox(height: 16),
            Text(
              'This is a very simple Factures Page.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Content will go here later.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
