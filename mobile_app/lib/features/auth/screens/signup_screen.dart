import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aastrosphere/common/widgets/spinning_wheel.dart';
import 'package:aastrosphere/core/theme/app_theme.dart';
import 'package:aastrosphere/features/home/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// --- NAYE IMPORTS ---
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart'; 
import 'package:aastrosphere/common/constants/api_keys.dart'; // API Key import
// --------------------

class SignUpScreen extends StatefulWidget {
  final String role;
  const SignUpScreen({super.key, required this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _tobController = TextEditingController();
  final TextEditingController _pobController = TextEditingController(); 

  String _dobRaw = ''; 
  String _tobRaw = '';
  String _pobName = '';
  double? _pobLat;
  double? _pobLng;
  
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _tobController.dispose();
    _pobController.dispose(); 
    super.dispose();
  }

  // _selectDate() function
  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
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

  // _selectTime() function
  void _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
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
        _tobController.text = picked.format(context); 
        _tobRaw = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  // _saveUserData() function
  void _saveUserData() async {
    if (_isLoading) return;

    final String name = _nameController.text.trim();
    final String dob = _dobController.text.trim();
    final String pob = _pobName; 

    if (name.isEmpty || dob.isEmpty) {
      setState(() {
        _errorText = 'Please fill in all mandatory fields (Name & DOB).';
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

      final Map<String, dynamic> userData = {
        'uid': uid,
        'phone_number': phoneNumber,
        'name': name,
        'dob': _dobRaw, 
        'role': widget.role,
        'created_at': FieldValue.serverTimestamp(),
      };

      if (_tobController.text.trim().isNotEmpty) {
        userData['tob'] = _tobRaw; 
      }
      if (pob.isNotEmpty) {
        userData['pob_name'] = _pobName;
        userData['pob_lat'] = _pobLat;
        userData['pob_lng'] = _pobLng;
      }
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid) 
          .set(userData);
          
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
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
        title: Text('Create Your Profile (${widget.role})'),
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
                      'One Last Step',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We need your Name and Date of Birth for predictions.',
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
                    const SizedBox(height: 20),

                    // TOB Field
                    _CustomTextField(
                      controller: _tobController,
                      hintText: 'Time of Birth (Optional)',
                      icon: Icons.access_time,
                      readOnly: true,
                      onTap: _selectTime,
                    ),
                    
                    // POB Field
                    const SizedBox(height: 20),
                    GooglePlaceAutoCompleteTextField(
                      textEditingController: _pobController,
                      googleAPIKey: kGooglePlacesApiKey, 
                      countries: const ["in", "us", "ca", "au", "gb", "sg"], 
                      inputDecoration: InputDecoration(
                        hintText: 'Place of Birth (Optional)',
                        hintStyle: TextStyle(color: AppColors.textSecondaryLight),
                        prefixIcon: Icon(Icons.location_on, color: AppColors.gold, size: 20),
                        filled: true,
                        fillColor: AppColors.bgLight.withOpacity(0.5),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.gold.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.gold, width: 2),
                        ),
                      ),
                      textStyle: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16),
                      
                      itemClick: (Prediction place) {
                        _pobController.text = place.description ?? 'Unknown Location';
                        setState(() {
                          _pobName = place.description ?? 'Unknown Location';
                          _pobLat = double.tryParse(place.lat ?? '');
                          _pobLng = double.tryParse(place.lng ?? '');
                        });
                        FocusScope.of(context).unfocus(); 
                      },
                      
                      itemBuilder: (context, i, Prediction place) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Text(place.description ?? '', style: TextStyle(color: AppColors.textPrimaryLight)),
                        );
                      },
                      isLatLngRequired: true, 
                      containerHorizontalPadding: 10,
                      containerVerticalPadding: 10,
                    ),

                    const SizedBox(height: 16),
                    if (_errorText != null)
                      Text(
                        _errorText!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    
                    const SizedBox(height: 24),
                    // Button
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
                            ? SizedBox(
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

// Custom Text Field Widget
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
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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