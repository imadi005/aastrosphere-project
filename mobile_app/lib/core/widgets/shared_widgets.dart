import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../numerology/numerology_engine.dart';
import '../theme/app_theme.dart';

// ─── Astro Card ───────────────────────────────────────────────────────────────
class AstroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  const AstroCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = borderColor ??
        (isDark ? AppColors.borderDark : AppColors.borderLight);

    Widget card = Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.5),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ─── Gold Text ────────────────────────────────────────────────────────────────
class GoldText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final bool useSerif;

  const GoldText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.useSerif = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.goldLight : AppColors.gold;
    final style = useSerif
        ? GoogleFonts.cormorantGaramond(
            fontSize: fontSize, fontWeight: fontWeight, color: color)
        : GoogleFonts.dmSans(
            fontSize: fontSize, fontWeight: fontWeight, color: color);
    return Text(text, style: style);
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ─── Day Rating Badge ─────────────────────────────────────────────────────────
class DayBadge extends StatelessWidget {
  final DayRating rating;
  const DayBadge(this.rating, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg, text;
    String label;

    switch (rating) {
      case DayRating.favorable:
        bg = isDark ? AppColors.successBgDark : AppColors.successBg;
        text = isDark ? AppColors.successDark : AppColors.success;
        label = 'Favorable';
      case DayRating.caution:
        bg = isDark ? AppColors.warningBgDark : AppColors.warningBg;
        text = isDark ? AppColors.warningDark : AppColors.warning;
        label = 'Caution';
      case DayRating.avoid:
        bg = isDark ? AppColors.dangerBgDark : AppColors.dangerBg;
        text = isDark ? AppColors.dangerDark : AppColors.danger;
        label = 'Avoid';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: text),
      ),
    );
  }
}

// ─── Numerology Grid ──────────────────────────────────────────────────────────
class NumerologyGrid extends StatelessWidget {
  final List<List<GridCell>> grid;
  final double cellSize;

  const NumerologyGrid({
    super.key,
    required this.grid,
    this.cellSize = 68,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int r = 0; r < 3; r++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int c = 0; c < 3; c++)
                Padding(
                  padding: EdgeInsets.all(r == 2 && c == 2 ? 0 : 2),
                  child: _GridCell(
                    cell: grid[r][c],
                    size: cellSize,
                    isDark: isDark,
                  ),
                ),
            ],
          ),
        const SizedBox(height: 10),
        _GridLegend(isDark: isDark),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  final GridCell cell;
  final double size;
  final bool isDark;

  const _GridCell({required this.cell, required this.size, required this.isDark});

  Color _bgColor() {
    if (cell.isEmpty) return isDark ? const Color(0xFF141412) : const Color(0xFFF5F2EE);
    if (cell.isMaha) return isDark ? const Color(0xFF1F1A06) : const Color(0xFFFEF8E7);
    if (cell.isAntar) return isDark ? const Color(0xFF0D1A0F) : const Color(0xFFEDF7F0);
    if (cell.isMonthly) return isDark ? const Color(0xFF0F0F1F) : const Color(0xFFEEEEFD);
    return isDark ? const Color(0xFF181614) : const Color(0xFFFAF8F4);
  }

  Color _borderColor() {
    if (cell.isMaha) return isDark ? AppColors.goldLight : AppColors.gold;
    if (cell.isAntar) return isDark ? AppColors.successDark : AppColors.success;
    if (cell.isMonthly) return const Color(0xFF6366F1);
    return isDark ? AppColors.borderDark : AppColors.borderLight;
  }

  Color _numColor() {
    if (cell.isMaha) return isDark ? AppColors.goldLight : AppColors.gold;
    if (cell.isAntar) return isDark ? AppColors.successDark : AppColors.success;
    if (cell.isMonthly) return const Color(0xFF6366F1);
    return isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor(), width: cell.highlights.isNotEmpty ? 0.8 : 0.5),
      ),
      child: cell.isEmpty
          ? Center(
              child: Text('—',
                style: TextStyle(
                  color: (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                  fontSize: 18,
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  cell.number.toString(),
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: _numColor(),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cell.planet,
                  style: GoogleFonts.dmSans(
                    fontSize: 8,
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
    );
  }
}

class _GridLegend extends StatelessWidget {
  final bool isDark;
  const _GridLegend({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendItem(
          color: isDark ? AppColors.goldLight : AppColors.gold,
          bg: isDark ? const Color(0xFF1F1A06) : const Color(0xFFFEF8E7),
          label: 'Maha',
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _LegendItem(
          color: isDark ? AppColors.successDark : AppColors.success,
          bg: isDark ? const Color(0xFF0D1A0F) : const Color(0xFFEDF7F0),
          label: 'Antar',
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _LegendItem(
          color: const Color(0xFF6366F1),
          bg: isDark ? const Color(0xFF0F0F1F) : const Color(0xFFEEEEFD),
          label: 'Monthly',
          isDark: isDark,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color, bg;
  final String label;
  final bool isDark;

  const _LegendItem({required this.color, required this.bg, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: color, width: 0.8),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

// ─── Role Toggle ──────────────────────────────────────────────────────────────
class RoleToggle extends StatelessWidget {
  final bool isAstrologer;
  final VoidCallback onToggle;

  const RoleToggle({super.key, required this.isAstrologer, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveBg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;
    final activeBg = isDark ? const Color(0xFF1F1A06) : const Color(0xFFFEF8E7);
    final goldColor = isDark ? AppColors.goldLight : AppColors.gold;
    final mutedColor = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        decoration: BoxDecoration(
          color: inactiveBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Pill(
              label: 'User',
              active: !isAstrologer,
              activeBg: activeBg,
              activeColor: goldColor,
              inactiveColor: mutedColor,
            ),
            _Pill(
              label: 'Astrologer',
              active: isAstrologer,
              activeBg: activeBg,
              activeColor: goldColor,
              inactiveColor: mutedColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeBg, activeColor, inactiveColor;

  const _Pill({
    required this.label,
    required this.active,
    required this.activeBg,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: active ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: active ? FontWeight.w500 : FontWeight.w400,
          color: active ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}

// ─── Dark Mode Toggle ─────────────────────────────────────────────────────────
class ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const ThemeToggleButton({super.key, required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          size: 16,
          color: isDark ? AppColors.goldLight : AppColors.gold,
        ),
      ),
    );
  }
}
