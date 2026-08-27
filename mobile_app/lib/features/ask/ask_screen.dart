import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/analytics_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/plans_screen.dart';
import '../../core/services/api_service.dart';
import '../../l10n/generated/app_localizations.dart';

class ChatMessage {
  final String id;
  final String role;
  /// What's shown in the bubble — always the user's own typed text, never
  /// includes the quoted-reply context (that's rendered separately via
  /// [replySnippet] so the UI stays clean, WhatsApp-style).
  final String content;
  /// What's actually sent to the API for this turn. Equal to [content]
  /// unless this message is a reply, in which case it also carries the
  /// quoted excerpt — so the model has that context even if the original
  /// message later falls outside the server's memory window.
  final String apiContent;
  final String? replySnippet;
  final bool? replyIsUser;
  final DateTime timestamp;

  ChatMessage({
    String? id,
    required this.role,
    required this.content,
    String? apiContent,
    this.replySnippet,
    this.replyIsUser,
    DateTime? timestamp,
  })  : id = id ?? '${DateTime.now().microsecondsSinceEpoch}',
        apiContent = apiContent ?? content,
        timestamp = timestamp ?? DateTime.now();
}

class AskScreen extends StatefulWidget {
  /// When set, this question is auto-filled and sent as soon as the chat is
  /// ready (used by the Chart screen's "Ask for my personalized insight"
  /// tap-to-explain flow) — the user never has to type it themselves.
  final String? initialQuestion;

  const AskScreen({super.key, this.initialQuestion});

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
  bool _welcomeMessageAdded = false;
  bool _initialQuestionSent = false;
  ChatMessage? _replyTarget;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserDob().then((_) => _maybeSendInitialQuestion());

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600)
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    _ctrl.addListener(_onTyping);
    // _historyLoading will be set false in _loadHistory
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // AppLocalizations isn't available yet during initState — this is the
    // first safe point where the InheritedWidget dependency is attached.
    if (!_welcomeMessageAdded) {
      _welcomeMessageAdded = true;
      _addWelcomeMessage(context);
    }
  }

  void _onTyping() {
    if (_ctrl.text.isNotEmpty && !_isTyping) {
      setState(() => _isTyping = true);
    } else if (_ctrl.text.isEmpty && _isTyping) {
      setState(() => _isTyping = false);
    }
  }
  
  void _maybeSendInitialQuestion() {
    if (_initialQuestionSent) return;
    final q = widget.initialQuestion;
    if (q == null || q.isEmpty || _userDob == null) return;
    _initialQuestionSent = true;
    _ctrl.text = q;
    // Let the welcome message + history finish rendering first so the
    // question lands as a natural next bubble, not a jarring first-frame jump.
    WidgetsBinding.instance.addPostFrameCallback((_) => _send());
  }

  void _addWelcomeMessage(BuildContext context) {
    _messages.add(ChatMessage(
      role: 'assistant',
      content: AppLocalizations.of(context)!.askWelcomeMessage,
    ));
  }

  Future<void> _loadUserDob() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _uid = uid;
    
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      var dob = (doc.data()?['dob'] as Timestamp?)?.toDate();
      // Astrologers using their own "Me" chat may not have a `users` doc —
      // same users-then-astrologers fallback as astrologerProfileProvider,
      // so Ask never silently fails to load a dob for them.
      if (dob == null) {
        final astroDoc = await FirebaseFirestore.instance.collection('astrologers').doc(uid).get();
        dob = (astroDoc.data()?['dob'] as Timestamp?)?.toDate();
      }
      if (dob != null && mounted) {
        setState(() => _userDob = dob!.toIso8601String());
      }
      // Load chat history
      await _loadHistory(uid);
    } catch (e) {
      debugPrint('Error loading: $e');
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
        final loaded = history.map((m) {
          final ts = m['ts'] as int?;
          return ChatMessage(
            role: m['role'] as String,
            content: m['content'] as String,
            apiContent: m['apiContent'] as String?,
            replySnippet: m['replySnippet'] as String?,
            replyIsUser: m['replyIsUser'] as bool?,
            timestamp: ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null,
          );
        }).toList();
        
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
      debugPrint('History load error: $e');
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
          .map((m) => {
                'role': m.role,
                'content': m.content,
                'apiContent': m.apiContent,
                if (m.replySnippet != null) 'replySnippet': m.replySnippet,
                if (m.replyIsUser != null) 'replyIsUser': m.replyIsUser,
                'ts': m.timestamp.millisecondsSinceEpoch,
              })
          .toList();
      
      await FirebaseFirestore.instance
          .collection('users').doc(_uid!)
          .collection('chat_history').doc('messages')
          .set({'messages': toSave, 'updated_at': FieldValue.serverTimestamp()});
    } catch (e) {
      debugPrint('History save error: $e');
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading || _userDob == null) return;

    if (!kIsWeb) HapticFeedback.lightImpact();

    final replyTarget = _replyTarget;
    final replySnippet = replyTarget != null ? _truncateForQuote(replyTarget.content) : null;
    // The quote gets baked into apiContent (what the model sees) but never
    // into content (what's shown in the bubble) — so even if the original
    // message this replies to later scrolls out of the server's memory
    // window, this turn still carries that context explicitly.
    final apiContent = replyTarget != null
        ? '[Replying to ${replyTarget.role == 'user' ? "the user's earlier message" : "your earlier answer"}: "$replySnippet"]\n\n$text'
        : text;

    setState(() {
      _messages.add(ChatMessage(
        role: 'user',
        content: text,
        apiContent: apiContent,
        replySnippet: replySnippet,
        replyIsUser: replyTarget?.role == 'user',
      ));
      _replyTarget = null;
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
          .map((m) => {'role': m.role, 'content': m.apiContent, 'ts': m.timestamp.millisecondsSinceEpoch})
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
    } on OutOfCreditsException catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            role: 'assistant',
            content: '✨ **${e.message}**',
          ));
          _loading = false;
        });
        // Push the full plans screen right at the moment of friction — this
        // is the highest-intent moment in the whole app to offer it. Popping
        // it (back button, or a completed purchase) returns straight to
        // this chat, exactly where the user was.
        PlansScreen.open(context);
      }
    } on NotAuthenticatedException catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            role: 'assistant',
            content: '🔒 ${e.message}',
          ));
          _loading = false;
        });
      }
    } on ServerErrorException catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            role: 'assistant',
            content: '⚠️ **${e.message}**',
          ));
          _loading = false;
        });
      }
    } catch (e) {
      // Anything not already categorized above (SocketException etc. handled
      // in ApiService) genuinely looks like a connectivity issue by this
      // point -- but log the raw error too, in case something new slips
      // through uncategorized.
      debugPrint('AskScreen: unhandled error type reached generic catch — $e');
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

  String _truncateForQuote(String text) {
    final singleLine = text.replaceAll('\n', ' ').trim();
    return singleLine.length > 120 ? '${singleLine.substring(0, 120)}…' : singleLine;
  }

  void _startReply(ChatMessage message) {
    if (!kIsWeb) HapticFeedback.selectionClick();
    setState(() => _replyTarget = message);
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() => _replyTarget = null);
  }

  void _showMessageActions(BuildContext context, ChatMessage message, bool isDark) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.bgCardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: Text(t.replyAction),
              onTap: () {
                Navigator.pop(ctx);
                _startReply(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: Text(t.copyAction),
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: message.content));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearChat(BuildContext context) {
    if (!kIsWeb) HapticFeedback.selectionClick();
    setState(() {
      _messages.clear();
      _addWelcomeMessage(context);
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
      appBar: _buildAppBar(context, gold, secondary, isDark),
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
  
  PreferredSizeWidget _buildAppBar(BuildContext context, Color gold, Color secondary, bool isDark) {
    final t = AppLocalizations.of(context)!;
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
              Text(t.askWord, style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: gold,
                letterSpacing: -0.5,
              )),
              Text(t.anythingWord, style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: -0.5,
              )),
            ],
          ),
          Text(t.byPankajj,
            style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
        ],
      ),
      actions: [
        if (_messages.length > 1)
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 20, color: secondary),
            onPressed: () => _clearChat(context),
            tooltip: t.clearChat,
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
            AppLocalizations.of(context)!.askQuestionGuidance,
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
                  AppLocalizations.of(context)!.careerLoveMoneyHealth,
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
    final t = AppLocalizations.of(context)!;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.85,
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: () => _showMessageActions(context, message, isDark),
              child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (message.replySnippet != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(left: BorderSide(color: gold.withOpacity(0.6), width: 3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.replyIsUser == true ? t.replyingToYou : t.replyingToAssistant,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: gold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message.replySnippet!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: secondaryTextColor(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  MarkdownBody(
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
                ],
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
  
  Widget _buildReplyPreview(bool isDark, Color gold, Color secondary) {
    final target = _replyTarget;
    if (target == null) return const SizedBox.shrink();
    final t = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: gold.withOpacity(0.6), width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.role == 'user' ? t.replyingToYou : t.replyingToAssistant,
                  style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: gold),
                ),
                const SizedBox(height: 2),
                Text(
                  _truncateForQuote(target.content),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(fontSize: 12, color: secondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 18, color: secondary),
            onPressed: _cancelReply,
            tooltip: t.cancelReply,
            splashRadius: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildReplyPreview(isDark, gold, secondary),
          Row(
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
                        hintText: _isTyping ? AppLocalizations.of(context)!.typingLabel : AppLocalizations.of(context)!.askYourQuestion,
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
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    final dayName = days[time.weekday - 1];
    final dateStr = '${time.day} ${months[time.month-1]}';
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '$dayName, $hh:$mm';
    if (diff.inHours < 24) return '$dayName, $hh:$mm';
    return '$dayName $dateStr, $hh:$mm';
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