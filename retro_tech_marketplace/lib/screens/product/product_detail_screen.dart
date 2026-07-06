import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../models/listing.dart';
import '../../store/listing_store.dart';
import '../../store/seed_data.dart';
import '../../widgets/aero_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/interaction_helpers.dart';
import '../../widgets/liquid_button.dart';
import '../../widgets/logo_mark.dart';
import '../../widgets/navigation.dart';
import '../home/home_screen.dart';
import 'product_video_player.dart';

typedef ProductVideoPlayerBuilder = MultimediaPlayer Function(String asset);

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.store,
    this.listing,
    this.videoPlayerBuilder,
  });

  final ListingStore store;
  final Listing? listing;
  final ProductVideoPlayerBuilder? videoPlayerBuilder;

  @override
  Widget build(BuildContext context) {
    final fallbackItem = seedListings.firstWhere(
      (item) => item.id == 'ipod-classic',
    );
    final item =
        listing ??
        store.byId('ipod-classic') ??
        (store.listings.isNotEmpty ? store.listings.first : fallbackItem);
    return GlassScaffold(
      includeSafeArea: false,
      background: const DetailAeroBackground(),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final metrics = ResponsiveMetrics.of(context);
            final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
            return Stack(
              children: [
                ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    metrics.pagePadding,
                    metrics.topGap,
                    metrics.pagePadding,
                    104 + bottomPadding,
                  ),
                  children: [
                    Row(
                      children: [
                        CircleGlassButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          size: 44,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        CircleGlassButton(
                          icon: Icons.ios_share_rounded,
                          size: 44,
                          onTap: () => copyShareText(
                            context,
                            label: 'Product details',
                            text:
                                'RetroTech listing: ${item.title} (${item.priceLabel}) from ${item.seller}.',
                          ),
                        ),
                        SizedBox(width: metrics.compact ? 10 : 14),
                        FavoriteButton(store: store, listing: item, size: 44),
                      ],
                    ),
                    SizedBox(height: metrics.compact ? 14 : 22),
                    ProductGallery(
                      item: item,
                      height: metrics.detailImageHeight,
                      width: constraints.maxWidth - metrics.pagePadding * 2,
                      videoPlayerBuilder: videoPlayerBuilder,
                    ),
                    SizedBox(height: metrics.compact ? 14 : 20),
                    ProductDetailPanel(item: item),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      metrics.pagePadding + 10,
                      12,
                      metrics.pagePadding + 10,
                      10 + bottomPadding,
                    ),
                    child: _PrimaryActionButton(
                      key: const ValueKey('product-detail-buy-now'),
                      label: 'Buy Now',
                      icon: Icons.shopping_bag_outlined,
                      height: metrics.compact ? 54 : 60,
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/checkout',
                        arguments: item,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.height,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final compact = height < 56;
    final iconSize = compact ? 18.0 : 20.0;
    final labelSideReserve = iconSize + (compact ? 7.0 : 9.0);

    return LiquidPressable(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      glowColor: AppTheme.red,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.red.withValues(alpha: 0.94), AppTheme.red],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.red.withValues(alpha: 0.34),
              offset: const Offset(0, 10),
              blurRadius: 24,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxLabelWidth =
                      (constraints.maxWidth - 2 * labelSideReserve)
                          .clamp(24.0, constraints.maxWidth)
                          .toDouble();

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxLabelWidth),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: compact ? 16 : 18,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: Icon(icon, color: Colors.white, size: iconSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductGallery extends StatefulWidget {
  const ProductGallery({
    super.key,
    required this.item,
    required this.height,
    required this.width,
    this.videoPlayerBuilder,
  });

  final Listing item;
  final double height;
  final double width;
  final ProductVideoPlayerBuilder? videoPlayerBuilder;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  late final PageController _controller;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void didUpdateWidget(ProductGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    final itemCount = _galleryItemCount(widget.item);
    if (_activeIndex >= itemCount) {
      _activeIndex = 0;
      _controller.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.item.detailImageAssets;
    final videoAsset = widget.item.detailVideoAsset;
    final hasVideo = videoAsset != null;
    final itemCount = _galleryItemCount(widget.item);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            height: widget.height,
            width: widget.width,
            child: PageView.builder(
              key: const ValueKey('product-gallery-page-view'),
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              itemCount: itemCount,
              onPageChanged: (index) => setState(() => _activeIndex = index),
              itemBuilder: (context, index) {
                if (hasVideo && index == 0) {
                  return ProductGalleryVideo(
                    asset: videoAsset,
                    width: widget.width,
                    height: widget.height,
                    active: _activeIndex == index,
                    player: widget.videoPlayerBuilder?.call(videoAsset),
                  );
                }
                final imageIndex = hasVideo ? index - 1 : index;
                return FittedBox(
                  fit: BoxFit.contain,
                  child: ProductImage(
                    asset: images[imageIndex],
                    width: 316,
                    height: 413,
                    heroTag: index == _activeIndex
                        ? listingHeroTag(widget.item)
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: ResponsiveMetrics.of(context).compact ? 8 : 14),
        Center(
          child: Dots(
            count: itemCount,
            activeIndex: _activeIndex,
            keyPrefix: 'product-gallery',
            onSelected: (index) => _controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      ],
    );
  }

  int _galleryItemCount(Listing item) {
    return item.detailImageAssets.length +
        (item.detailVideoAsset == null ? 0 : 1);
  }
}

class ProductGalleryVideo extends StatefulWidget {
  const ProductGalleryVideo({
    super.key,
    required this.asset,
    required this.width,
    required this.height,
    required this.active,
    this.player,
  });

  final String asset;
  final double width;
  final double height;
  final bool active;
  final MultimediaPlayer? player;

  @override
  State<ProductGalleryVideo> createState() => _ProductGalleryVideoState();
}

class _ProductGalleryVideoState extends State<ProductGalleryVideo> {
  late final MultimediaPlayer _player =
      widget.player ?? AssetMultimediaPlayer(widget.asset);
  late final Future<void> _initializeFuture = _player.initialize();

  @override
  void didUpdateWidget(ProductGalleryVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active && _player.isPlaying) {
      _pause();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _pause() async {
    await _player.pause();
    if (mounted) setState(() {});
  }

  Future<void> _togglePlayback() async {
    if (!_player.isInitialized) return;
    if (_player.isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleMuted() async {
    if (!_player.isInitialized) return;
    await _player.setMuted(!_player.isMuted);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: FutureBuilder<void>(
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildFrame(
              context,
              aspectRatio: 16 / 9,
              child: const Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          if (snapshot.hasError || !_player.isInitialized) {
            return _buildFrame(
              context,
              aspectRatio: 16 / 9,
              child: Center(
                child: Text(
                  'Video unavailable',
                  style: AppTheme.body.copyWith(color: Colors.white),
                ),
              ),
            );
          }
          final playing = _player.isPlaying;
          return Semantics(
            button: true,
            label: playing ? 'Pause product video' : 'Play product video',
            child: GestureDetector(
              key: const ValueKey('product-gallery-video-toggle'),
              behavior: HitTestBehavior.opaque,
              onTap: _togglePlayback,
              child: _buildFrame(
                context,
                aspectRatio: _player.aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _player.buildView(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.26),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: AnimatedOpacity(
                        opacity: playing ? 0 : 1,
                        duration: const Duration(milliseconds: 180),
                        child: _VideoControlIcon(
                          icon: Icons.play_arrow_rounded,
                          size: 68,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Semantics(
                        button: true,
                        label: _player.isMuted ? 'Turn sound on' : 'Mute video',
                        child: GestureDetector(
                          key: const ValueKey(
                            'product-gallery-video-sound-toggle',
                          ),
                          behavior: HitTestBehavior.opaque,
                          onTap: _toggleMuted,
                          child: _VideoControlIcon(
                            icon: _player.isMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            size: 42,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrame(
    BuildContext context, {
    required double aspectRatio,
    required Widget child,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var width = constraints.maxWidth;
        var height = width / aspectRatio;
        if (height > constraints.maxHeight) {
          height = constraints.maxHeight;
          width = height * aspectRatio;
        }
        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: ColoredBox(color: AppTheme.ink, child: child),
            ),
          ),
        );
      },
    );
  }
}

class _VideoControlIcon extends StatelessWidget {
  const _VideoControlIcon({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.86),
        border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ink.withValues(alpha: 0.16),
            offset: Offset(0, 10),
            blurRadius: 22,
          ),
        ],
      ),
      child: Icon(icon, color: AppTheme.blue, size: size * 0.52),
    );
  }
}

class ProductDetailPanel extends StatelessWidget {
  const ProductDetailPanel({super.key, required this.item});

  final Listing item;

  @override
  Widget build(BuildContext context) {
    final metrics = ResponsiveMetrics.of(context);
    return GlassCard(
      padding: EdgeInsets.all(metrics.compact ? 18 : 22),
      radius: metrics.cardRadius,
      opacity: 0.42,
      blur: 30,
      borderOpacity: 0.82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('FEATURED', style: AppTheme.label),
              const Spacer(),
              Text(
                item.priceLabel,
                style: AppTheme.label.copyWith(
                  color: AppTheme.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: metrics.compact ? 14 : 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: AppTheme.h1.copyWith(
                      fontSize: metrics.compact ? 22 : 25,
                      height: 1.08,
                    ),
                    children: [
                      TextSpan(text: '${item.title}\n'),
                      TextSpan(
                        text: item.subtitle,
                        style: TextStyle(color: AppTheme.red),
                      ),
                      accentSquare(size: 8),
                    ],
                  ),
                ),
              ),
              SizedBox(width: metrics.gutter),
              CircleGlassButton(
                icon: Icons.shopping_cart_outlined,
                color: AppTheme.blue,
                size: metrics.compact ? 42 : 46,
                onTap: () =>
                    Navigator.pushNamed(context, '/checkout', arguments: item),
              ),
            ],
          ),
          SizedBox(height: metrics.compact ? 14 : 18),
          Text(
            item.description,
            style: AppTheme.body.copyWith(fontSize: 12, height: 1.5),
          ),
          SizedBox(height: metrics.compact ? 16 : 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 360 ? 2 : 4;
              const spacing = 10.0;
              final chipWidth =
                  (constraints.maxWidth - (columns - 1) * spacing) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: chipWidth,
                    child: SpecChip(
                      Icons.sd_storage_rounded,
                      item.storage,
                      'Storage',
                    ),
                  ),
                  SizedBox(
                    width: chipWidth,
                    child: SpecChip(
                      Icons.battery_full_rounded,
                      item.battery,
                      'Battery Life',
                    ),
                  ),
                  SizedBox(
                    width: chipWidth,
                    child: SpecChip(
                      Icons.grade_rounded,
                      item.condition.replaceAll('\n', ' - '),
                      'Condition',
                    ),
                  ),
                  SizedBox(
                    width: chipWidth,
                    child: SpecChip(
                      Icons.settings_input_component_rounded,
                      item.connector,
                      'Connector',
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: metrics.compact ? 18 : 22),
          Divider(height: 1, color: AppTheme.line),
          SizedBox(height: metrics.compact ? 16 : 18),
          Text('Seller', style: AppTheme.h2.copyWith(fontSize: 15)),
          SizedBox(height: metrics.compact ? 10 : 12),
          Row(
            children: [
              LogoMark(size: 43, heroTag: sellerLogoHeroTag),
              SizedBox(width: metrics.gutter),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.seller,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.h2.copyWith(fontSize: 14),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${item.rating} ★  (${item.reviews})',
                      style: AppTheme.label.copyWith(fontSize: 13),
                    ),
                    Text(
                      'Active today',
                      style: AppTheme.body.copyWith(fontSize: 11, height: 1.1),
                    ),
                  ],
                ),
              ),
              SizedBox(width: metrics.gutter),
              CircleGlassButton(
                key: const ValueKey('product-detail-contact-seller'),
                icon: Icons.chat_bubble_outline_rounded,
                size: 42,
                color: AppTheme.blue,
                onTap: () =>
                    Navigator.pushNamed(context, '/chat', arguments: item),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Dots extends StatelessWidget {
  const Dots({
    super.key,
    this.count = 4,
    this.activeIndex = 0,
    this.onSelected,
    this.keyPrefix,
  });

  final int count;
  final int activeIndex;
  final ValueChanged<int>? onSelected;
  final String? keyPrefix;

  @override
  Widget build(BuildContext context) {
    var dragOffset = 0.0;

    void resetDrag() => dragOffset = 0;

    void trackDrag(DragUpdateDetails details) {
      dragOffset += details.primaryDelta ?? 0;
    }

    void selectByDragEnd(DragEndDetails details) {
      if (onSelected == null || count < 2) return;
      final velocity = details.primaryVelocity ?? 0;
      final movement = dragOffset.abs() >= 12 ? dragOffset : -velocity;
      resetDrag();
      if (movement.abs() < 12) return;
      final direction = movement < 0 ? 1 : -1;
      final nextIndex = (activeIndex + direction).clamp(0, count - 1);
      if (nextIndex != activeIndex) onSelected!(nextIndex);
    }

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final active = index == activeIndex;
        final indicator = AnimatedContainer(
          key: keyPrefix == null ? null : ValueKey('$keyPrefix-dot-$index'),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: active ? 20 : 8,
          height: 5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: active ? AppTheme.red : AppTheme.line,
          ),
        );
        if (onSelected == null) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: indicator,
          );
        }
        return Semantics(
          button: true,
          selected: active,
          label: 'Show product image ${index + 1}',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected!(index),
            onHorizontalDragStart: (_) => resetDrag(),
            onHorizontalDragUpdate: trackDrag,
            onHorizontalDragEnd: selectByDragEnd,
            child: SizedBox(
              width: 28,
              height: 22,
              child: Center(child: indicator),
            ),
          ),
        );
      }),
    );
    if (onSelected == null || count < 2) return row;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => resetDrag(),
      onHorizontalDragUpdate: trackDrag,
      onHorizontalDragEnd: selectByDragEnd,
      child: row,
    );
  }
}

class SpecChip extends StatelessWidget {
  const SpecChip(this.icon, this.value, this.label, {super.key});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: GlassCard(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        radius: 16,
        opacity: 0.5,
        blur: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: AppTheme.ink),
            SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: AppTheme.body.copyWith(fontSize: 8, height: 1.1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
