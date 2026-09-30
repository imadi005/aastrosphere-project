import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/widgets/plans_screen.dart';
import '../../core/services/api_service.dart';
import '../../core/services/purchase_service.dart';
import '../auth/providers/user_provider.dart';

/// Full account page: editable profile (name/DOB), subscription status,
/// questions remaining, and past purchase history. Reached via the account
/// icon in the top-right corner of the user shell's app bar.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  Map<String, dynamic>? _credits;
  List<dynamic>? _purchases;
  bool _loadingCredits = true;
  bool _loadingPurchases = true;
  Map<String, dynamic>? _pendingPurchase;

  @override
  void initState() {
    super.initState();
    _loadCredits();
    _loadPurchases();
    _checkPending();
  }

  Future<void> _checkPending() async {
    final p = await PurchaseService.getPendingPurchase();
    if (mounted) setState(() => _pendingPurchase = p);
  }

  Future<void> _loadCredits() async {
    try {
      final r = await ApiService.getCredits();
      if (mounted) setState(() { _credits = r; _loadingCredits = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingCredits = false);
    }
  }

  Future<void> _loadPurchases() async {
    try {
      final r = await ApiService.getPurchaseHistory();
      if (mounted) setState(() { _purchases = r; _loadingPurchases = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingPurchases = false);
    }
  }

  Future<void> _refreshAfterPlansScreen() async {
    setState(() { _loadingCredits = true; _loadingPurchases = true; });
    await Future.wait([_loadCredits(), _loadPurchases(), _checkPending()]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Account', style: GoogleFonts.cormorantGaramond(
            fontSize: 20, fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
      ),
      body: userAsync.when(
        loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
        error: (_, __) => Center(child: Text('Could not load your profile.', style: GoogleFonts.dmSans(color: secondary))),
        data: (user) {
          if (user == null) return Center(child: Text('No profile found.', style: GoogleFonts.dmSans(color: secondary)));
          return RefreshIndicator(
            onRefresh: () async { await Future.wait([_loadCredits(), _loadPurchases(), _checkPending()]); },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
              children: [
                if (_pendingPurchase != null) ...[
                  PendingPurchaseBanner(isDark: isDark, gold: gold, secondary: secondary),
                  const SizedBox(height: 16),
                ],
                _EditableProfileCard(user: user, isDark: isDark, gold: gold),
                SectionLabel('Subscription'),
                _SubscriptionCard(
                  isDark: isDark, gold: gold,
                  loading: _loadingCredits,
                  credits: _credits,
                  onManage: () async {
                    await PlansScreen.open(context);
                    _refreshAfterPlansScreen();
                  },
                ),
                SectionLabel('Past Purchases'),
                _PurchaseHistoryCard(isDark: isDark, loading: _loadingPurchases, purchases: _purchases),
                const SizedBox(height: 24),
                Center(child: GestureDetector(
                  onTap: () => FirebaseAuth.instance.signOut(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Sign Out', style: GoogleFonts.dmSans(fontSize: 13, color: secondary)),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Editable profile card ──────────────────────────────────────────────────
class _EditableProfileCard extends ConsumerStatefulWidget {
  final UserProfile user;
  final bool isDark;
  final Color gold;
  const _EditableProfileCard({required this.user, required this.isDark, required this.gold});

  @override
  ConsumerState<_EditableProfileCard> createState() => _EditableProfileCardState();
}

class _EditableProfileCardState extends ConsumerState<_EditableProfileCard> {
  late TextEditingController _nameCtrl;
  late DateTime _dob;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _dob = widget.user.dob;
  }

  @override
  void didUpdateWidget(covariant _EditableProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.user.uid == widget.user.uid) {
      _nameCtrl.text = widget.user.name;
      _dob = widget.user.dob;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final save = ref.read(saveUserProfileProvider);
      await save(UserProfile(
        uid: widget.user.uid,
        name: _nameCtrl.text.trim(),
        dob: _dob,
        phone: widget.user.phone,
        isAstrologer: widget.user.isAstrologer,
      ));
      if (mounted) setState(() { _editing = false; _saving = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Please try again.')),
        );
      }
    }
  }

  String _dobStr(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final gold = widget.gold;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 50, height: 50,
                decoration: BoxDecoration(
                    color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: gold.withOpacity(0.3), width: 0.5)),
                child: Center(child: Text(
                    widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : 'A',
                    style: GoogleFonts.cormorantGaramond(fontSize: 24, color: gold)))),
            const SizedBox(width: 14),
            Expanded(
              child: _editing
                  ? TextField(
                      controller: _nameCtrl,
                      style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: primary),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Your name',
                        border: UnderlineInputBorder(borderSide: BorderSide(color: border)),
                      ),
                    )
                  : Text(widget.user.name, style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w500, color: primary)),
            ),
            if (!_editing)
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 18, color: secondary),
                onPressed: () => setState(() => _editing = true),
                tooltip: 'Edit profile',
              ),
          ]),
          const SizedBox(height: 14),
          Divider(color: border, height: 1, thickness: 0.5),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Date of Birth',
            valueWidget: _editing
                ? GestureDetector(
                    onTap: _pickDob,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(_dobStr(_dob), style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: gold)),
                      const SizedBox(width: 4),
                      Icon(Icons.calendar_today_outlined, size: 13, color: gold),
                    ]),
                  )
                : Text(_dobStr(_dob), style: GoogleFonts.dmSans(fontSize: 13, color: primary)),
            secondary: secondary,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Phone',
            valueWidget: Text(widget.user.phone, style: GoogleFonts.dmSans(fontSize: 13, color: primary)),
            secondary: secondary,
          ),
          if (_editing) ...[
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => setState(() {
                    _editing = false;
                    _nameCtrl.text = widget.user.name;
                    _dob = widget.user.dob;
                  }),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black87),
                  child: _saving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                      : const Text('Save'),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final Widget valueWidget;
  final Color secondary;
  const _InfoRow({required this.label, required this.valueWidget, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
        valueWidget,
      ],
    );
  }
}

// ─── Subscription + credits card ───────────────────────────────────────────
class _SubscriptionCard extends StatelessWidget {
  final bool isDark;
  final Color gold;
  final bool loading;
  final Map<String, dynamic>? credits;
  final VoidCallback onManage;
  const _SubscriptionCard({
    required this.isDark, required this.gold, required this.loading,
    required this.credits, required this.onManage,
  });

  String _expiryStr(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;

    if (loading) {
      return AstroCard(
        padding: const EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
      );
    }

    final isActive = credits?['subscriptionActive'] == true;
    final expiresAt = credits?['subscriptionExpiresAt'] as int?;
    final creditsLeft = credits?['credits'] as int? ?? 0;

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(isActive ? Icons.workspace_premium : Icons.workspace_premium_outlined,
                size: 18, color: isActive ? successColor : secondary),
            const SizedBox(width: 8),
            Text(isActive ? 'Premium — Active' : 'Not subscribed',
                style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600,
                    color: isActive ? successColor : primary)),
          ]),
          if (isActive && expiresAt != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text('Renews / expires ${_expiryStr(expiresAt)}',
                  style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
            ),
          ],
          const SizedBox(height: 14),
          Divider(color: border, height: 1, thickness: 0.5),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Questions left', style: GoogleFonts.dmSans(fontSize: 13, color: secondary)),
              Text(
                isActive ? 'Unlimited' : '$creditsLeft',
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: gold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onManage,
              style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black87),
              child: Text(isActive ? 'Manage Plan' : 'Buy Questions / Subscribe'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Past purchases card ───────────────────────────────────────────────────
class _PurchaseHistoryCard extends StatelessWidget {
  final bool isDark;
  final bool loading;
  final List<dynamic>? purchases;
  const _PurchaseHistoryCard({required this.isDark, required this.loading, required this.purchases});

  String _dateStr(int? ms) {
    if (ms == null) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    if (loading) {
      return AstroCard(
        padding: const EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
      );
    }

    final list = purchases ?? [];
    if (list.isEmpty) {
      return AstroCard(
        padding: const EdgeInsets.all(16),
        child: Text('No purchases yet.', style: GoogleFonts.dmSans(fontSize: 13, color: secondary)),
      );
    }

    return AstroCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: list.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value as Map<String, dynamic>;
          return Column(children: [
            if (i > 0) Divider(color: border, height: 1, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['label'] as String? ?? p['productId'] as String? ?? '',
                          style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: primary)),
                      const SizedBox(height: 2),
                      Text(_dateStr(p['createdAt'] as int?),
                          style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
                    ],
                  ),
                ),
                if (p['priceInr'] != null)
                  Text('₹${p['priceInr']}', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: gold)),
              ]),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}
