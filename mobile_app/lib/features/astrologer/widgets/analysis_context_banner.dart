import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

/// A compact, consistent reminder of whose chart is being read. Chart keeps
/// the editable picker; the other astrologer tools use this read-only context
/// so no screen silently switches people while the astrologer is working.
class AnalysisContextBanner extends StatelessWidget {
  final DateTime dob;
  final bool isClient;
  final String clientName;
  const AnalysisContextBanner({
    super.key,
    required this.dob,
    required this.isClient,
    required this.clientName,
  });

  String _format(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final label = isClient
        ? (clientName.trim().isEmpty ? 'Client' : clientName.trim())
        : 'My chart';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 27,
          height: 27,
          decoration: BoxDecoration(color: gold.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(isClient ? Icons.person_outline : Icons.person, size: 15, color: gold),
        ),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(fontSize: 11, color: primary, fontWeight: FontWeight.w600)),
          Text('DOB · ${_format(dob)}',
              style: GoogleFonts.dmSans(fontSize: 9, color: secondary)),
        ])),
        Text(isClient ? 'CLIENT VIEW' : 'MY VIEW',
            style: GoogleFonts.dmSans(fontSize: 8, color: gold,
                fontWeight: FontWeight.w700, letterSpacing: 0.6)),
      ]),
    );
  }
}
