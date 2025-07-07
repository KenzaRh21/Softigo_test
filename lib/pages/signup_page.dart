// lib/pages/signup_page.dart
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // State variable to toggle password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;


  // the email validation

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed from the widget tree
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar as requested
      body: Center(
        // SingleChildScrollView prevents overflow when the keyboard appears
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Back Button (positioned at the top left of the content area)
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context); // Navigates back to the previous page
                  },
                ),
              ),
              const SizedBox(height: 20), // Space between back button and logo

              // Logo centered at the top
              Image.asset(
                'assets/images/softigo_-removebg-preview.png', // Path to your logo
                height: 100, // Adjust height as needed
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30), // Space between logo and title

              const Text(
                'Create Your Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color (0xFF177F23), // Adjust color as per your brand
                ),
              ),
              const SizedBox(height: 40),

              // Card for the input fields and button with shadow
              Card(
                elevation: 10, // Gives the card a shadow effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded corners for the card
                ),
                color : Color (0xFFFDFDFD),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      // Name Input Field
                      TextField(
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color (0xFF177F23), width: 2), // Adjust color
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Input Field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color (0xFF177F23), width: 2), // Adjust color
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Input Field with Eye Icon
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible, // Toggles visibility based on state
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Create your password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Theme.of(context).primaryColorDark, // Use theme color
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible; // Toggle state
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color (0xFF177F23), width: 2), // Adjust color
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password Input Field with Eye Icon
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible, // Toggles visibility based on state
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter your password',
                          prefixIcon: const Icon(Icons.lock_open),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Theme.of(context).primaryColorDark, // Use theme color
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible; // Toggle state
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color (0xFF177F23), width: 2), // Adjust color
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity, // Makes the button full width
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement sign up logic
                            final name = _nameController.text;
                            final email = _emailController.text;
                            final password = _passwordController.text;
                            final confirmPassword = _confirmPasswordController.text;

                            if (password != confirmPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Passwords do not match!')),
                              );
                              return;
                            }

                            print('Attempting sign up with: Name: $name, Email: $email, Password: $password');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Signing up $email...')),
                            );
                            // Example: Navigate to home page after successful sign up
                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color (0xFF177F23), // Button background color (adjust to your logo's green)
                            foregroundColor: Colors.white, // Text color
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}