import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';

class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;
  
  ChatMessage({required this.role, required this.content, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

class AskScreen extends StatefulWidget {
  const AskScreen({super.key});
  
  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  bool _loading = false;
  bool _historyLoading = true;
  String? _userDob;
  String? _uid;
  bool _isTyping = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserDob();
    _addWelcomeMessage();
    
    _fadeController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 600)
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
    
    _ctrl.addListener(_onTyping);
    // _historyLoading will be set false in _loadHistory
  }
  
  void _onTyping() {
    if (_ctrl.text.isNotEmpty && !_isTyping) {
      setState(() => _isTyping = true);
    } else if (_ctrl.text.isEmpty && _isTyping) {
      setState(() => _isTyping = false);
    }
  }
  
  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      role: 'assistant',
      content: '''
✨ **Namaskar** ✨

I'm your personal astro guide. Ask me anything about:

• **Astrology** - Planets, zodiac, nakshatra
• **Career** - Job switch, promotion, business
• **Relationships** - Love, marriage, family vibes
• **Finance** - Money, investments, wealth
• **Health** - Wellness, remedies, lifestyle

**What's on your mind?** 🙏
''',
    ));
  }

  Future<void> _loadUserDob() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _uid = uid;
    
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final dob = (doc.data()?['dob'] as Timestamp?)?.toDate();
      if (dob != null && mounted) {
        setState(() => _userDob = dob.toIso8601String());
      }
      // Load chat history
      await _loadHistory(uid);
    } catch (e) {
      debugPrint('Error loading: \$e');
      if (mounted) setState(() => _historyLoading = false);
    }
  }

  Future<void> _loadHistory(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('chat_history').doc('messages').get();
      
      if (doc.exists && doc.data() != null) {
        final history = (doc.data()!['messages'] as List? ?? []);
        final loaded = history.map((m) => ChatMessage(
          role: m['role'] as String,
          content: m['content'] as String,
        )).toList();
        
        if (mounted && loaded.isNotEmpty) {
          setState(() {
            // Keep welcome message at top, append history
            _messages.addAll(loaded);
            _historyLoading = false;
          });
          // Scroll to bottom after loading
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          return;
        }
      }
    } catch (e) {
      debugPrint('History load error: \$e');
    }
    if (mounted) setState(() => _historyLoading = false);
  }

  Future<void> _saveHistory() async {
    if (_uid == null) return;
    try {
      // Save last 50 messages (skip welcome message)
      final toSave = _messages
          .skip(1)
          .take(50)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();
      
      await FirebaseFirestore.instance
          .collection('users').doc(_uid!)
          .collection('chat_history').doc('messages')
          .set({'messages': toSave, 'updated_at': FieldValue.serverTimestamp()});
    } catch (e) {
      debugPrint('History save error: \$e');
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading || _userDob == null) return;
    
    HapticFeedback.lightImpact();
    
    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _loading = true;
      _isTyping = false;
    });
    
    _ctrl.clear();
    _scrollToBottom();
    _focusNode.unfocus();

    try {
      // Send last 20 messages for context (memory window)
      final allHistory = _messages.skip(1).toList();
      final recentMessages = allHistory.length > 20 
          ? allHistory.sublist(allHistory.length - 20)
          : allHistory;
      final apiMessages = recentMessages
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final result = await ApiService.ask(
        dob: _userDob!,
        messages: apiMessages,
        clientDate: ApiService.clientDate,
      );
      
      final answer = result['answer'] as String? ?? '⚠️ Oops! Something went wrong. Try again?';
      
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(role: 'assistant', content: answer));
          _loading = false;
        });
        _scrollToBottom();
        _saveHistory(); // persist to Firestore
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            role: 'assistant', 
            content: '🔌 **No internet connection**\n\nCheck your network and try again. 🙏'
          ));
          _loading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scroll.hasClients && _scroll.position.maxScrollExtent > 0) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }
  
  void _clearChat() {
    HapticFeedback.selectionClick();
    setState(() {
      _messages.clear();
      _addWelcomeMessage();
    });
    // Clear from Firestore too
    if (_uid != null) {
      FirebaseFirestore.instance
          .collection('users').doc(_uid!)
          .collection('chat_history').doc('messages')
          .delete().catchError((_) {});
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTyping);
    _ctrl.dispose();
    _scroll.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: _buildAppBar(gold, secondary, isDark),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Expanded(
                child: _historyLoading || (_messages.isEmpty && !_loading)
                    ? _buildEmptyState(gold, secondary)
                    : _buildChatList(isDark, gold, border),
              ),
              _buildInputArea(isDark, gold, secondary, border),
            ],
          ),
        ),
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar(Color gold, Color secondary, bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Ask ', style: GoogleFonts.cormorantGaramond(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: gold,
                letterSpacing: -0.5,
              )),
              Text('Anything', style: GoogleFonts.cormorantGaramond(
                fontSize: 24, 
                fontWeight: FontWeight.w600, 
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: -0.5,
              )),
            ],
          ),
          Text('by Pankajj Kumar Mishra', 
            style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
        ],
      ),
      actions: [
        if (_messages.isNotEmpty)
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 20, color: secondary),
            onPressed: _clearChat,
            tooltip: 'Clear chat',
            splashRadius: 24,
          ),
      ],
    );
  }
  
  Widget _buildEmptyState(Color gold, Color secondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gold.withOpacity(0.2), gold.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 36, color: gold),
          ),
          const SizedBox(height: 24),
          Text(
            'Ask your question for\nastrological guidance',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: secondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology_alt_rounded, size: 16, color: gold),
                const SizedBox(width: 8),
                Text(
                  'Career · Love · Money · Health',
                  style: GoogleFonts.dmSans(fontSize: 12, color: gold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatList(bool isDark, Color gold, Color border) {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _messages.length + (_loading ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == _messages.length) {
          return _TypingBubble(gold: gold, isDark: isDark);
        }
        
        final message = _messages[i];
        final isUser = message.role == 'user';
        
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMessageBubble(message, isUser, isDark, gold, border),
          ),
        );
      },
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message, bool isUser, bool isDark, Color gold, Color border) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.85,
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser 
                    ? LinearGradient(
                        colors: [gold.withOpacity(0.12), gold.withOpacity(0.08)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUser ? null : (isDark ? AppColors.bgCardDark : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: Border.all(
                  color: isUser ? gold.withOpacity(0.3) : border,
                  width: 0.5,
                ),
              ),
              child: MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.dmSans(
                    fontSize: 14,
                    height: 1.6,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  h1: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: gold,
                  ),
                  h2: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  strong: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUser ? null : gold,
                  ),
                  listBullet: TextStyle(
                    color: gold,
                    fontSize: 14,
                  ),
                  blockquote: TextStyle(
                    color: secondaryTextColor(isDark),
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: gold.withOpacity(0.5),
                        width: 3,
                      ),
                    ),
                  ),
                  code: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _formatTime(message.timestamp),
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: secondaryTextColor(isDark).withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputArea(bool isDark, Color gold, Color secondary, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : Colors.white,
        border: Border(top: BorderSide(color: border, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgCardDark : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: border, width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focusNode,
                      maxLines: 5,
                      minLines: 1,
                      style: GoogleFonts.dmSans(fontSize: 15, height: 1.2),
                      decoration: InputDecoration(
                        hintText: _isTyping ? 'Typing...' : 'Ask your question...',
                        hintStyle: TextStyle(
                          color: secondary.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  if (_ctrl.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, size: 18, color: secondary),
                      onPressed: () => _ctrl.clear(),
                      splashRadius: 20,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: _send,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _loading 
                        ? [gold.withOpacity(0.5), gold.withOpacity(0.3)]
                        : [gold, gold.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.black87, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
  
  Color secondaryTextColor(bool isDark) {
    return isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  }
}

// Enhanced Typing Bubble
class _TypingBubble extends StatefulWidget {
  final Color gold;
  final bool isDark;
  
  const _TypingBubble({required this.gold, required this.isDark});
  
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    
    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            1.0,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final border = widget.isDark ? AppColors.borderDark : AppColors.borderLight;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.gold.withOpacity(0.15), widget.gold.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('✨', style: TextStyle(fontSize: 14, color: widget.gold)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.bgCardDark : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: border, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _animations[index],
                  builder: (context, child) {
                    return Container(
                      margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.gold.withOpacity(_animations[index].value),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}