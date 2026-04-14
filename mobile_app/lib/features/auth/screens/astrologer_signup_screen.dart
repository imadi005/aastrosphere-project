import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aastrosphere/common/widgets/spinning_wheel.dart';
import 'package:aastrosphere/core/theme/app_theme.dart';
import 'package:aastrosphere/features/home/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// YEH 'User' WALI SIGNUP SCREEN SE ALAG HAI
class AstrologerSignUpScreen extends StatefulWidget {
  final String role;
  const AstrologerSignUpScreen({super.key, required this.role});

  @override
  State<AstrologerSignUpScreen> createState() => _AstrologerSignUpScreenState();
}

class _AstrologerSignUpScreenState extends State<AstrologerSignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _dobRaw = ''; 
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1), // Astrologers ke liye different initial date
      firstDate: DateTime(1920, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: AppColors.bgLight,
              surface: AppColors.bgCardLight,
              onSurface: AppColors.textPrimaryLight,
            ),
            dialogBackgroundColor: AppColors.bgCardLight,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        _dobRaw = picked.toIso8601String(); 
      });
    }
  }

  void _saveUserData() async {
    if (_isLoading) return;

    final String name = _nameController.text.trim();
    final String dob = _dobController.text.trim();

    if (name.isEmpty || dob.isEmpty) {
      setState(() {
        _errorText = 'Please fill in all fields.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user found. Please login again.');
      }
      
      final String uid = currentUser.uid;
      final String? phoneNumber = currentUser.phoneNumber;

      // Data object mein TOB/POB nahi hai
      final Map<String, dynamic> userData = {
        'uid': uid,
        'phone_number': phoneNumber,
        'name': name,
        'dob': _dobRaw, 
        'role': widget.role, // 'Astrologer'
        'created_at': FieldValue.serverTimestamp(),
      };
      
      // Data ko Firestore mein 'astrologers' collection ke andar save karo
      // NOTE: Hum 'astrologers' collection use kar rahe hain, 'users' nahi
      await FirebaseFirestore.instance
          .collection('astrologers') // <-- ALAG COLLECTION
          .doc(uid) 
          .set(userData);
          
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()), // TODO: Astrologer Home Screen
          (route) => false,
        );
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Failed to save data. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Create Astrologer Profile'),
      ),
      body: Stack(
        children: [
          Center(child: SpinningWheel()),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.bgCardLight.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Astrologer Sign Up',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please provide your details for verification.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name Field
                    _CustomTextField(
                      controller: _nameController,
                      hintText: 'Enter your full name',
                      icon: Icons.person,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 20),
                    
                    // DOB Field
                    _CustomTextField(
                      controller: _dobController,
                      hintText: 'Select Date of Birth',
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: _selectDate,
                    ),
                    // TOB/POB fields yahaan nahi hain

                    const SizedBox(height: 16),
                    if (_errorText != null)
                      Text(
                        _errorText!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _saveUserData,
                        child: _isLoading
                            ? const SizedBox(
                                height: 28,
                                width: 28,
                                child: CircularProgressIndicator(color: AppColors.bgLight),
                              )
                            : Text(
                                'Save & Continue',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.bgLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// (Yeh _CustomTextField widget 'signup_screen.dart' se copy kiya hai)
class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  const _CustomTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textSecondaryLight),
        prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
        filled: true,
        fillColor: AppColors.bgLight.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gold.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gold, width: 2),
        ),
      ),
    );
  }
}