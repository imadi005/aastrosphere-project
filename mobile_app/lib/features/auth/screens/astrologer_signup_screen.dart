import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aastrosphere/common/widgets/spinning_wheel.dart';
import 'package:aastrosphere/core/theme/app_theme.dart';
import 'package:aastrosphere/features/home/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aastrosphere/core/providers/role_provider.dart';

class AstrologerSignUpScreen extends ConsumerStatefulWidget {
  final String role;
  const AstrologerSignUpScreen({super.key, required this.role});

  @override
  ConsumerState<AstrologerSignUpScreen> createState() =>
      _AstrologerSignUpScreenState();
}

class _AstrologerSignUpScreenState
    extends ConsumerState<AstrologerSignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDob;
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
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1920, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
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
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
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
      if (currentUser == null)
        throw Exception('No user found. Please login again.');
      final String uid = currentUser.uid;
      final String? phoneNumber = currentUser.phoneNumber;
      final dobTimestamp = Timestamp.fromDate(DateTime.parse(_dobRaw));

      final Map<String, dynamic> userData = {
        'uid': uid,
        'phone': phoneNumber,
        'name': name,
        'dob': dobTimestamp,
        'role': widget.role,
        'created_at': FieldValue.serverTimestamp(),
      };

      // Save to astrologers collection
      await FirebaseFirestore.instance
          .collection('astrologers')
          .doc(uid)
          .set(userData);

      // Also save to users collection with isAstrologer:true
      // so userProfileProvider works for toggle chip etc.
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'phone': phoneNumber,
        'name': name,
        'dob': dobTimestamp,
        'isAstrologer': true,
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Set role to astrologer before navigating
      await ref.read(roleProvider.notifier).setRole(AppRole.astrologer);

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
        title: const Text('Create Astrologer Profile'),
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
                    Text('Astrologer Sign Up',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    Text('Please provide your details.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 24),
                    _NumberStrip(gold: AppColors.gold),
                    const SizedBox(height: 28),
                    _CustomTextField(
                        controller: _nameController,
                        hintText: 'Enter your full name',
                        icon: Icons.person,
                        keyboardType: TextInputType.name),
                    const SizedBox(height: 20),
                    _BirthDatePortal(
                      selectedDob: _selectedDob,
                      onTap: _selectDate,
                      gold: AppColors.gold,
                    ),
                    const SizedBox(height: 16),
                    if (_errorText != null)
                      Text(_errorText!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : _saveUserData,
                        child: _isLoading
                            ? const SizedBox(
                                height: 28,
                                width: 28,
                                child: CircularProgressIndicator(
                                    color: AppColors.bgLight))
                            : Text('Save & Continue',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        color: AppColors.bgLight,
                                        fontWeight: FontWeight.bold)),
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

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;

  const _CustomTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimaryLight, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textSecondaryLight),
        prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
        filled: true,
        fillColor: AppColors.bgLight.withOpacity(0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.gold.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gold, width: 2)),
      ),
    );
  }
}

class _NumberStrip extends StatelessWidget {
  final Color gold;

  const _NumberStrip({required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.bgCardLight.withOpacity(0.78),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.18), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(9, (index) {
          final n = index + 1;
          return Text(
            '$n',
            style: GoogleFonts.cormorantGaramond(
              fontSize: n == 1 || n == 9 ? 22 : 18,
              color: gold.withOpacity(n == 1 || n == 9 ? 0.92 : 0.54),
              fontWeight: FontWeight.w500,
            ),
          );
        }),
      ),
    );
  }
}

class _BirthDatePortal extends StatelessWidget {
  final DateTime? selectedDob;
  final VoidCallback onTap;
  final Color gold;

  const _BirthDatePortal({
    required this.selectedDob,
    required this.onTap,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final dob = selectedDob;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgLight.withOpacity(0.58),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: dob == null
                  ? AppColors.gold.withOpacity(0.34)
                  : gold.withOpacity(0.6),
              width: 0.7,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: gold.withOpacity(0.36), width: 0.7),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/zodiac_circle_gold.png'),
                    fit: BoxFit.cover,
                    opacity: 0.18,
                  ),
                ),
                child:
                    Icon(Icons.calendar_month_outlined, color: gold, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: dob == null
                    ? Text(
                        'Select Date of Birth',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                      )
                    : Row(
                        children: [
                          _DateTile(
                              value: dob.day.toString().padLeft(2, '0'),
                              label: 'Day',
                              gold: gold),
                          const SizedBox(width: 8),
                          _DateTile(
                              value: dob.month.toString().padLeft(2, '0'),
                              label: 'Month',
                              gold: gold),
                          const SizedBox(width: 8),
                          _DateTile(
                              value: '${dob.year}', label: 'Year', gold: gold),
                        ],
                      ),
              ),
              const Icon(Icons.expand_more,
                  color: AppColors.textPrimaryLight, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String value;
  final String label;
  final Color gold;

  const _DateTile({
    required this.value,
    required this.label,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            style: GoogleFonts.cormorantGaramond(
              fontSize: value.length > 2 ? 18 : 22,
              height: 1,
              color: gold,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: gold.withOpacity(0.62),
            ),
          ),
        ],
      ),
    );
  }
}
