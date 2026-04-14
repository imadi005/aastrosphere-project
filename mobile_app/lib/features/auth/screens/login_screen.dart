import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:aastrosphere/common/widgets/spinning_wheel.dart';
import 'package:aastrosphere/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aastrosphere/features/auth/screens/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role; // 'User' ya 'Astrologer'
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // --- LOGIC UPDATE HUA HAI ---
  void _sendOTP() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // User se '+91' nahi mangwayenge, khud add karenge.
    final String phoneNumber = '+91' + _phoneController.text.trim();

    // Ab 10 digit check karenge
    if (_phoneController.text.trim().length != 10) {
      setState(() {
        _isLoading = false;
        _errorText = 'Please enter a valid 10-digit phone number';
      });
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber, // Yahaan '+91' ke saath bhejenge
        
        verificationCompleted: (PhoneAuthCredential credential) {
          setState(() { _isLoading = false; });
          // TODO: Auto-verify logic yahaan daal sakte hain
        },
        
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
            _errorText = e.message ?? 'Failed to send OTP. Try again.';
          });
        },
        
        codeSent: (String verificationId, int? resendToken) {
          setState(() { _isLoading = false; });
          // User ko OTP screen pe bhejo
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  role: widget.role,
                  verificationId: verificationId,
                  phoneNumber: phoneNumber, // Poora number (+91 wala) pass karein
                ),
              ),
            );
          }
        },
        
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'An unknown error occurred.';
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // --- LAYER 1: SPINNING WHEEL (Background) ---
          Center(child: SpinningWheel()),

          // --- LAYER 2: LOGIN FORM (Foreground) ---
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              // Form fade-in animation
              child: FadeInUp(
                duration: const Duration(milliseconds: 500),
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
                      // Title (Dynamic)
                      Text(
                        '${widget.role} Login',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter your phone number to continue',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // --- YEH TEXT FIELD UPDATE HUA HAI ---
                      _CustomTextField(
                        controller: _phoneController,
                        hintText: '98765 43210', // Hint se +91 hata diya
                        icon: Icons.phone_android,
                        prefixText: '+91 ', // Prefix yahaan add kar diya
                      ),
                      // ---------------------------------

                      // Error text
                      const SizedBox(height: 16),
                      if (_errorText != null)
                        Text(
                          _errorText!,
                          style: TextStyle(color: Colors.red, fontSize: 12),
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
                          onPressed: _isLoading ? null : _sendOTP,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: CircularProgressIndicator(color: AppColors.bgLight),
                                )
                              : Text(
                                  'Get OTP',
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
          ),
        ],
      ),
    );
  }
}

// --- YEH WIDGET BHI UPDATE HUA HAI ---
class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final String? prefixText; // NAYA

  const _CustomTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.prefixText, // NAYA
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: 10, // NAYA: User ko 10 digit pe rok dega
      style: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16, letterSpacing: 1.5),
      decoration: InputDecoration(
        counterText: "", // MaxLength counter ko hide karega
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textSecondaryLight, letterSpacing: 0),
        
        // --- YEH PREFIX LOGIC NAYA ADD HUA HAI ---
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 20, right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.gold, size: 20),
              if (prefixText != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    prefixText!,
                    style: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
        // ------------------------------------------
        
        filled: true,
        fillColor: AppColors.bgLight.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
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