import 'package:flutter/material.dart';
import '../../../core/services/analytics_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aastrosphere/common/widgets/spinning_wheel.dart';
import 'package:aastrosphere/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aastrosphere/features/auth/screens/signup_screen.dart';
import 'package:aastrosphere/features/home/screens/home_screen.dart';
import 'package:aastrosphere/features/auth/screens/astrologer_signup_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aastrosphere/features/auth/repository/auth_repository.dart';
import 'package:aastrosphere/core/providers/role_provider.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String role;
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.role,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOTP(String otp) async {
    if (_isLoading) return;
    if (otp.length != 6) {
      setState(() { _errorText = 'Please enter a valid 6-digit OTP'; });
      return;
    }
    setState(() { _isLoading = true; _errorText = null; });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      final UserCredential userCredential =
          await ref.read(firebaseAuthProvider).signInWithCredential(credential);
      final String uid = userCredential.user!.uid;
      await AnalyticsService.login('phone');

      final authRepo = ref.read(authRepositoryProvider);
      final roles = await authRepo.getUserRoles(uid);

      final bool userExists = roles['User'] != null;
      final bool astrologerExists = roles['Astrologer'] != null;
      final String wantedRole = widget.role;

      // Case 1: Both roles exist → respect wantedRole
      if (userExists && astrologerExists) {
        await _setRoleAndGoHome(wantedRole == 'Astrologer' ? AppRole.astrologer : AppRole.user);

      // Case 2: Only User exists
      } else if (userExists) {
        if (wantedRole == 'User') {
          await _setRoleAndGoHome(AppRole.user);
        } else {
          _showDualRoleDialog('User', 'Astrologer', () {
            _navigateToAstrologerSignUp();
          }, existingAppRole: AppRole.user);
        }

      // Case 3: Only Astrologer exists
      } else if (astrologerExists) {
        if (wantedRole == 'Astrologer') {
          await _setRoleAndGoHome(AppRole.astrologer);
        } else {
          _showDualRoleDialog('Astrologer', 'User', () {
            _navigateToUserSignUp();
          }, existingAppRole: AppRole.astrologer);
        }

      // Case 4: New user
      } else {
        if (wantedRole == 'User') {
          _navigateToUserSignUp();
        } else {
          _navigateToAstrologerSignUp();
        }
      }

    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = e.code == 'invalid-verification-code'
            ? 'The OTP entered is invalid. Please try again.'
            : 'An error occurred. Please try again.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'An unknown error occurred.';
      });
    }
  }

  /// Set role in provider (persists to SharedPreferences) then navigate home
  Future<void> _setRoleAndGoHome(AppRole role) async {
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid ?? '';
    await AnalyticsService.identify(uid, isAstrologer: role == AppRole.astrologer);
    await ref.read(roleProvider.notifier).setRole(role);
    _navigateToHome();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  void _navigateToUserSignUp() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen(
        role: widget.role,
        verificationId: widget.verificationId,
        phoneNumber: widget.phoneNumber,
      )),
      (route) => false,
    );
  }

  void _navigateToAstrologerSignUp() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AstrologerSignUpScreen(role: 'Astrologer')),
      (route) => false,
    );
  }

  void _showDualRoleDialog(
    String existingRole,
    String newRole,
    VoidCallback onYes, {
    required AppRole existingAppRole,
  }) {
    setState(() { _isLoading = false; });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCardLight,
        title: Text('Role Confirmation', style: Theme.of(context).textTheme.headlineSmall),
        content: Text(
          'You are already registered as a $existingRole. Do you want to proceed and register as a $newRole as well?',
          style: const TextStyle(color: AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryLight)),
            onPressed: () {
              Navigator.of(context).pop();
              // Go home with the existing role
              _setRoleAndGoHome(existingAppRole);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: Text('Yes, Register',
                style: const TextStyle(color: AppColors.bgLight, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
              onYes();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.cinzel(fontSize: 22, color: AppColors.textPrimaryLight),
      decoration: BoxDecoration(
        color: AppColors.bgLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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
                    Text('Verify Your Phone', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    Text(
                      'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Pinput(
                      controller: _otpController,
                      length: 6,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: AppColors.gold, width: 2),
                        ),
                      ),
                      onCompleted: (pin) => _verifyOTP(pin),
                    ),
                    const SizedBox(height: 16),
                    if (_errorText != null)
                      Text(_errorText!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : () => _verifyOTP(_otpController.text),
                        child: _isLoading
                            ? const SizedBox(height: 28, width: 28,
                                child: CircularProgressIndicator(color: AppColors.bgLight))
                            : Text('Verify & Continue',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.bgLight, fontWeight: FontWeight.bold)),
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
