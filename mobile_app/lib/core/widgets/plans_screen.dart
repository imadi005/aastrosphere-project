import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// The single paywall surface for the whole app. Every purchase prompt —
/// PremiumLockCard's "Unlock with Premium" button, Ask's out-of-credits
/// moment, anywhere else a paywall is triggered — pushes this as a full
/// screen via [PlansScreen.open], never a bottom sheet or inline dialog.
/// That keeps pricing/feature explanation consistent in one place, and
/// because it's a normal Navigator push, popping it (on purchase success,
/// or via the back button) returns the user to exactly the screen and
/// state they were in when the prompt fired — no separate "return to"
/// bookkeeping needed.
///
/// Pricing itself is fetched live from /api/pricing (backend/pricing.js is
/// the single source of truth) rather than hardcoded here, so prices can
/// change without an app release.
class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  /// Pushes the plans screen on top of whatever the caller is showing.
  /// Awaiting this future resolves when the user leaves the screen (either
  /// by going back, or — once real billing is wired — after a purchase
  /// completes and the screen pops itself), so callers can refresh their
  /// data afterward if they want to reflect newly-unlocked content:
  ///   await PlansScreen.open(context);
  ///   ref.invalidate(someProvider); // pick up the new subscription state
  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PlansScreen()),
    );
  }

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  Map<String, dynamic>? _pricing;
  bool _loading = true;
  String? _error;
  String _selectedSubPlanId = 'sub_annual';
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getPricing();
      if (mounted) setState(() { _pricing = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load pricing. Check your connection.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(_error!, style: GoogleFonts.dmSans(color: secondary), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      TextButton(onPressed: () { setState(() => _loading = true); _load(); }, child: const Text('Retry')),
                    ]),
                  ))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    children: [
                      Text(
                        '✨ Unlock Everything',
                        style: GoogleFonts.cormorantGaramond(fontSize: 30, fontWeight: FontWeight.bold, color: gold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'One subscription unlocks every premium screen in the app.',
                        style: GoogleFonts.dmSans(fontSize: 13, height: 1.5, color: secondary),
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureList(isDark, gold, primary, secondary, border),
                      const SizedBox(height: 24),
                      ..._buildSubscriptionCards(isDark, gold, secondary, border),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(child: Divider(color: border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or just ask a few questions', style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
                          ),
                          Expanded(child: Divider(color: border)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._buildPackRow(isDark, gold, secondary, border),
                      const SizedBox(height: 16),
                      Text(
                        'Subscribing unlocks Chart, Insights, and Circle too. Packs and single questions are for Ask only.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(fontSize: 11, color: secondary),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildFeatureList(bool isDark, Color gold, Color primary, Color secondary, Color border) {
    const features = [
      (Icons.chat_bubble_outline_rounded, 'Unlimited Ask', 'Chat as much as you want, no credits to track'),
      (Icons.auto_awesome_rounded, 'Full Chart Day Analysis', 'Every finding for today — accident risk, opportunities, all of it'),
      (Icons.calendar_month_rounded, 'Complete Insights', 'Weekly, Monthly, Yearly, and your full Deep Profile'),
      (Icons.favorite_rounded, 'Unlimited Compatibility Reports', 'Check with anyone in your Circle, anytime'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        children: features.map((f) {
          final (icon, title, subtitle) = f;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: gold.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: primary)),
                  Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
                ]),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildSubscriptionCards(bool isDark, Color gold, Color secondary, Color border) {
    final plans = (_pricing?['subscription_plans'] as List? ?? []).cast<Map<String, dynamic>>();
    return plans.map<Widget>((plan) {
      final id = plan['id'] as String;
      final selected = _selectedSubPlanId == id;
      final label = plan['label'] as String;
      final price = plan['priceInr'] as int;
      final savings = plan['savingsLabel'] as String?;
      final periodDays = plan['periodDays'] as int;
      final perMonth = periodDays >= 300 ? (price / 12).round() : null;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () => setState(() => _selectedSubPlanId = id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? gold.withOpacity(0.1) : (isDark ? AppColors.bgCardDark : Colors.white),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? gold : border, width: selected ? 1.5 : 0.5),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: selected ? gold : secondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(label, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700)),
                          if (savings != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(20)),
                              child: Text(savings, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black87)),
                            ),
                          ],
                        ],
                      ),
                      if (perMonth != null)
                        Text('≈ ₹$perMonth/month', style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
                    ],
                  ),
                ),
                Text('₹$price', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: gold)),
              ],
            ),
          ),
        ),
      );
    }).toList()
      ..add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _purchasing ? null : () => _handlePurchase(kind: 'subscription', id: _selectedSubPlanId),
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _purchasing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.black87)))
                : Text('Subscribe', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      );
  }

  List<Widget> _buildPackRow(bool isDark, Color gold, Color secondary, Color border) {
    final packs = (_pricing?['question_packs'] as List? ?? []).cast<Map<String, dynamic>>();
    return [
      SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: packs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (ctx, i) {
            final pack = packs[i];
            final popular = pack['popular'] == true;
            return GestureDetector(
              onTap: _purchasing ? null : () => _handlePurchase(kind: 'pack', id: pack['id'] as String),
              child: Container(
                width: 110,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgCardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: popular ? gold : border, width: popular ? 1.2 : 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${pack['questions']} questions', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('₹${pack['priceInr']}', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: gold)),
                    if (popular) ...[
                      const SizedBox(height: 4),
                      Text('Popular', style: GoogleFonts.dmSans(fontSize: 10, color: gold, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  Future<void> _handlePurchase({required String kind, required String id}) async {
    // Play Billing / App Store purchase flow isn't wired up yet -- this is
    // the one remaining piece (needs products created in Play Console /
    // App Store Connect first, then receipt verification calling
    // grantCredits()/activateSubscription() in authMiddleware.js).
    //
    // Once wired, the success path here should look like:
    //   setState(() => _purchasing = true);
    //   final ok = await BillingService.purchase(kind: kind, productId: id);
    //   if (!mounted) return;
    //   setState(() => _purchasing = false);
    //   if (ok && mounted) Navigator.of(context).pop(); // returns to origin screen
    //   else showError(...);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payments are coming soon — check back shortly!')),
    );
  }
}
