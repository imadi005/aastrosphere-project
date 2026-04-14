import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aastrosphere/core/theme/app_theme.dart';
import 'package:aastrosphere/features/shell/app_shell.dart';

class SignUpScreen extends StatefulWidget {
  final String role;
  final String verificationId;
  final String phoneNumber;

  const SignUpScreen({
    super.key,
    required this.role,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _selectedDob;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty || _selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'dob': Timestamp.fromDate(_selectedDob!),
        'phone': widget.phoneNumber,
        'isAstrologer': widget.role == 'Astrologer',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppShell()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              FadeInDown(
                child: Text('Tell us about yourself',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Text('Your chart will be calculated from this',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondary)),
              ),
              const SizedBox(height: 40),

              // Name
              _FieldLabel('Full name', gold),
              const SizedBox(height: 8),
              _InputField(
                controller: _nameController,
                hint: 'Enter your full name',
                icon: Icons.person_outline,
                gold: gold,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // DOB
              _FieldLabel('Date of birth', gold),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: gold, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        _dobController.text.isEmpty ? 'Select date of birth' : _dobController.text,
                        style: TextStyle(
                          color: _dobController.text.isEmpty ? secondary : 
                            (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: AppColors.bgLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: AppColors.bgLight, strokeWidth: 2),
                        )
                      : Text('Continue',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
                              color: AppColors.bgLight)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final Color gold;
  const _FieldLabel(this.text, this.gold);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(fontSize: 12, color: gold,
            fontWeight: FontWeight.w500, letterSpacing: 0.5));
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color gold;
  final bool isDark;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.gold,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return TextField(
      controller: controller,
      style: TextStyle(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: secondary),
        prefixIcon: Icon(icon, color: gold, size: 18),
        filled: true,
        fillColor: isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: gold, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
