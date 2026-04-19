import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';

class ChatMessage {
  final String role;
  final String content;
  ChatMessage({required this.role, required this.content});
}

class AskScreen extends StatefulWidget {
  const AskScreen({super.key});
  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _loading = false;
  String? _userDob;

  @override
  void initState() {
    super.initState();
    _loadUserDob();
    _messages.add(ChatMessage(
      role: 'assistant',
      content: 'Namaskar 🙏\nKoi bhi sawaal poochh sakte hain — ank jyotish, future, relationships, finance — kisi bhi bhasha mein.',
    ));
  }

  Future<void> _loadUserDob() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final dob = (doc.data()?['dob'] as Timestamp?)?.toDate();
    if (dob != null && mounted) setState(() => _userDob = dob.toIso8601String());
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading || _userDob == null) return;
    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _loading = true;
    });
    _ctrl.clear();
    _scrollToBottom();

    try {
      // Skip welcome message in API call
      final apiMessages = _messages
          .skip(1)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final result = await ApiService.ask(
        dob: _userDob!,
        messages: apiMessages,
        clientDate: ApiService.clientDate,
      );
      final answer = result['answer'] as String? ?? 'Kuch issue aa gaya, dobara try karein.';
      if (mounted) setState(() {
        _messages.add(ChatMessage(role: 'assistant', content: answer));
        _loading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (mounted) setState(() {
        _messages.add(ChatMessage(role: 'assistant', content: 'Abhi connect nahi ho paya. Thodi der mein try karein.'));
        _loading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 16,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Ask Anything', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
          Text('by Pankajj Kumar Mishra',
              style: GoogleFonts.dmSans(fontSize: 10, color: secondary, fontStyle: FontStyle.italic)),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _messages.length) return _TypingBubble(gold: gold, isDark: isDark);
              final m = _messages[i];
              final isUser = m.role == 'user';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser) ...[
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(color: gold.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                        child: Center(child: Text('✦', style: TextStyle(fontSize: 11, color: gold))),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isUser ? gold.withOpacity(0.12) : isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                          border: isUser ? null : Border.all(color: border, width: 0.5),
                        ),
                        child: Text(m.content,
                            style: GoogleFonts.dmSans(fontSize: 13,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                height: 1.6)),
                      ),
                    ),
                    if (isUser) const SizedBox(width: 8),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
            border: Border(top: BorderSide(color: border, width: 0.5)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLines: 4, minLines: 1,
                style: GoogleFonts.dmSans(fontSize: 14,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                decoration: InputDecoration(
                  hintText: 'Koi bhi sawaal poochhein...',
                  hintStyle: GoogleFonts.dmSans(fontSize: 13, color: secondary.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _send,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _loading ? gold.withOpacity(0.3) : gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_upward_rounded, size: 18, color: Colors.black),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  final Color gold;
  final bool isDark;
  const _TypingBubble({required this.gold, required this.isDark});
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.2, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final border = widget.isDark ? AppColors.borderDark : AppColors.borderLight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: widget.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text('✦', style: TextStyle(fontSize: 11, color: widget.gold))),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4), bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: border, width: 0.5),
          ),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: [
              ...List.generate(3, (i) => Padding(
                padding: EdgeInsets.only(right: i < 2 ? 4.0 : 0),
                child: Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.gold.withOpacity((_anim.value - i * 0.2).clamp(0.15, 1.0)),
                  ),
                ),
              )),
            ]),
          ),
        ),
      ]),
    );
  }
}
