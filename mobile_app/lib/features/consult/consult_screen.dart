import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/shared_widgets.dart';

// ─── Entry point card (shown in Me screen) ────────────────────────────────────
class AskAstrologerCard extends StatelessWidget {
  final bool isDark;
  final Color gold;
  const AskAstrologerCard({required this.isDark, required this.gold, super.key});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ConsultScreen())),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gold.withOpacity(0.12), gold.withOpacity(0.04)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withOpacity(0.25), width: 0.5),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_awesome, size: 20, color: gold),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ask the Astrologer',
                style: GoogleFonts.cormorantGaramond(
                    fontSize: 17, fontWeight: FontWeight.w600, color: primary)),
            const SizedBox(height: 3),
            Text('5 questions · ₹200 · answered in 24 hours',
                style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
            const SizedBox(height: 1),
            Text('by Pankajj Kumar Mishra',
                style: GoogleFonts.dmSans(
                    fontSize: 10, color: gold.withOpacity(0.8),
                    fontStyle: FontStyle.italic)),
          ])),
          Icon(Icons.chevron_right, size: 18, color: gold.withOpacity(0.6)),
        ]),
      ),
    );
  }
}

// ─── Main Consult Screen ──────────────────────────────────────────────────────
class ConsultScreen extends StatelessWidget {
  const ConsultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;

    // Check if user already has pending/answered sessions
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 16,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Ask the Astrologer',
            style: GoogleFonts.cormorantGaramond(
                fontSize: 20, color: gold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('consultations')
            .where('uid', isEqualTo: uid)
            .orderBy('created_at', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          final hasPending = docs.any((d) =>
              (d.data() as Map)['status'] == 'pending' ||
              (d.data() as Map)['status'] == 'answered');

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Header info card ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: gold.withOpacity(0.15), width: 0.5),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.auto_awesome, size: 13, color: gold),
                    const SizedBox(width: 8),
                    Text('PERSONAL CONSULTATION',
                        style: GoogleFonts.dmSans(fontSize: 9,
                            fontWeight: FontWeight.w700, letterSpacing: 1, color: gold)),
                  ]),
                  const SizedBox(height: 10),
                  _InfoRow(icon: Icons.help_outline, text: '5 questions per session',
                      isDark: isDark),
                  _InfoRow(icon: Icons.currency_rupee, text: '₹200 per session',
                      isDark: isDark),
                  _InfoRow(icon: Icons.schedule_outlined, text: 'Answers within 24 hours',
                      isDark: isDark),
                  _InfoRow(icon: Icons.person_outline, text: 'by Pankajj Kumar Mishra',
                      isDark: isDark),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Past sessions ─────────────────────────────────────────────
              if (docs.isNotEmpty) ...[
                Text('YOUR SESSIONS',
                    style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                const SizedBox(height: 10),
                ...docs.map((doc) => _SessionCard(doc: doc, isDark: isDark, gold: gold)),
                const SizedBox(height: 20),
              ],

              // ── New session button ────────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _QuestionsScreen())),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text('Ask 5 Questions — ₹200',
                      style: GoogleFonts.dmSans(fontSize: 15,
                          fontWeight: FontWeight.w600, color: Colors.black))),
                ),
              ),
              const SizedBox(height: 24),

              // ── Support ───────────────────────────────────────────────────
              _SupportSection(isDark: isDark, gold: gold),
            ]),
          );
        },
      ),
    );
  }
}

// ─── Session card ─────────────────────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final DocumentSnapshot doc;
  final bool isDark;
  final Color gold;
  const _SessionCard({required this.doc, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'pending';
    final ts = data['created_at'] as Timestamp?;
    final date = ts != null ? _fmt(ts.toDate()) : '';
    final isAnswered = status == 'answered';
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final statusColor = isAnswered
        ? (isDark ? AppColors.successDark : AppColors.success)
        : gold;

    return GestureDetector(
      onTap: isAnswered
          ? () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => _AnswerScreen(doc: doc, isDark: isDark, gold: gold)))
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(date, style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
            const SizedBox(height: 3),
            Text(isAnswered ? 'Answers have arrived — tap to read'
                : 'Awaiting answer from Pankajj Kumar Mishra',
                style: GoogleFonts.dmSans(fontSize: 12, color: primary)),
          ])),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(isAnswered ? 'Answered' : 'Pending',
                style: GoogleFonts.dmSans(fontSize: 10,
                    fontWeight: FontWeight.w600, color: statusColor)),
          ),
          if (isAnswered) ...[
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 16, color: secondary),
          ],
        ]),
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }
}

// ─── Questions Screen ─────────────────────────────────────────────────────────
class _QuestionsScreen extends StatefulWidget {
  const _QuestionsScreen();
  @override
  State<_QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<_QuestionsScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(5, (_) => TextEditingController());

  bool get _allFilled => _ctrls.every((c) => c.text.trim().isNotEmpty);

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 16, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Your Questions',
            style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Write your 5 questions clearly.',
              style: GoogleFonts.dmSans(fontSize: 13, color: primary)),
          const SizedBox(height: 4),
          Text('Be specific — the more detail, the better the answer.',
              style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
          const SizedBox(height: 20),

          ...List.generate(5, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Question ${i + 1}',
                  style: GoogleFonts.dmSans(fontSize: 10,
                      fontWeight: FontWeight.w700, letterSpacing: 0.8, color: gold)),
              const SizedBox(height: 6),
              TextField(
                controller: _ctrls[i],
                maxLines: 3,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.dmSans(fontSize: 13, color: primary),
                decoration: InputDecoration(
                  hintText: 'Type your question here...',
                  hintStyle: GoogleFonts.dmSans(fontSize: 12, color: secondary.withOpacity(0.5)),
                  filled: true,
                  fillColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: border, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: gold, width: 1),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ]),
          )),

          const SizedBox(height: 8),
          GestureDetector(
            onTap: _allFilled
                ? () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _PaymentScreen(
                        questions: _ctrls.map((c) => c.text.trim()).toList())))
                : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _allFilled ? gold : gold.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text('Continue to Payment',
                  style: GoogleFonts.dmSans(fontSize: 15,
                      fontWeight: FontWeight.w600, color: Colors.black))),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Payment Screen ───────────────────────────────────────────────────────────
class _PaymentScreen extends StatefulWidget {
  final List<String> questions;
  const _PaymentScreen({required this.questions});
  @override
  State<_PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<_PaymentScreen> {
  final _utrCtrl = TextEditingController();
  bool _saving = false;
  bool _done = false;

  @override
  void dispose() { _utrCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_utrCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final name = userDoc.data()?['name'] as String? ?? 'User';
      final dob = userDoc.data()?['dob'];

      await FirebaseFirestore.instance.collection('consultations').add({
        'uid': uid,
        'name': name,
        'dob': dob,
        'questions': widget.questions,
        'utr': _utrCtrl.text.trim(),
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'answers': null,
        'answered_at': null,
      });

      if (mounted) setState(() { _saving = false; _done = true; });
    } catch (e) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    if (_done) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        body: Center(child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.check_circle_outline, size: 56, color: gold),
            const SizedBox(height: 20),
            Text('Questions Submitted',
                style: GoogleFonts.cormorantGaramond(fontSize: 24, color: gold)),
            const SizedBox(height: 12),
            Text('Pankajj Kumar Mishra will answer your questions within 24 hours. You will receive a notification when the answers are ready.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 13, color: secondary, height: 1.6)),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: gold, borderRadius: BorderRadius.circular(12)),
                child: Text('Back to Home',
                    style: GoogleFonts.dmSans(
                        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
              ),
            ),
          ]),
        )),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 16, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Payment',
            style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Amount chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: gold.withOpacity(0.3), width: 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.currency_rupee, size: 14, color: gold),
              Text('200', style: GoogleFonts.cormorantGaramond(
                  fontSize: 24, color: gold, height: 1)),
              const SizedBox(width: 8),
              Text('for 5 questions', style: GoogleFonts.dmSans(
                  fontSize: 12, color: secondary)),
            ]),
          ),
          const SizedBox(height: 20),

          // QR Code
          Center(
            child: Column(children: [
              Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: gold.withOpacity(0.3), width: 1),
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/upi_qr.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2, size: 70, color: Colors.black87),
                      const SizedBox(height: 6),
                      Text('UPI QR Code',
                          style: GoogleFonts.dmSans(fontSize: 11,
                              color: Colors.black54, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text('Scan & pay ₹200 via any UPI app',
                  style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
            ]),
          ),
          const SizedBox(height: 24),

          // UTR input
          Text('PAYMENT REFERENCE (UTR)',
              style: GoogleFonts.dmSans(fontSize: 9,
                  fontWeight: FontWeight.w700, letterSpacing: 1, color: gold)),
          const SizedBox(height: 8),
          TextField(
            controller: _utrCtrl,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.dmSans(fontSize: 13, color: primary),
            decoration: InputDecoration(
              hintText: 'Enter UTR / transaction reference number',
              hintStyle: GoogleFonts.dmSans(fontSize: 12,
                  color: secondary.withOpacity(0.5)),
              filled: true,
              fillColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: border, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: gold, width: 1),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 6),
          Text('After paying, enter the UTR/reference number from your payment app.',
              style: GoogleFonts.dmSans(fontSize: 11,
                  color: secondary.withOpacity(0.6), height: 1.4)),
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.lock_outline, size: 13,
                color: (isDark ? AppColors.successDark : AppColors.success).withOpacity(0.8)),
            const SizedBox(width: 7),
            Expanded(child: Text(
              'Your questions are 100% confidential — seen only by Pankajj Kumar Mishra.',
              style: GoogleFonts.dmSans(fontSize: 11,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  height: 1.5),
            )),
          ]),
          const SizedBox(height: 24),

          // Submit
          GestureDetector(
            onTap: _utrCtrl.text.trim().isNotEmpty && !_saving ? _submit : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _utrCtrl.text.trim().isNotEmpty ? gold : gold.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: _saving
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text('Submit Questions',
                      style: GoogleFonts.dmSans(fontSize: 15,
                          fontWeight: FontWeight.w600, color: Colors.black))),
            ),
          ),
          const SizedBox(height: 24),

          // Support
          _SupportSection(isDark: isDark, gold: gold),
        ]),
      ),
    );
  }
}

// ─── Answer Screen ────────────────────────────────────────────────────────────
class _AnswerScreen extends StatelessWidget {
  final DocumentSnapshot doc;
  final bool isDark;
  final Color gold;
  const _AnswerScreen({required this.doc, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final questions = (data['questions'] as List? ?? []).cast<String>();
    final answers = (data['answers'] as List? ?? []).cast<String>();
    final ts = data['answered_at'] as Timestamp?;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 16, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Your Answers',
            style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: successColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: successColor.withOpacity(0.2), width: 0.5),
            ),
            child: Row(children: [
              Icon(Icons.check_circle_outline, size: 16, color: successColor),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Answered by Pankajj Kumar Mishra',
                    style: GoogleFonts.dmSans(fontSize: 12,
                        fontWeight: FontWeight.w500, color: primary)),
                if (ts != null)
                  Text(_fmt(ts.toDate()),
                      style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),

          // Q&A pairs
          ...List.generate(questions.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Question
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(child: Text('${i+1}',
                      style: GoogleFonts.dmSans(fontSize: 10,
                          fontWeight: FontWeight.w700, color: gold))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(questions[i],
                    style: GoogleFonts.dmSans(fontSize: 13,
                        fontWeight: FontWeight.w500, color: primary, height: 1.5))),
              ]),
              const SizedBox(height: 10),
              // Answer
              if (i < answers.length && answers[i].isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: border, width: 0.5),
                  ),
                  child: Text(answers[i],
                      style: GoogleFonts.dmSans(fontSize: 13,
                          color: secondary, height: 1.65)),
                )
              else
                Text('Answer pending...',
                    style: GoogleFonts.dmSans(fontSize: 12,
                        color: secondary.withOpacity(0.4),
                        fontStyle: FontStyle.italic)),
            ]),
          )),

          const SizedBox(height: 12),
          _SupportSection(isDark: isDark, gold: gold),
        ]),
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }
}

// ─── Astrologer side — Pending Questions Dashboard ────────────────────────────
class AstrologerConsultScreen extends StatelessWidget {
  const AstrologerConsultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Consultations',
            style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('consultations')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          final pending = docs.where((d) =>
              (d.data() as Map)['status'] == 'pending').toList();
          final answered = docs.where((d) =>
              (d.data() as Map)['status'] == 'answered').toList();

          return DefaultTabController(
            length: 2,
            child: Column(children: [
              TabBar(
                labelColor: gold,
                unselectedLabelColor: secondary,
                indicatorColor: gold,
                labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: 'Pending (${pending.length})'),
                  Tab(text: 'Answered (${answered.length})'),
                ],
              ),
              Expanded(child: TabBarView(children: [
                _ConsultList(docs: pending, isDark: isDark, gold: gold),
                _ConsultList(docs: answered, isDark: isDark, gold: gold),
              ])),
            ]),
          );
        },
      ),
    );
  }
}

class _ConsultList extends StatelessWidget {
  final List<DocumentSnapshot> docs;
  final bool isDark;
  final Color gold;
  const _ConsultList({required this.docs, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return Center(child: Text('Nothing here',
          style: GoogleFonts.dmSans(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _ConsultTile(doc: docs[i], isDark: isDark, gold: gold),
    );
  }
}

class _ConsultTile extends StatelessWidget {
  final DocumentSnapshot doc;
  final bool isDark;
  final Color gold;
  const _ConsultTile({required this.doc, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] as String? ?? 'User';
    final utr = data['utr'] as String? ?? '';
    final ts = data['created_at'] as Timestamp?;
    final date = ts != null ? _fmt(ts.toDate()) : '';
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _AnswerInputScreen(doc: doc, isDark: isDark, gold: gold))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Center(child: Text(name[0].toUpperCase(),
                style: GoogleFonts.cormorantGaramond(fontSize: 18, color: gold))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w500, color: primary)),
            Text('$date  ·  UTR: $utr',
                style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
          ])),
          Icon(Icons.chevron_right, size: 16, color: secondary),
        ]),
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }
}

// ─── Answer Input Screen (Astrologer) ────────────────────────────────────────
class _AnswerInputScreen extends StatefulWidget {
  final DocumentSnapshot doc;
  final bool isDark;
  final Color gold;
  const _AnswerInputScreen({required this.doc, required this.isDark, required this.gold});
  @override
  State<_AnswerInputScreen> createState() => _AnswerInputScreenState();
}

class _AnswerInputScreenState extends State<_AnswerInputScreen> {
  late List<TextEditingController> _ctrls;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.doc.data() as Map<String, dynamic>;
    final existing = (data['answers'] as List? ?? []).cast<String>();
    _ctrls = List.generate(5, (i) =>
        TextEditingController(text: i < existing.length ? existing[i] : ''));
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.doc.reference.update({
        'answers': _ctrls.map((c) => c.text.trim()).toList(),
        'status': 'answered',
        'answered_at': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final gold = widget.gold;
    final data = widget.doc.data() as Map<String, dynamic>;
    final questions = (data['questions'] as List? ?? []).cast<String>();
    final name = data['name'] as String? ?? 'User';
    final utr = data['utr'] as String? ?? '';
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 16, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(name,
            style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('UTR: $utr',
                style: GoogleFonts.dmSans(fontSize: 10, color: secondary))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(children: [
          ...List.generate(questions.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Question
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Q${i+1}  ', style: GoogleFonts.dmSans(
                      fontSize: 11, fontWeight: FontWeight.w700, color: gold)),
                  Expanded(child: Text(questions[i],
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: primary, height: 1.5))),
                ]),
              ),
              const SizedBox(height: 8),
              // Answer input
              TextField(
                controller: _ctrls[i],
                maxLines: 4,
                style: GoogleFonts.dmSans(fontSize: 13, color: primary),
                decoration: InputDecoration(
                  hintText: 'Type answer...',
                  hintStyle: GoogleFonts.dmSans(fontSize: 12,
                      color: secondary.withOpacity(0.4)),
                  filled: true,
                  fillColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: border, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: gold, width: 1),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ]),
          )),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: !_saving ? _save : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: gold, borderRadius: BorderRadius.circular(14)),
              child: Center(child: _saving
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text('Submit Answers',
                      style: GoogleFonts.dmSans(fontSize: 15,
                          fontWeight: FontWeight.w600, color: Colors.black))),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Support Section ──────────────────────────────────────────────────────────
class _SupportSection extends StatelessWidget {
  final bool isDark;
  final Color gold;
  const _SupportSection({required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NEED HELP?',
            style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700,
                letterSpacing: 1, color: secondary)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            const phone = '919771497955';
            const msg = 'Hey, I have a query about Aastrosphere';
            final url = 'https://wa.me/$phone?text=${Uri.encodeComponent(msg)}';
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            }
          },
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chat_outlined, size: 16, color: Color(0xFF25D366)),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('WhatsApp Support',
                  style: GoogleFonts.dmSans(fontSize: 12,
                      fontWeight: FontWeight.w500, color:
                      isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              Text('+91 97714 97955',
                  style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _InfoRow({required this.icon, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(children: [
        Icon(icon, size: 14, color: secondary.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
      ]),
    );
  }
}
