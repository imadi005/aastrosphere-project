import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/api_service.dart';

class Friend {
  final String id, name;
  final DateTime dob;
  final String? relation;
  Friend({required this.id, required this.name, required this.dob, this.relation});

  factory Friend.fromMap(String id, Map<String, dynamic> m) => Friend(
    id: id,
    name: m['name'] as String,
    dob: (m['dob'] as Timestamp).toDate(),
    relation: m['relation'] as String?,
  );
}

final friendsProvider = StreamProvider<List<Friend>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('users').doc(uid).collection('friends')
      .snapshots()
      .map((s) => s.docs.map((d) => Friend.fromMap(d.id, d.data())).toList());
});

class CircleScreen extends ConsumerWidget {
  const CircleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final friendsAsync = ref.watch(friendsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: gold,
        onPressed: () => _showAddFriend(context, isDark, gold),
        child: const Icon(Icons.person_add_outlined, size: 20, color: Colors.black),
      ),
      body: friendsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
        error: (_, __) => Center(child: Text('Error', style: GoogleFonts.dmSans(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))),
        data: (friends) => friends.isEmpty
            ? _EmptyCircle(isDark: isDark, gold: gold, onAdd: () => _showAddFriend(context, isDark, gold))
            : _FriendsList(friends: friends, isDark: isDark, gold: gold),
      ),
    );
  }

  void _showAddFriend(BuildContext context, bool isDark, Color gold) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddFriendSheet(isDark: isDark, gold: gold),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyCircle extends StatelessWidget {
  final bool isDark; final Color gold; final VoidCallback onAdd;
  const _EmptyCircle({required this.isDark, required this.gold, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Your Circle', style: GoogleFonts.cormorantGaramond(fontSize: 24, color: gold)),
      const SizedBox(height: 8),
      Text('Add anyone — partner, friend, family, colleague',
          style: GoogleFonts.dmSans(fontSize: 13, color: secondary), textAlign: TextAlign.center),
      const SizedBox(height: 6),
      Text('See how your numbers interact', style: GoogleFonts.dmSans(fontSize: 12, color: secondary.withOpacity(0.6))),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: onAdd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(24),
              border: Border.all(color: gold.withOpacity(0.3), width: 0.5)),
          child: Text('Add someone', style: GoogleFonts.dmSans(fontSize: 13, color: gold)),
        ),
      ),
    ]));
  }
}

// ─── Friends list ─────────────────────────────────────────────────────────────
class _FriendsList extends StatelessWidget {
  final List<Friend> friends; final bool isDark; final Color gold;
  const _FriendsList({required this.friends, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Text('Your Circle', style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold)),
        Text('${friends.length} ${friends.length == 1 ? 'person' : 'people'} — tap to see full reading',
            style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
        const SizedBox(height: 16),
        ...friends.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FriendCard(friend: f, isDark: isDark, gold: gold),
        )),
      ],
    );
  }
}

// ─── Friend card (expandable) ─────────────────────────────────────────────────
class _FriendCard extends StatefulWidget {
  final Friend friend; final bool isDark; final Color gold;
  const _FriendCard({required this.friend, required this.isDark, required this.gold});

  @override
  State<_FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends State<_FriendCard> {
  Map<String, dynamic>? _compat;
  bool _loading = false;
  bool _expanded = false;
  int _activeTab = 0; // 0=Today 1=Overall 2=Details

  Future<void> _loadCompat() async {
    if (_compat != null) return;
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final myDob = (userDoc.data()?['dob'] as Timestamp?)?.toDate();
      if (myDob == null) return;
      final result = await ApiService.getCompatibility(
        myDob.toIso8601String(),
        widget.friend.dob.toIso8601String(),
        clientDate: ApiService.clientDate,
        clientHour: ApiService.clientHour,
        relation: widget.friend.relation,
      );
      if (mounted) setState(() { _compat = result; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCompat();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final gold = widget.gold;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final score = _compat?['score'] as int?;
    final level = _compat?['level'] as String?;
    final today = _compat?['today'] as Map<String, dynamic>?;
    final todayScore = today?['score'] as int?;

    Color scoreColor(int? s) {
      if (s == null) return gold;
      if (s >= 75) return isDark ? AppColors.successDark : AppColors.success;
      if (s >= 50) return gold;
      return isDark ? AppColors.dangerDark : AppColors.danger;
    }

    return AstroCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ── Header row ──────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                // Avatar
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(22)),
                  child: Center(child: Text(widget.friend.name[0].toUpperCase(),
                      style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold))),
                ),
                const SizedBox(width: 12),
                // Name + relation
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.friend.name, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: primary)),
                  if (widget.friend.relation != null)
                    Text(widget.friend.relation!, style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
                  Text(_dobStr(widget.friend.dob), style: GoogleFonts.dmSans(fontSize: 11, color: secondary.withOpacity(0.7))),
                ])),
                // Score + today indicator
                if (_loading) SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 1.5, color: gold))
                else if (score != null) Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('$score%', style: GoogleFonts.cormorantGaramond(fontSize: 26, color: scoreColor(score), height: 1)),
                  if (todayScore != null)
                    Text('Today: $todayScore%', style: GoogleFonts.dmSans(fontSize: 10, color: scoreColor(todayScore))),
                ]),
                const SizedBox(width: 8),
                Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: secondary),
              ]),
            ),
          ),

          // ── Expanded content ─────────────────────────────────────
          if (_expanded && _compat != null) ...[
            Divider(color: border, height: 1, thickness: 0.5),

            // Tab bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(children: [
                _Tab(label: 'Today', active: _activeTab == 0, gold: gold, isDark: isDark, onTap: () => setState(() => _activeTab = 0)),
                const SizedBox(width: 8),
                _Tab(label: 'Overall', active: _activeTab == 1, gold: gold, isDark: isDark, onTap: () => setState(() => _activeTab = 1)),
                const SizedBox(width: 8),
                _Tab(label: 'Dynamics', active: _activeTab == 2, gold: gold, isDark: isDark, onTap: () => setState(() => _activeTab = 2)),
              ]),
            ),

            // Tab content
            Padding(
              padding: const EdgeInsets.all(16),
              child: _activeTab == 0
                  ? _TodayTab(today: today!, isDark: isDark, gold: gold)
                  : _activeTab == 1
                      ? _OverallTab(compat: _compat!, isDark: isDark, gold: gold)
                      : _DynamicsTab(compat: _compat!, isDark: isDark, gold: gold),
            ),

            // Delete button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: GestureDetector(
                onTap: () => _deleteFriend(context),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Icon(Icons.remove_circle_outline, size: 14, color: secondary.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Text('Remove', style: GoogleFonts.dmSans(fontSize: 11, color: secondary.withOpacity(0.5))),
                ]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _deleteFriend(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users').doc(uid).collection('friends').doc(widget.friend.id).delete();
  }

  String _dobStr(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }
}

// ─── Tab widget ───────────────────────────────────────────────────────────────
class _Tab extends StatelessWidget {
  final String label; final bool active, isDark; final Color gold; final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.isDark, required this.gold, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? gold.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? gold.withOpacity(0.4) : (isDark ? AppColors.borderDark : AppColors.borderLight), width: 0.5),
        ),
        child: Text(label, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? gold : secondary)),
      ),
    );
  }
}

// ─── TODAY TAB ────────────────────────────────────────────────────────────────
class _TodayTab extends StatelessWidget {
  final Map<String, dynamic> today; final bool isDark; final Color gold;
  const _TodayTab({required this.today, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;

    final todayScore = today['score'] as int? ?? 50;
    final headline = today['headline'] as String? ?? '';
    final detail = today['detail'] as String? ?? '';
    final dayLabel = today['day_label'] as String? ?? '';
    final doList = (today['do_together'] as List? ?? []).cast<String>();
    final watchList = (today['watch_together'] as List? ?? []).cast<String>();
    final daily1 = today['daily1'] as int?;
    final daily2 = today['daily2'] as int?;

    Color scoreColor;
    if (todayScore >= 75) scoreColor = successColor;
    else if (todayScore >= 50) scoreColor = gold;
    else scoreColor = dangerColor;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Score row — visual
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text('$todayScore%', style: GoogleFonts.cormorantGaramond(
            fontSize: 48, color: scoreColor, height: 1, fontWeight: FontWeight.w300)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dayLabel, style: GoogleFonts.dmSans(
              fontSize: 12, fontWeight: FontWeight.w600, color: scoreColor)),
          const SizedBox(height: 3),
          Text(headline, style: GoogleFonts.dmSans(
              fontSize: 11, color: primary, height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
      ]),
      const SizedBox(height: 10),

      // Detail — collapsible
      Text(detail, style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.6),
          maxLines: 3, overflow: TextOverflow.ellipsis),

      if (doList.isNotEmpty) ...[
        const SizedBox(height: 14),
        Divider(color: border, height: 1, thickness: 0.5),
        const SizedBox(height: 10),
        Text('DO TOGETHER', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: successColor)),
        const SizedBox(height: 6),
        ...doList.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(top: 5),
                child: Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: successColor))),
            const SizedBox(width: 8),
            Expanded(child: Text(item, style: GoogleFonts.dmSans(fontSize: 12, color: primary, height: 1.4))),
          ]),
        )),
      ],

      if (watchList.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text('BE CAREFUL TODAY', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: dangerColor)),
        const SizedBox(height: 6),
        ...watchList.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(top: 5),
                child: Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: dangerColor))),
            const SizedBox(width: 8),
            Expanded(child: Text(item, style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.4))),
          ]),
        )),
      ],
    ]);
  }
}

// ─── OVERALL TAB ──────────────────────────────────────────────────────────────
class _OverallTab extends StatelessWidget {
  final Map<String, dynamic> compat; final bool isDark; final Color gold;
  const _OverallTab({required this.compat, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;

    final core = compat['core'] as String? ?? '';
    final strength = compat['strength'] as String? ?? '';
    final tension = compat['tension'] as String? ?? '';
    final growth = compat['growth'] as String? ?? '';
    final romantic = compat['romantic'] as String?;
    final friendship = compat['friendship'] as String?;
    final destinyNote = compat['destiny_note'] as String?;
    final relationLabel = compat['relationship_label'] as String? ?? 'Close connection';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(core, style: GoogleFonts.dmSans(fontSize: 13, color: primary, height: 1.65)),
      const SizedBox(height: 14),
      Divider(color: border, height: 1, thickness: 0.5),
      const SizedBox(height: 12),

      _CompatRow(label: 'What works', text: strength, color: successColor, secondary: secondary, primary: primary),
      const SizedBox(height: 10),
      _CompatRow(label: 'The tension', text: tension, color: dangerColor, secondary: secondary, primary: primary),
      const SizedBox(height: 10),
      _CompatRow(label: 'Growth edge', text: growth, color: gold, secondary: secondary, primary: primary),

      if (romantic != null || friendship != null) ...[
        const SizedBox(height: 12),
        Divider(color: border, height: 1, thickness: 0.5),
        const SizedBox(height: 10),
        if (romantic != null)
          _CompatRow(label: relationLabel, text: romantic, color: Colors.pinkAccent, secondary: secondary, primary: primary),
        if (romantic != null && friendship != null) const SizedBox(height: 10),
        if (friendship != null)
          _CompatRow(label: 'Friendship', text: friendship, color: const Color(0xFF6366F1), secondary: secondary, primary: primary),
      ],

      if (destinyNote != null) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: gold.withOpacity(0.15), width: 0.5),
          ),
          child: Text(destinyNote, style: GoogleFonts.dmSans(fontSize: 11, color: secondary, height: 1.5, fontStyle: FontStyle.italic)),
        ),
      ],
    ]);
  }
}

class _CompatRow extends StatelessWidget {
  final String label, text; final Color color, secondary, primary;
  const _CompatRow({required this.label, required this.text, required this.color, required this.secondary, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: color)),
      const SizedBox(height: 4),
      Text(text, style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
    ]);
  }
}

// ─── DYNAMICS TAB ─────────────────────────────────────────────────────────────
class _DynamicsTab extends StatelessWidget {
  final Map<String, dynamic> compat; final bool isDark; final Color gold;
  const _DynamicsTab({required this.compat, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final p1 = compat['person1_brings'] as Map<String, dynamic>?;
    final p2 = compat['person2_brings'] as Map<String, dynamic>?;

    if (p1 == null || p2 == null) return const SizedBox();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('How you show up for each other', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: primary)),
      const SizedBox(height: 12),

      // Person 1
      _PersonDynamic(person: p1, label: 'You', gold: gold, isDark: isDark),
      const SizedBox(height: 12),
      Divider(color: border, height: 1, thickness: 0.5),
      const SizedBox(height: 12),

      // Person 2
      _PersonDynamic(person: p2, label: 'Them', gold: gold, isDark: isDark),
    ]);
  }
}

class _PersonDynamic extends StatelessWidget {
  final Map<String, dynamic> person; final String label;
  final Color gold; final bool isDark;
  const _PersonDynamic({required this.person, required this.label, required this.gold, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    final successColor = isDark ? AppColors.successDark : AppColors.success;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: gold)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: gold)),
        const SizedBox(width: 6),
        Text('(Basic ${person['basic']}, Destiny ${person['destiny']})',
            style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
      ]),
      const SizedBox(height: 8),
      if (person['brings'] != null)
        _DynRow('Brings', person['brings'] as String, successColor, secondary),
      if (person['needs'] != null)
        _DynRow('Needs', person['needs'] as String, gold, secondary),
      if (person['blind_spot'] != null)
        _DynRow('Blind spot', person['blind_spot'] as String, dangerColor, secondary),
      if (person['conflict_style'] != null)
        _DynRow('In conflict', person['conflict_style'] as String, const Color(0xFF6366F1), secondary),
    ]);
  }
}

class _DynRow extends StatelessWidget {
  final String label, text; final Color labelColor, secondary;
  const _DynRow(this.label, this.text, this.labelColor, this.secondary);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 70, child: Text(label, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: labelColor))),
        Expanded(child: Text(text, style: GoogleFonts.dmSans(fontSize: 11, color: secondary, height: 1.4))),
      ]),
    );
  }
}

// ─── Add friend sheet ─────────────────────────────────────────────────────────
class _AddFriendSheet extends StatefulWidget {
  final bool isDark; final Color gold;
  const _AddFriendSheet({required this.isDark, required this.gold});

  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  final _nameCtrl = TextEditingController();
  DateTime? _dob;
  String _relation = 'Friend';
  bool _saving = false;

  static const _relations = ['Partner', 'Friend', 'Family', 'Colleague', 'Other'];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final gold = widget.gold;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 3, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Text('Add to your circle', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
        const SizedBox(height: 4),
        Text('Partner, friend, family, colleague — anyone', style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
        const SizedBox(height: 20),

        // Name
        TextField(
          controller: _nameCtrl,
          style: GoogleFonts.dmSans(fontSize: 14, color: primary),
          decoration: InputDecoration(
            hintText: 'Their name',
            hintStyle: GoogleFonts.dmSans(color: secondary),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border, width: 0.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: gold, width: 1)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),

        // Relation selector
        Wrap(spacing: 8, children: _relations.map((r) {
          final active = _relation == r;
          return GestureDetector(
            onTap: () => setState(() => _relation = r),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: active ? gold.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? gold.withOpacity(0.4) : border, width: 0.5),
              ),
              child: Text(r, style: GoogleFonts.dmSans(fontSize: 12, color: active ? gold : secondary)),
            ),
          );
        }).toList()),
        const SizedBox(height: 12),

        // DOB picker
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(1995),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: isDark
                      ? ColorScheme.dark(primary: gold, onPrimary: Colors.black, surface: AppColors.bgCardDark)
                      : ColorScheme.light(primary: gold, onPrimary: Colors.black, surface: AppColors.bgCardLight),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => _dob = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _dob != null ? gold.withOpacity(0.4) : border, width: 0.5),
            ),
            child: Row(children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: _dob != null ? gold : secondary),
              const SizedBox(width: 10),
              Text(_dob != null ? _fmt(_dob!) : 'Date of birth',
                  style: GoogleFonts.dmSans(fontSize: 14, color: _dob != null ? primary : secondary)),
            ]),
          ),
        ),
        const SizedBox(height: 20),

        // Save button
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: _saving ? null : _save,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: (_nameCtrl.text.isNotEmpty && _dob != null) ? gold : gold.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text('Add to circle', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black))),
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _dob == null) return;
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection('users').doc(uid).collection('friends')
          .add({'name': _nameCtrl.text.trim(), 'dob': Timestamp.fromDate(_dob!), 'relation': _relation});
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }
}
