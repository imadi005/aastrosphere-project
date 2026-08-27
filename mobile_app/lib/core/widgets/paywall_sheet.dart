import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// The single paywall surface for the whole app — every "Unlock with
/// Premium" button (Chart, Insights, Circle, and the Ask out-of-credits
/// screen) opens this same sheet, so pricing only needs to be explained once.
///
/// Pricing itself is fetched live from /api/pricing (backend/pricing.js is
/// the single source of truth) rather than hardcoded here, so prices can
/// change without an app release.
class PaywallSheet {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PaywallSheetContent(),
    );
  }
}

class _PaywallSheetContent extends StatefulWidget {
  const _PaywallSheetContent();

  @override
  State<_PaywallSheetContent> createState() => _PaywallSheetContentState();
}

class _PaywallSheetContentState extends State<_PaywallSheetContent> {
  Map<String, dynamic>? _pricing;
  bool _loading = true;
  String? _error;
  String _selectedSubPlanId = 'sub_annual';

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
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, style: GoogleFonts.dmSans(color: secondary), textAlign: TextAlign.center),
                  ))
                : ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '✨ Unlock Everything',
                        style: GoogleFonts.cormorantGaramond(fontSize: 28, fontWeight: FontWeight.bold, color: gold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'One subscription unlocks your full Chart Analysis, complete Insights, unlimited compatibility reports, and unlimited Ask — everything, everywhere in the app.',
                        style: GoogleFonts.dmSans(fontSize: 13, height: 1.5, color: secondary),
                      ),
                      const SizedBox(height: 20),
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
                        'Subscribing unlocks every screen in the app, not just Ask. Packs and single questions are for Ask only.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(fontSize: 11, color: secondary),
                      ),
                    ],
                  ),
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
            onPressed: () => _handlePurchase(context, kind: 'subscription', id: _selectedSubPlanId),
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Subscribe', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700)),
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
              onTap: () => _handlePurchase(context, kind: 'pack', id: pack['id'] as String),
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

  void _handlePurchase(BuildContext context, {required String kind, required String id}) {
    // Play Billing / App Store purchase flow isn't wired up yet — this is
    // the one remaining piece (needs products created in Play Console /
    // App Store Connect first, then receipt verification calling
    // grantCredits()/activateSubscription() in authMiddleware.js).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payments are coming soon — check back shortly!')),
    );
  }
}
