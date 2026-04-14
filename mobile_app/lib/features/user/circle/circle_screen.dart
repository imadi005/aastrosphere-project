import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/api_service.dart';

// ─── Friend model ─────────────────────────────────────────────
class Friend {
  final String id, name;
  final DateTime dob;
  Friend({required this.id, required this.name, required this.dob});

  factory Friend.fromMap(String id, Map<String, dynamic> m) => Friend(
    id: id,
    name: m['name'] as String,
    dob: (m['dob'] as Timestamp).toDate(),
  );
}

// ─── Providers ────────────────────────────────────────────────
final friendsProvider = StreamProvider<List<Friend>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('friends')
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
        error: (_, __) => Center(child: Text('Error',
            style: GoogleFonts.dmSans(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))),
        data: (friends) => friends.isEmpty
            ? _EmptyCircle(isDark: isDark, gold: gold, onAdd: () => _showAddFriend(context, isDark, gold))
            : _FriendsList(friends: friends, isDark: isDark, gold: gold),
      ),
    );
  }

  void _showAddFriend(BuildContext context, bool isDark, Color gold) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddFriendSheet(isDark: isDark, gold: gold),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────
class _EmptyCircle extends StatelessWidget {
  final bool isDark;
  final Color gold;
  final VoidCallback onAdd;
  const _EmptyCircle({required this.isDark, required this.gold, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Your Circle', style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold)),
      const SizedBox(height: 8),
      Text('Add people to check compatibility', style: GoogleFonts.dmSans(fontSize: 13, color: secondary)),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: onAdd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
              color: gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: gold.withOpacity(0.3), width: 0.5)),
          child: Text('Add someone', style: GoogleFonts.dmSans(fontSize: 13, color: gold)),
        ),
      ),
    ]));
  }
}

// ─── Friends list ─────────────────────────────────────────────
class _FriendsList extends StatelessWidget {
  final List<Friend> friends;
  final bool isDark;
  final Color gold;
  const _FriendsList({required this.friends, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Text('Your Circle', style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold)),
        Text('${friends.length} ${friends.length == 1 ? 'person' : 'people'} in your circle',
            style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
        const SizedBox(height: 16),
        ...friends.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _FriendCard(friend: f, isDark: isDark, gold: gold),
        )),
      ],
    );
  }
}

class _FriendCard extends StatefulWidget {
  final Friend friend;
  final bool isDark;
  final Color gold;
  const _FriendCard({required this.friend, required this.isDark, required this.gold});

  @override
  State<_FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends State<_FriendCard> {
  Map<String, dynamic>? _compat;
  bool _loading = false;

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

    Color scoreColor = gold;
    if (score != null) {
      if (score >= 70) scoreColor = isDark ? AppColors.successDark : AppColors.success;
      else if (score < 40) scoreColor = isDark ? AppColors.dangerDark : AppColors.danger;
    }

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Center(child: Text(
                  widget.friend.name[0].toUpperCase(),
                  style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.friend.name,
                    style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: primary)),
                Text(_dobStr(widget.friend.dob),
                    style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
              ],
            )),
            if (_loading) SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: gold),
            ) else if (score != null) Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$score%', style: GoogleFonts.cormorantGaramond(
                    fontSize: 22, color: scoreColor)),
                if (level != null)
                  Text(level, style: GoogleFonts.dmSans(fontSize: 9, color: secondary)),
              ],
            ),
          ]),
          if (_compat != null) ...[
            const SizedBox(height: 12),
            Divider(color: border, thickness: 0.5, height: 1),
            const SizedBox(height: 12),
            Text(_compat!['summary'] as String? ?? '',
                style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
          ],
          // Delete
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) return;
                await FirebaseFirestore.instance
                    .collection('users').doc(uid)
                    .collection('friends').doc(widget.friend.id)
                    .delete();
              },
              child: Text('Remove', style: GoogleFonts.dmSans(
                  fontSize: 11, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)),
            ),
          ),
        ],
      ),
    );
  }

  String _dobStr(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month-1]} ${d.year}';
  }
}

// ─── Add friend sheet ─────────────────────────────────────────
class _AddFriendSheet extends StatefulWidget {
  final bool isDark;
  final Color gold;
  const _AddFriendSheet({required this.isDark, required this.gold});

  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  final _name = TextEditingController();
  DateTime? _dob;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final gold = widget.gold;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 36, height: 3,
              decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Add to Circle', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            style: GoogleFonts.dmSans(fontSize: 14, color: primary),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: GoogleFonts.dmSans(fontSize: 12, color: secondary),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: border, width: 0.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: gold, width: 1)),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(1995),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _dob = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border, width: 0.5)),
              child: Row(children: [
                Expanded(child: Text(
                  _dob == null ? 'Date of Birth' : _fmt(_dob!),
                  style: GoogleFonts.dmSans(fontSize: 14,
                      color: _dob == null ? secondary : primary),
                )),
                Icon(Icons.calendar_today_outlined, size: 16, color: secondary),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _saving ? null : _save,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                    color: gold, borderRadius: BorderRadius.circular(12)),
                child: Center(child: _saving
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.black))
                    : Text('Add to Circle',
                        style: GoogleFonts.dmSans(fontSize: 14,
                            fontWeight: FontWeight.w500, color: Colors.black))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_name.text.isEmpty || _dob == null) return;
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('friends')
          .add({
        'name': _name.text.trim(),
        'dob': Timestamp.fromDate(_dob!),
        'addedAt': FieldValue.serverTimestamp(),
      });
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
