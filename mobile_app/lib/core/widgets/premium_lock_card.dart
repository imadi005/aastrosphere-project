import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'plans_screen.dart';

/// Renders whatever a gated API response's `locked`/`locked_preview` (or a
/// nested field's `locked`/`preview`) fields describe — a compact card with
/// the teaser text and an "Unlock with Premium" CTA that pushes [PlansScreen].
/// Used identically across Chart, Insights, and Circle so a subscriber only
/// ever needs to learn this one interaction, and popping the plans screen
/// (back button, or a successful purchase) always returns to this exact card.
class PremiumLockCard extends StatelessWidget {
  final String preview;
  final String? title;

  const PremiumLockCard({super.key, required this.preview, this.title});

  /// Reads `locked`/`locked_preview` off a decoded JSON map — the shape every
  /// gated endpoint in this app uses. Returns null if the map isn't locked,
  /// so callers can do `PremiumLockCard.fromJson(data) ?? realContentWidget`.
  static PremiumLockCard? fromJson(Map<String, dynamic>? data, {String? title}) {
    if (data == null || data['locked'] != true) return null;
    final preview = data['locked_preview'] as String? ?? data['preview'] as String?;
    return PremiumLockCard(preview: preview ?? '', title: title);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: gold.withOpacity(0.35), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_rounded, size: 16, color: gold),
              const SizedBox(width: 8),
              Text(
                title ?? 'Premium',
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: gold),
              ),
            ],
          ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              preview,
              style: GoogleFonts.dmSans(fontSize: 13, height: 1.5, color: secondary),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => PlansScreen.open(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide(color: border, width: 0),
              ),
              child: Text(
                'Unlock with Premium',
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
