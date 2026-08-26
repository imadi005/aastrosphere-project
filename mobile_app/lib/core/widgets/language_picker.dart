import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/locale_provider.dart';

/// Opens the "Select your language" bottom sheet. Call from anywhere —
/// the login screens and the post-login settings toggle both use this.
Future<void> showLanguagePicker(BuildContext context, WidgetRef ref) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.bgCardDark : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _LanguagePickerSheet(),
  );
}

class _LanguagePickerSheet extends ConsumerWidget {
  const _LanguagePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final currentCode = ref.watch(localeProvider).languageCode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: border, borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Select your language',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 20, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: kAppLanguages.length,
                itemBuilder: (ctx, i) {
                  final lang = kAppLanguages[i];
                  final selected = lang.code == currentCode;
                  return ListTile(
                    onTap: () {
                      ref.read(localeProvider.notifier).setLanguage(lang.code);
                      Navigator.of(ctx).pop();
                    },
                    leading: Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: selected ? gold : secondary.withOpacity(0.5),
                      size: 20,
                    ),
                    title: Row(
                      children: [
                        Text(lang.nativeName,
                            style: GoogleFonts.dmSans(
                              fontSize: 15, fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            )),
                        const SizedBox(width: 8),
                        Text(lang.englishName,
                            style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
                      ],
                    ),
                    trailing: lang.available
                        ? null
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Coming soon',
                                style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
