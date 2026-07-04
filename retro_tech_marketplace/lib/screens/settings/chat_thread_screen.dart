import 'package:flutter/material.dart';
import '../../constants/assets.dart';
import '../../constants/theme.dart';
import '../../models/listing.dart';
import '../../store/seed_data.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/interaction_helpers.dart';
import '../../widgets/liquid_button.dart';
import '../../widgets/logo_mark.dart';
import '../../widgets/navigation.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key, this.inShell = false});

  final bool inShell;

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final _searchSheetController = TextEditingController();
  String _filter = 'Messages';
  String _query = '';

  @override
  void dispose() {
    _searchSheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ResponsiveMetrics.of(context);
    final query = _query.trim().toLowerCase();
    final visibleMessages = _inboxMessages
        .where((message) {
          final listing = _listingFor(message);
          return message.type == _filter &&
              (query.isEmpty ||
                  message.name.toLowerCase().contains(query) ||
                  message.message.toLowerCase().contains(query) ||
                  (listing?.shortTitle.toLowerCase().contains(query) ??
                      false) ||
                  (listing?.priceLabel.toLowerCase().contains(query) ?? false));
        })
        .toList(growable: false);
    final content = ListView(
      padding: widget.inShell
          ? metrics.pageInsetsWithNav
          : EdgeInsets.fromLTRB(22, 18, 22, 30 + metrics.bottomSafeInset),
      children: [
        Row(
          children: [
            CircleGlassButton(
              icon: Icons.search_rounded,
              onTap: () => _showInboxSearch(context),
            ),
            Spacer(),
            Text('Inbox', style: AppTheme.h2),
            Spacer(),
            CircleGlassButton(
              icon: Icons.tune_rounded,
              onTap: () => _showInboxFilter(context),
            ),
          ],
        ),
        SizedBox(height: 18),
        Row(
          children: [
            for (final label in const ['Messages', 'Orders', 'Support'])
              FilterPill(
                label,
                _filter == label,
                onTap: () => setState(() => _filter = label),
              ),
          ],
        ),
        if (_query.trim().isNotEmpty) ...[
          SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            radius: 22,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Search: $_query',
                    style: AppTheme.body.copyWith(fontSize: 12),
                  ),
                ),
                CircleGlassButton(
                  icon: Icons.close_rounded,
                  size: 32,
                  onTap: () => setState(() => _query = ''),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 18),
        if (visibleMessages.isEmpty)
          GlassCard(
            child: Text('No conversations found.', style: AppTheme.body),
          )
        else
          ...visibleMessages.map(
            (message) => _MessageTile(message, listing: _listingFor(message)),
          ),
      ],
    );
    return widget.inShell ? content : GlassScaffold(child: content);
  }

  Listing? _listingFor(_InboxMessage message) {
    final listingId = message.listingId;
    if (listingId == null) return null;
    for (final listing in seedListings) {
      if (listing.id == listingId) return listing;
    }
    return null;
  }

  Future<void> _showInboxSearch(BuildContext context) async {
    _searchSheetController.text = _query;
    _searchSheetController.selection = TextSelection.collapsed(
      offset: _searchSheetController.text.length,
    );
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.white.withValues(alpha: 0.38),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: GlassCard(
              radius: 28,
              opacity: 0.84,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Inbox',
                    style: AppTheme.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 14),
                  GlassCard(
                    height: 48,
                    radius: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      key: const ValueKey('inbox-search-sheet-field'),
                      controller: _searchSheetController,
                      autofocus: true,
                      onSubmitted: (value) =>
                          Navigator.pop(sheetContext, value),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.search_rounded,
                          color: AppTheme.muted,
                          size: 18,
                        ),
                        hintText: 'Seller, order, or support',
                        hintStyle: AppTheme.body,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LiquidButton(
                    label: 'Apply Search',
                    height: 48,
                    icon: Icons.search_rounded,
                    onPressed: () => Navigator.pop(
                      sheetContext,
                      _searchSheetController.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    setState(() => _query = selected);
  }

  Future<void> _showInboxFilter(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.white.withValues(alpha: 0.38),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: GlassCard(
              radius: 28,
              opacity: 0.84,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Inbox',
                    style: AppTheme.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 14),
                  for (final label in const ['Messages', 'Orders', 'Support'])
                    LiquidPressable(
                      onTap: () => Navigator.pop(sheetContext, label),
                      active: _filter == label,
                      borderRadius: BorderRadius.circular(18),
                      glowColor: AppTheme.blue,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                label,
                                style: AppTheme.label.copyWith(
                                  color: _filter == label
                                      ? AppTheme.blue
                                      : AppTheme.ink,
                                ),
                              ),
                            ),
                            if (_filter == label)
                              const Icon(
                                Icons.check_rounded,
                                color: AppTheme.blue,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    setState(() => _filter = selected);
  }
}

class _InboxMessage {
  const _InboxMessage(
    this.type,
    this.name,
    this.message,
    this.time,
    this.badge,
    this.avatarAsset, {
    this.listingId,
  });

  final String type;
  final String name;
  final String message;
  final String time;
  final String badge;
  final String avatarAsset;
  final String? listingId;
}

const _inboxMessages = [
  _InboxMessage(
    'Messages',
    'RetroTech Collector',
    'The iPod is fully tested and ready to ship.',
    '2m',
    '2',
    Assets.avatarSilhouette,
    listingId: 'ipod-classic',
  ),
  _InboxMessage(
    'Messages',
    'VintageAudioCo',
    'I can include the original earbuds for you.',
    '18m',
    '1',
    Assets.avatarVintage,
    listingId: 'walkman',
  ),
  _InboxMessage(
    'Messages',
    'PalmPilotFan',
    'Battery holds charge well. Let me know if you want more photos.',
    '1h',
    '3',
    Assets.avatarPalm,
    listingId: 'palm',
  ),
  _InboxMessage(
    'Orders',
    'RetroTech Orders',
    'Your latest order is paid and seller notified.',
    'Today',
    '',
    Assets.logoMark,
    listingId: 'ipod-classic',
  ),
  _InboxMessage(
    'Support',
    'RetroTech Support',
    'We can help with listings, payments, and account questions.',
    'Yesterday',
    '',
    Assets.avatarPixel,
  ),
];

class _MessageTile extends StatelessWidget {
  const _MessageTile(this.message, {this.listing});

  final _InboxMessage message;
  final Listing? listing;

  @override
  Widget build(BuildContext context) {
    final item = listing;
    final unread = message.badge.isNotEmpty;
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: OpenMotionContainer(
        radius: 30,
        openPage: ChatThreadScreen(listing: item, sellerName: message.name),
        routeSettings: const RouteSettings(name: '/chat'),
        closedBuilder: (openContainer) => LiquidPressable(
          onTap: openContainer,
          borderRadius: BorderRadius.circular(30),
          glowColor: AppTheme.blue,
          child: GlassCard(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: ProductImage(
                    asset: message.avatarAsset,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item != null) ...[
                            Container(
                              width: 56,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.58),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              child: ProductImage(
                                asset: item.imageAsset,
                                width: 52,
                                height: 48,
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.body.copyWith(
                                    color: unread
                                        ? AppTheme.ink
                                        : AppTheme.muted,
                                    fontSize: 12,
                                    fontWeight: unread
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (item != null) ...[
                                  SizedBox(height: 5),
                                  Text(
                                    '${item.priceLabel} - ${_cleanMeta(item.condition)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.label.copyWith(
                                      color: AppTheme.blue,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      message.time,
                      style: AppTheme.body.copyWith(
                        color: unread ? AppTheme.blue : AppTheme.muted,
                        fontSize: 10,
                        fontWeight: unread ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                    if (unread)
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          message.badge,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _cleanMeta(String value) => value.replaceAll('\n', ' - ');
}

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key, this.listing, this.sellerName});

  final Listing? listing;
  final String? sellerName;

  @override
  State<ChatThreadScreen> createState() => ChatThreadScreenState();
}

class ChatThreadScreenState extends State<ChatThreadScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final List<_ChatLine> _messages = _initialMessages;

  Listing get _item => widget.listing ?? seedListings.first;
  String get _sellerName =>
      widget.sellerName ?? widget.listing?.seller ?? _item.seller;
  String get _sellerAvatarAsset {
    return switch (_sellerName) {
      'VintageAudioCo' => Assets.avatarVintage,
      'PalmPilotFan' => Assets.avatarPalm,
      'PixelCam Studio' => Assets.avatarPixel,
      _ => Assets.avatarSilhouette,
    };
  }

  List<_ChatLine> get _initialMessages {
    final item = _item;
    return [
      _ChatLine(
        widget.listing == null
            ? 'Hi! Thanks for reaching out.'
            : 'Hi! Thanks for your interest in the ${item.title}.',
        false,
        '2:14 PM',
      ),
      _ChatLine(
        "It's in excellent condition. The front and back are clean.",
        false,
        '2:15 PM',
      ),
      _ChatLine(
        'Thanks! Can you confirm storage capacity and battery?',
        true,
        '2:16 PM',
      ),
      _ChatLine(
        "Sure! It is the ${item.storage} model and battery holds charge well.",
        false,
        '2:17 PM',
      ),
      _ChatLine(
        'Perfect, please do. Also, do you ship to Kuala Lumpur?',
        true,
        '2:18 PM',
      ),
      _ChatLine(
        'Yes, shipping is RM15 via Pos Laju and usually takes 2-3 working days.',
        false,
        '2:18 PM',
      ),
      _ChatLine(
        "Great! I'll take it. Please let me know your preferred payment method.",
        true,
        '2:19 PM',
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatLine(text, true, 'Now'));
      _messageController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    final metrics = ResponsiveMetrics.of(context);
    return GlassScaffold(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              metrics.pagePadding,
              metrics.topGap,
              metrics.pagePadding,
              0,
            ),
            child: Row(
              children: [
                CircleGlassButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                SizedBox(width: 12),
                ClipOval(
                  child: ProductImage(
                    asset: _sellerAvatarAsset,
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sellerName,
                        style: AppTheme.h2.copyWith(fontSize: 16),
                      ),
                      Text(
                        'Active today',
                        style: AppTheme.body.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                CircleGlassButton(
                  icon: Icons.more_horiz_rounded,
                  onTap: () => showInfoSheet(
                    context,
                    icon: Icons.more_horiz_rounded,
                    title: 'Conversation details',
                    body:
                        'This demo keeps chat messages locally on this screen. Attachments, blocking, and reporting are not connected yet.',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              metrics.pagePadding,
              14,
              metrics.pagePadding,
              10,
            ),
            child: GlassCard(
              radius: 26,
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: LiquidPressable(
                      key: const ValueKey('chat-product-card-open-product'),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/product',
                        arguments: item,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      glowColor: AppTheme.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          children: [
                            ProductImage(
                              asset: item.imageAsset,
                              width: 64,
                              height: 58,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.shortTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    item.priceLabel,
                                    style: AppTheme.label.copyWith(
                                      color: AppTheme.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    '${_cleanListingMeta(item.condition)} - Rating ${item.rating.toStringAsFixed(1)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.body.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.blue,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: metrics.compact ? 78 : 88,
                    child: LiquidButton(
                      key: const ValueKey('chat-product-card-buy-now'),
                      label: 'Buy Now',
                      height: 44,
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/checkout',
                        arguments: item,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                metrics.pagePadding,
                8,
                metrics.pagePadding,
                8,
              ),
              children: [
                Center(
                  child: Text(
                    'Today 2:14 PM',
                    style: AppTheme.body.copyWith(fontSize: 11),
                  ),
                ),
                SizedBox(height: 12),
                ..._messages.map(
                  (message) => _ChatBubble(
                    message,
                    sellerAvatarAsset: _sellerAvatarAsset,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              metrics.pagePadding,
              6,
              metrics.pagePadding,
              18 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: GlassCard(
              radius: 999,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.image_outlined, color: AppTheme.muted),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      key: const ValueKey('chat-message-field'),
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(),
                      minLines: 1,
                      maxLines: 3,
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message seller',
                        hintStyle: AppTheme.body,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  CircleGlassButton(
                    icon: Icons.send_rounded,
                    color: AppTheme.red,
                    size: 42,
                    onTap: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _cleanListingMeta(String value) => value.replaceAll('\n', ' - ');

class _ChatLine {
  const _ChatLine(this.text, this.mine, this.time);

  final String text;
  final bool mine;
  final String time;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble(this.line, {required this.sellerAvatarAsset});

  final _ChatLine line;
  final String sellerAvatarAsset;

  @override
  Widget build(BuildContext context) {
    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      child: Container(
        padding: EdgeInsets.all(13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: line.mine
              ? Colors.white.withValues(alpha: 0.56)
              : Colors.white.withValues(alpha: 0.76),
          border: Border.all(
            color: line.mine
                ? AppTheme.blue.withValues(alpha: 0.34)
                : Colors.white.withValues(alpha: 0.88),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              line.text,
              style: TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line.time,
                  style: TextStyle(color: AppTheme.muted, fontSize: 10),
                ),
                if (line.mine) ...[
                  SizedBox(width: 5),
                  Icon(Icons.done_all_rounded, color: AppTheme.blue, size: 13),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: line.mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!line.mine) ...[
            ClipOval(
              child: ProductImage(
                asset: sellerAvatarAsset,
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(child: bubble),
        ],
      ),
    );
  }
}
