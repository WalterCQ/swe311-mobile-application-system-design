import 'package:flutter/material.dart';
import '../../constants/assets.dart';
import '../../constants/theme.dart';
import '../../models/community_record.dart';
import '../../models/listing.dart';
import '../../store/listing_store.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/interaction_helpers.dart';
import '../../widgets/liquid_button.dart';
import '../../widgets/logo_mark.dart';
import '../../widgets/navigation.dart';
import '../product/product_detail_screen.dart';
import '../profile/account_profile_screen.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.store,
    required this.listing,
    this.size = 42,
  });

  final ListingStore store;
  final Listing listing;
  final double size;

  @override
  State<FavoriteButton> createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final favorite = widget.store.isSaved(widget.listing.id);
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: LiquidPressable(
            onTap: () {
              widget.store.toggleSaved(widget.listing.id);
            },
            borderRadius: BorderRadius.circular(widget.size / 2),
            glowColor: AppTheme.red,
            active: favorite,
            pressedScale: 0.94,
            child: GlassCard(
              width: widget.size,
              height: widget.size,
              radius: widget.size / 2,
              padding: EdgeInsets.zero,
              opacity: favorite ? 0.72 : 0.62,
              child: Icon(
                favorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: AppTheme.red,
                size: widget.size * 0.45,
              ),
            ),
          ),
        );
      },
    );
  }
}

class HomeListingCard extends StatefulWidget {
  const HomeListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.heroTag,
    this.margin,
    this.store,
  });

  final Listing listing;
  final VoidCallback? onTap;
  final Object? heroTag;
  final EdgeInsetsGeometry? margin;
  final ListingStore? store;

  @override
  State<HomeListingCard> createState() => _HomeListingCardState();
}

class _HomeListingCardState extends State<HomeListingCard> {
  late final PageController _galleryController;
  int _activeImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _galleryController = PageController();
  }

  @override
  void didUpdateWidget(HomeListingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final imageCount = widget.listing.detailImageAssets.length;
    if (oldWidget.listing.id != widget.listing.id ||
        _activeImageIndex >= imageCount) {
      _activeImageIndex = 0;
      if (_galleryController.hasClients) {
        _galleryController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ResponsiveMetrics.of(context);
    final listing = widget.listing;
    final isMotorola = listing.id == 'motorola-v60';
    final isIpod = listing.id == 'ipod-classic';
    final galleryImages = listing.detailImageAssets;
    final usesVerticalImageFrame =
        listing.imageAsset == Assets.v60 ||
        listing.imageAsset == Assets.ipodFront ||
        listing.imageAsset == Assets.walkman ||
        listing.imageAsset == Assets.gameboy ||
        listing.imageAsset == Assets.palm ||
        listing.imageAsset == Assets.watch;
    final usesSquareImageFrame =
        listing.imageAsset == Assets.discmanHome ||
        listing.imageAsset == Assets.imac;
    final usesWideImageFrame =
        listing.imageAsset == Assets.minidisc ||
        listing.imageAsset == Assets.camera;
    final imageWidth = usesVerticalImageFrame
        ? 176.0
        : usesSquareImageFrame
        ? 140.0
        : usesWideImageFrame
        ? 200.0
        : 167.0;
    final imageHeight = usesVerticalImageFrame
        ? 264.0
        : usesSquareImageFrame
        ? 140.0
        : usesWideImageFrame
        ? 140.0
        : 115.0;
    final imageFit = usesSquareImageFrame || usesWideImageFrame
        ? BoxFit.cover
        : BoxFit.contain;
    return Container(
      margin: widget.margin ?? EdgeInsets.only(bottom: metrics.gutter + 2),
      child: LiquidPressable(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(metrics.cardRadius),
        glowColor: AppTheme.red,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = metrics.homeCardHeight;
            final compact = constraints.maxWidth < 340;
            final buttonSize = compact ? 32.0 : 36.0;
            return GlassCard(
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 20,
                compact ? 14 : 16,
                compact ? 12 : 14,
                compact ? 14 : 18,
              ),
              radius: metrics.cardRadius,
              opacity: 0.22,
              blur: 42,
              borderOpacity: 0.9,
              child: SizedBox(
                height: cardHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: compact ? 5 : 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.status,
                            style: AppTheme.label.copyWith(fontSize: 12),
                          ),
                          SizedBox(height: compact ? 7 : 9),
                          Text.rich(
                            TextSpan(
                              style: AppTheme.h2.copyWith(
                                fontSize: compact ? 20 : 23,
                                height: 1.05,
                              ),
                              children: [
                                TextSpan(
                                  text: isMotorola
                                      ? 'Motorola\n'
                                      : '${listing.title}\n',
                                ),
                                TextSpan(
                                  text: isIpod ? '4th Gen ' : listing.subtitle,
                                ),
                                accentSquare(size: 8),
                              ],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          _RatingLine(listing: listing),
                          SizedBox(height: compact ? 6 : 7),
                          Text(
                            listing.priceLabel,
                            style: TextStyle(
                              color: AppTheme.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: compact ? 4 : 6),
                    Expanded(
                      flex: compact ? 5 : 6,
                      child: Column(
                        children: [
                          Expanded(
                            child: Transform.scale(
                              scale: compact ? 1.12 : 1.16,
                              child: PageView.builder(
                                key: ValueKey(
                                  'home-gallery-page-view-${listing.id}',
                                ),
                                controller: _galleryController,
                                physics: const BouncingScrollPhysics(),
                                itemCount: galleryImages.length,
                                onPageChanged: (index) =>
                                    setState(() => _activeImageIndex = index),
                                itemBuilder: (context, index) {
                                  return FittedBox(
                                    fit: BoxFit.contain,
                                    child: ProductImage(
                                      asset: galleryImages[index],
                                      width: imageWidth,
                                      height: imageHeight,
                                      fit: imageFit,
                                      heroTag: index == _activeImageIndex
                                          ? widget.heroTag
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 4 : 6),
                          Dots(
                            count: galleryImages.length,
                            activeIndex: _activeImageIndex,
                            keyPrefix: 'home-gallery-${listing.id}',
                            onSelected: (index) =>
                                _galleryController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutCubic,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: compact ? 4 : 6),
                    SizedBox(
                      width: buttonSize,
                      child: Column(
                        children: [
                          if (widget.store == null)
                            CircleGlassButton(
                              icon: Icons.favorite_border_rounded,
                              color: AppTheme.red,
                              size: buttonSize,
                            )
                          else
                            FavoriteButton(
                              store: widget.store!,
                              listing: listing,
                              size: buttonSize,
                            ),
                          SizedBox(height: compact ? 7 : 9),
                          CircleGlassButton(
                            icon: Icons.shopping_cart_outlined,
                            color: AppTheme.blue,
                            size: buttonSize,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/checkout',
                              arguments: listing,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.store,
    required this.onSearchTap,
    required this.onProfileTap,
  });

  final ListingStore store;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final metrics = ResponsiveMetrics.of(context);
        return ListView(
          padding: metrics.pageInsetsWithNav,
          children: [
            Row(
              children: [
                CircleGlassImageButton(
                  key: const ValueKey('home-profile-avatar-button'),
                  asset: Assets.homeAvatar,
                  onTap: widget.onProfileTap,
                ),
                SizedBox(width: metrics.compact ? 12 : 18),
                Expanded(
                  child: GlassCard(
                    height: 48,
                    radius: 26,
                    padding: EdgeInsets.all(5),
                    child: HomeSegmentControl(
                      value: _segment,
                      onChanged: (value) {
                        if (_segment == value) return;
                        setState(() => _segment = value);
                      },
                    ),
                  ),
                ),
                SizedBox(width: metrics.compact ? 12 : 18),
                if (_segment == 0)
                  CircleGlassButton(
                    key: const ValueKey('home-search-button'),
                    icon: Icons.search_rounded,
                    onTap: widget.onSearchTap,
                  )
                else
                  const SizedBox(width: 46, height: 46),
              ],
            ),
            SizedBox(height: metrics.compact ? 20 : 28),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                reverseDuration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final fromRight = (child.key as ValueKey<int>).value == 1;
                  final offset = Tween<Offset>(
                    begin: Offset(fromRight ? 0.055 : -0.055, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_segment),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _segment == 0
                        ? _marketContent(context)
                        : _communityContent(context),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _marketContent(BuildContext context) {
    final listings = widget.store.listings;
    return [
      RichText(
        text: TextSpan(
          style: AppTheme.hero,
          children: [
            TextSpan(text: 'Rediscover\n'),
            TextSpan(
              text: 'Iconic',
              style: TextStyle(color: AppTheme.red),
            ),
            accentSquare(size: 13, gap: 7),
          ],
        ),
      ),
      SizedBox(height: 12),
      Text(
        'Buy, sell, and collect authentic\nY2K electronics.',
        style: AppTheme.body.copyWith(fontSize: 18),
      ),
      SizedBox(height: 22),
      Row(
        children: [
          SolidCircleButton(
            icon: Icons.north_east_rounded,
            onTap: () =>
                Navigator.pushNamed(context, '/category', arguments: 'Audio'),
          ),
          SizedBox(width: 14),
          Text(
            'Explore\nCollection',
            style: AppTheme.h2.copyWith(fontSize: 16),
          ),
        ],
      ),
      SizedBox(height: 22),
      ...listings.take(3).map((listing) {
        return ListingCard(
          listing: listing,
          large: true,
          openStore: widget.store,
          onTap: () =>
              Navigator.pushNamed(context, '/product', arguments: listing),
        );
      }),
    ];
  }

  List<Widget> _communityContent(BuildContext context) {
    final posts = [..._communityPosts];
    posts.sort(
      (a, b) => (b.likes + b.replies * 2).compareTo(a.likes + a.replies * 2),
    );

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              'Community',
              style: AppTheme.h1.copyWith(fontSize: 30, height: 1),
            ),
          ),
          Text('Latest', style: AppTheme.label.copyWith(color: AppTheme.muted)),
        ],
      ),
      SizedBox(height: 10),
      Text(
        'Collectors, restorers, and transparent tech fans share finds here.',
        style: AppTheme.body,
      ),
      SizedBox(height: 16),
      for (final post in posts)
        Builder(
          builder: (context) {
            final liked = widget.store.isCommunityPostLiked(post.id);
            final extraReplies = widget.store.communityRepliesFor(post.id);
            return CommunityPostCard(
              user: post.user,
              handle: post.handle,
              time: post.time,
              text: post.text,
              asset: post.asset,
              likes: post.likes + (liked ? 1 : 0),
              replies: post.replies + extraReplies.length,
              liked: liked,
              sourceLabel: 'For you',
              onReply: () => _openCommunityPost(context, post),
              onLike: () => _toggleCommunityPostLike(post),
              onTap: () => _openCommunityPost(context, post),
            );
          },
        ),
    ];
  }

  void _toggleCommunityPostLike(_CommunityPost post) {
    widget.store.toggleCommunityPostLike(post.id);
  }

  void _openCommunityPost(BuildContext context, _CommunityPost post) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        settings: const RouteSettings(name: '/community-post'),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _CommunityThreadScreen(store: widget.store, post: post),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0.045, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _CommunityPost {
  const _CommunityPost({
    required this.id,
    required this.user,
    required this.handle,
    required this.time,
    required this.text,
    required this.asset,
    required this.likes,
    required this.replies,
    required this.replyItems,
  });

  final String id;
  final String user;
  final String handle;
  final String time;
  final String text;
  final String asset;
  final int likes;
  final int replies;
  final List<_CommunityReply> replyItems;
}

class _CommunityReply {
  const _CommunityReply({
    required this.user,
    required this.handle,
    required this.time,
    required this.text,
    required this.asset,
  });

  final String user;
  final String handle;
  final String time;
  final String text;
  final String asset;
}

String _communityReplyKey(_CommunityReply reply) =>
    '${reply.user}|${reply.handle}|${reply.time}|${reply.text}';

_CommunityReply _replyFromRecord(CommunityReplyRecord reply) {
  return _CommunityReply(
    user: reply.user,
    handle: reply.handle,
    time: reply.time,
    text: reply.text,
    asset: reply.asset,
  );
}

const _communityPosts = [
  _CommunityPost(
    id: 'vintage-audio-earbuds',
    user: 'VintageAudioCo',
    handle: '@vintageaudioco',
    time: '18m',
    text: 'I can include the original earbuds for the Walkman bundle.',
    asset: Assets.avatarVintage,
    likes: 24,
    replies: 8,
    replyItems: [
      _CommunityReply(
        user: 'RetroTech Collector',
        handle: '@retrotech',
        time: '12m',
        text: 'That makes the bundle much more complete.',
        asset: Assets.logoMark,
      ),
      _CommunityReply(
        user: 'PalmPilotFan',
        handle: '@palmpilotfan',
        time: '5m',
        text: 'Original accessories always help buyers trust the listing.',
        asset: Assets.avatarPalm,
      ),
    ],
  ),
  _CommunityPost(
    id: 'palm-battery-photos',
    user: 'PalmPilotFan',
    handle: '@palmpilotfan',
    time: '1h',
    text:
        'Battery holds charge well. Ask for more photos before buying rare PDAs.',
    asset: Assets.avatarPalm,
    likes: 18,
    replies: 5,
    replyItems: [
      _CommunityReply(
        user: 'PixelCam Studio',
        handle: '@pixelcam',
        time: '45m',
        text: 'A stylus photo and screen contrast shot help a lot.',
        asset: Assets.avatarPixel,
      ),
      _CommunityReply(
        user: 'VintageAudioCo',
        handle: '@vintageaudioco',
        time: '28m',
        text: 'I also check the dock connector before making an offer.',
        asset: Assets.avatarVintage,
      ),
    ],
  ),
  _CommunityPost(
    id: 'pixelcam-transparent-photos',
    user: 'PixelCam Studio',
    handle: '@pixelcam',
    time: 'Yesterday',
    text:
        'Transparent tech photographs best against high-key white backgrounds.',
    asset: Assets.avatarPixel,
    likes: 31,
    replies: 11,
    replyItems: [
      _CommunityReply(
        user: 'RetroTech Collector',
        handle: '@retrotech',
        time: '21h',
        text:
            'Side lighting also shows scratches without making them look worse.',
        asset: Assets.logoMark,
      ),
      _CommunityReply(
        user: 'PalmPilotFan',
        handle: '@palmpilotfan',
        time: '19h',
        text: 'Great tip for clear Game Boy shells.',
        asset: Assets.avatarPalm,
      ),
    ],
  ),
];

class _CommunityThreadScreen extends StatefulWidget {
  const _CommunityThreadScreen({required this.store, required this.post});

  final ListingStore store;
  final _CommunityPost post;

  @override
  State<_CommunityThreadScreen> createState() => _CommunityThreadScreenState();
}

class _CommunityThreadScreenState extends State<_CommunityThreadScreen> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  void _toggleLike() {
    widget.store.toggleCommunityPostLike(widget.post.id);
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) {
      _focusReplyInput();
      showAppSnackBar(context, 'Write a reply first.');
      return;
    }
    final now = DateTime.now();
    await widget.store.addCommunityReply(
      CommunityReplyRecord(
        id: 'reply-${now.microsecondsSinceEpoch}',
        postId: widget.post.id,
        user: 'RetroTech Collector',
        handle: '@retrotech',
        time: 'Now',
        text: text,
        asset: Assets.logoMark,
        createdAt: now,
      ),
    );
    if (!mounted) return;
    _replyController.clear();
  }

  void _focusReplyInput() {
    _replyFocusNode.requestFocus();
  }

  void _replyTo(_CommunityReply reply) {
    final prefix = '${reply.handle} ';
    final current = _replyController.text.trimLeft();
    final nextText = current.startsWith(prefix) ? current : '$prefix$current';
    _replyController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
    _focusReplyInput();
  }

  void _toggleReplyLike(_CommunityReply reply) {
    final replyId = _communityReplyKey(reply);
    final liked = !widget.store.isCommunityReplyLiked(replyId);
    widget.store.toggleCommunityReplyLike(replyId);
    showAppSnackBar(context, liked ? 'Reply liked.' : 'Reply unliked.');
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ResponsiveMetrics.of(context);
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final liked = widget.store.isCommunityPostLiked(widget.post.id);
        final storedReplies = widget.store.communityRepliesFor(widget.post.id);
        final replies = [
          ...storedReplies.map(_replyFromRecord),
          ...widget.post.replyItems,
        ];
        final likeCount = widget.post.likes + (liked ? 1 : 0);
        final replyCount = widget.post.replies + storedReplies.length;

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
                child: TopBar(title: 'Post', showTrailing: false),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    metrics.pagePadding,
                    18,
                    metrics.pagePadding,
                    18,
                  ),
                  children: [
                    GlassCard(
                      padding: EdgeInsets.all(18),
                      radius: metrics.cardRadius,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CommunityPostBody(
                            post: widget.post,
                            likeCount: likeCount,
                            replyCount: replyCount,
                            liked: liked,
                            onReply: _focusReplyInput,
                            onLike: _toggleLike,
                          ),
                          SizedBox(height: 18),
                          Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                          SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Relevant replies',
                                  style: AppTheme.h2.copyWith(fontSize: 17),
                                ),
                              ),
                              Text(
                                'Latest first',
                                style: AppTheme.label.copyWith(
                                  color: AppTheme.muted,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          for (final reply in replies)
                            _CommunityReplyTile(
                              key: ObjectKey(reply),
                              reply: reply,
                              liked: widget.store.isCommunityReplyLiked(
                                _communityReplyKey(reply),
                              ),
                              onReply: () => _replyTo(reply),
                              onLike: () => _toggleReplyLike(reply),
                            ),
                        ],
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
                  18 + metrics.bottomSafeInset,
                ),
                child: GlassCard(
                  radius: 999,
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      ClipOval(
                        child: ProductImage(
                          asset: Assets.logoMark,
                          width: 34,
                          height: 34,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          focusNode: _replyFocusNode,
                          onSubmitted: (_) => _sendReply(),
                          minLines: 1,
                          maxLines: 3,
                          style: TextStyle(
                            color: AppTheme.ink,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Reply to ${widget.post.user}',
                            hintStyle: AppTheme.body,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      CircleGlassButton(
                        key: const ValueKey('community-send-reply'),
                        icon: Icons.arrow_upward_rounded,
                        color: AppTheme.blue,
                        size: 40,
                        onTap: _sendReply,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommunityPostBody extends StatelessWidget {
  const _CommunityPostBody({
    required this.post,
    required this.likeCount,
    required this.replyCount,
    required this.liked,
    required this.onReply,
    required this.onLike,
  });

  final _CommunityPost post;
  final int likeCount;
  final int replyCount;
  final bool liked;
  final VoidCallback onReply;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommunityAuthorRow(
          user: post.user,
          handle: post.handle,
          time: post.time,
          asset: post.asset,
          avatarSize: 52,
          onMoreTap: () => showInfoSheet(
            context,
            icon: Icons.more_horiz_rounded,
            title: 'Post options',
            body: 'Copy this post text so you can share or save it.',
            actionLabel: 'Copy post',
            onAction: () {
              copyShareText(
                context,
                label: 'Post',
                text: '${post.user}: ${post.text}',
              );
            },
          ),
        ),
        SizedBox(height: 16),
        Text(
          post.text,
          style: AppTheme.body.copyWith(
            color: AppTheme.ink,
            fontSize: 20,
            height: 1.35,
          ),
        ),
        SizedBox(height: 18),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _CommunityMetric(value: '$replyCount', label: 'Replies'),
            _CommunityMetric(value: '$likeCount', label: 'Likes'),
          ],
        ),
        SizedBox(height: 12),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.72)),
        SizedBox(height: 8),
        Row(
          children: [
            _CommunityActionButton(
              key: const ValueKey('community-post-reply'),
              icon: Icons.chat_bubble_outline_rounded,
              label: '$replyCount',
              color: AppTheme.blue,
              onTap: onReply,
            ),
            SizedBox(width: 16),
            _CommunityActionButton(
              key: const ValueKey('community-post-like'),
              icon: liked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: '$likeCount',
              color: AppTheme.red,
              active: liked,
              onTap: onLike,
            ),
          ],
        ),
      ],
    );
  }
}

class _CommunityReplyTile extends StatelessWidget {
  const _CommunityReplyTile({
    super.key,
    required this.reply,
    required this.liked,
    required this.onReply,
    required this.onLike,
  });

  final _CommunityReply reply;
  final bool liked;
  final VoidCallback onReply;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final key = _communityReplyKey(reply);
    return Padding(
      padding: EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _Avatar(asset: reply.asset, size: 40),
              Container(
                width: 2,
                height: 54,
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: AppTheme.line.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CommunityInlineMeta(
                  user: reply.user,
                  handle: reply.handle,
                  time: reply.time,
                ),
                SizedBox(height: 6),
                Text(
                  reply.text,
                  style: AppTheme.body.copyWith(
                    color: AppTheme.ink,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    _CommunityActionButton(
                      key: ValueKey('community-reply-reply-$key'),
                      icon: Icons.chat_bubble_outline_rounded,
                      color: AppTheme.blue,
                      onTap: onReply,
                    ),
                    SizedBox(width: 10),
                    _CommunityActionButton(
                      key: ValueKey('community-reply-like-$key'),
                      icon: liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: AppTheme.red,
                      active: liked,
                      onTap: onLike,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityMetric extends StatelessWidget {
  const _CommunityMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTheme.label.copyWith(color: AppTheme.muted),
        children: [
          TextSpan(
            text: value,
            style: AppTheme.label.copyWith(color: AppTheme.ink),
          ),
          TextSpan(text: ' $label'),
        ],
      ),
    );
  }
}

class _CommunityAuthorRow extends StatelessWidget {
  const _CommunityAuthorRow({
    required this.user,
    required this.handle,
    required this.time,
    required this.asset,
    required this.avatarSize,
    this.onMoreTap,
  });

  final String user;
  final String handle;
  final String time;
  final String asset;
  final double avatarSize;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(asset: asset, size: avatarSize),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              SizedBox(height: 2),
              _CommunityMetaLine(handle: handle, time: time, fontSize: 12),
            ],
          ),
        ),
        CircleGlassButton(
          icon: Icons.more_horiz_rounded,
          size: 34,
          onTap: onMoreTap,
        ),
      ],
    );
  }
}

class _CommunityInlineMeta extends StatelessWidget {
  const _CommunityInlineMeta({
    required this.user,
    required this.handle,
    required this.time,
  });

  final String user;
  final String handle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            user,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: _CommunityMetaLine(handle: handle, time: time, fontSize: 11),
        ),
      ],
    );
  }
}

class _CommunityMetaLine extends StatelessWidget {
  const _CommunityMetaLine({
    required this.handle,
    required this.time,
    required this.fontSize,
  });

  final String handle;
  final String time;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            handle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.body.copyWith(fontSize: fontSize),
          ),
        ),
        SizedBox(width: 8),
        Text(
          time,
          maxLines: 1,
          style: AppTheme.body.copyWith(fontSize: fontSize),
        ),
      ],
    );
  }
}

class _CommunityActionButton extends StatelessWidget {
  const _CommunityActionButton({
    super.key,
    required this.icon,
    this.label,
    required this.color,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String? label;
  final Color color;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LiquidPressable(
      onTap: onTap,
      active: active,
      borderRadius: BorderRadius.circular(18),
      glowColor: color,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: color),
            if (label != null) ...[
              SizedBox(width: 5),
              Text(
                label!,
                style: AppTheme.label.copyWith(color: color, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: ProductImage(asset: asset, width: size, height: size),
    );
  }
}

class _RatingLine extends StatelessWidget {
  const _RatingLine({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: AppTheme.blue, size: 14),
          SizedBox(width: 3),
          Text(
            '${listing.rating.toStringAsFixed(1)} (${listing.reviews})',
            style: AppTheme.label.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class HomeSegmentControl extends StatelessWidget {
  const HomeSegmentControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: value == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withValues(alpha: 0.82),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.red.withValues(alpha: 0.14),
                      offset: Offset(0, 7),
                      blurRadius: 15,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.54),
                      offset: Offset(-2, -2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            SegmentPill('Market', value == 0, () => onChanged(0)),
            SegmentPill('Community', value == 1, () => onChanged(1)),
          ],
        ),
      ],
    );
  }
}

class SegmentPill extends StatelessWidget {
  const SegmentPill(this.label, this.active, this.onTap, {super.key});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LiquidPressable(
        onTap: onTap,
        active: active,
        borderRadius: BorderRadius.circular(24),
        glowColor: AppTheme.red,
        pressedScale: 0.96,
        child: AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: active ? AppTheme.red : AppTheme.muted,
          ),
          child: Center(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.openStore,
    this.large = false,
  });

  final Listing listing;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ListingStore? openStore;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final metrics = ResponsiveMetrics.of(context);
    final hasActions = onEdit != null || onDelete != null;
    final heroTag = listingHeroTag(listing);

    Widget buildCard(VoidCallback? tap, {EdgeInsetsGeometry? margin}) {
      if (!hasActions) {
        return HomeListingCard(
          listing: listing,
          onTap: tap,
          heroTag: heroTag,
          margin: margin,
          store: openStore,
        );
      }
      final imageWidth = 172.0;
      final imageHeight = 184.0;
      final compact = metrics.compact;
      final detailsColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(listing.status.toUpperCase(), style: AppTheme.label),
          SizedBox(height: compact ? 3 : 5),
          Text(
            listing.shortTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.h2.copyWith(
              fontSize: large ? 25 : (compact ? 17 : 18),
            ),
          ),
          SizedBox(height: compact ? 3 : 5),
          _RatingLine(listing: listing),
          const Spacer(),
          Text(
            listing.priceLabel,
            style: TextStyle(
              color: AppTheme.red,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 12 : 13,
            ),
          ),
          if (!large) ...[
            SizedBox(height: compact ? 2 : 4),
            Text(
              '${listing.views} views',
              style: AppTheme.body.copyWith(fontSize: compact ? 10 : 11),
            ),
          ],
        ],
      );

      return LiquidPressable(
        onTap: tap,
        borderRadius: BorderRadius.circular(metrics.cardRadius),
        glowColor: AppTheme.blue,
        child: GlassCard(
          margin: margin ?? EdgeInsets.only(bottom: metrics.gutter + 2),
          padding: EdgeInsets.fromLTRB(20, 16, 14, 18),
          radius: metrics.cardRadius,
          opacity: 0.22,
          blur: 42,
          borderOpacity: 0.9,
          child: SizedBox(
            height: metrics.listingActionCardHeight + (compact ? 4 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: metrics.compact ? 5 : 4, child: detailsColumn),
                SizedBox(width: metrics.compact ? 4 : 6),
                Expanded(
                  flex: metrics.compact ? 5 : 6,
                  child: Transform.scale(
                    scale: metrics.compact ? 1.1 : 1.14,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: ProductImage(
                        asset: listing.imageAsset,
                        width: imageWidth,
                        height: imageHeight,
                        heroTag: heroTag,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: metrics.compact ? 4 : 6),
                SizedBox(
                  width: 38,
                  child: Column(
                    children: [
                      CircleGlassButton(
                        icon: Icons.edit_rounded,
                        color: AppTheme.blue,
                        size: 38,
                        onTap: onEdit,
                      ),
                      SizedBox(height: 10),
                      CircleGlassButton(
                        icon: Icons.delete_outline_rounded,
                        color: AppTheme.red,
                        size: 38,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final store = openStore;
    if (store == null) return buildCard(onTap);

    return Container(
      margin: EdgeInsets.only(bottom: metrics.gutter + 2),
      child: OpenMotionContainer(
        radius: metrics.cardRadius,
        routeSettings: RouteSettings(name: '/product', arguments: listing),
        openPage: ProductDetailScreen(store: store, listing: listing),
        closedBuilder: (openContainer) =>
            buildCard(openContainer, margin: EdgeInsets.zero),
      ),
    );
  }
}
