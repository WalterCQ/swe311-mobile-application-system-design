import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/assets.dart';
import '../../store/listing_store.dart';
import '../../store/seed_data.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/image_cache.dart';
import '../../widgets/interaction_helpers.dart';
import '../../widgets/liquid_button.dart';
import '../../widgets/logo_mark.dart';
import '../../widgets/navigation.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, this.store});

  final ListingStore? store;

  @override
  Widget build(BuildContext context) {
    final metrics = ResponsiveMetrics.of(context);
    final listings = store?.listings ?? seedListings;
    final listingCount = listings.length;
    final sellerCount = listings
        .map((listing) => listing.seller)
        .toSet()
        .length;
    final orderCount = store?.orders.length ?? 0;
    final followCount = store?.followedSellerCount ?? 0;
    return GlassScaffold(
      includeSafeArea: false,
      background: const AboutBackground(),
      child: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            metrics.pagePadding,
            metrics.topGap,
            metrics.pagePadding,
            30 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          children: [
            Row(
              children: [
                AboutIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => popOrMain(context),
                ),
                const Spacer(),
                AboutIconButton(
                  icon: Icons.ios_share_rounded,
                  onTap: () => copyShareText(
                    context,
                    label: 'About RetroTech',
                    text:
                        'RetroTech is a marketplace and collector community for Y2K electronics.',
                  ),
                ),
              ],
            ),
            SizedBox(height: metrics.compact ? 28 : 42),
            AboutHeroCopy(compact: metrics.compact),
            SizedBox(height: metrics.compact ? 30 : 42),
            Row(
              children: const [
                SmallDash(aboutRed),
                SizedBox(width: 10),
                SmallDash(aboutBlue),
              ],
            ),
            SizedBox(height: metrics.compact ? 28 : 38),
            Text.rich(
              TextSpan(
                style: AboutText.body,
                children: [
                  TextSpan(
                    text: 'RetroTech',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        ' connects collectors with verified sellers, practical tools, and transparent product details for ',
                  ),
                  TextSpan(
                    text: 'Y2K',
                    style: TextStyle(
                      color: aboutRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: ' electronics. From '),
                  TextSpan(
                    text: 'classic',
                    style: TextStyle(
                      color: aboutBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' devices, rare finds, and restored gear that deserve a reliable second life.',
                  ),
                ],
              ),
            ),
            SizedBox(height: metrics.compact ? 28 : 42),
            Row(
              children: [
                AboutIconButton(
                  icon: Icons.arrow_forward_rounded,
                  color: aboutRed,
                  size: 42,
                  iconSize: 22,
                  onTap: () => showInfoSheet(
                    context,
                    icon: Icons.flag_outlined,
                    title: 'Our mission',
                    body:
                        'RetroTech makes it easier to discover, verify, and preserve iconic electronics through trusted listings, safer messaging, and a collector-first community.',
                  ),
                ),
                SizedBox(width: metrics.gutter),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Learn more about our ',
                          style: AboutText.ctaCopy,
                        ),
                        TextSpan(text: 'mission', style: AboutText.ctaLink),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: metrics.compact ? 32 : 44),
            Text('WHAT WE STAND FOR', style: AboutText.section),
            SizedBox(height: metrics.gutter),
            LayoutBuilder(
              builder: (context, constraints) {
                final gap = metrics.compact ? 8.0 : 10.0;
                final cardWidth = ((constraints.maxWidth - gap * 2) / 3)
                    .clamp(86.0, 132.0)
                    .toDouble();
                return Row(
                  children: [
                    ValueCard(
                      Icons.favorite_rounded,
                      'Trust & Safety',
                      'Verified sellers\nand clearer\ntransactions.',
                      aboutRed,
                      width: cardWidth,
                      iconSize: 18,
                      onTap: () => showInfoSheet(
                        context,
                        icon: Icons.favorite_rounded,
                        title: 'Trust & Safety',
                        body:
                            'RetroTech surfaces seller reputation, payment context, and clear listing details so buyers can make safer decisions.',
                      ),
                    ),
                    SizedBox(width: gap),
                    ValueCard(
                      Icons.groups_rounded,
                      'Community First',
                      'Collectors share\nfinds, repairs,\nand advice.',
                      aboutBlue,
                      width: cardWidth,
                      iconSize: 16,
                      onTap: () => showInfoSheet(
                        context,
                        icon: Icons.groups_rounded,
                        title: 'Community First',
                        body:
                            'The community space is built for collectors to discuss finds, restorations, buying tips, and product history.',
                      ),
                    ),
                    SizedBox(width: gap),
                    ValueCard(
                      Icons.eco_rounded,
                      'Sustainability',
                      'Vintage tech\ngets a useful\nsecond life.',
                      aboutGreen,
                      width: cardWidth,
                      iconSize: 16,
                      onTap: () => showInfoSheet(
                        context,
                        icon: Icons.eco_rounded,
                        title: 'Sustainability',
                        body:
                            'Buying and restoring older electronics keeps usable devices in circulation and reduces unnecessary waste.',
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: metrics.compact ? 32 : 44),
            Text('BY THE NUMBERS', style: AboutText.section),
            SizedBox(height: metrics.gutter),
            LayoutBuilder(
              builder: (context, constraints) {
                final gap = metrics.compact ? 6.0 : 8.0;
                final numberWidth = ((constraints.maxWidth - gap * 3) / 4)
                    .clamp(64.0, 90.0)
                    .toDouble();
                return Row(
                  children: [
                    Number(
                      '$listingCount',
                      'Listings',
                      aboutRed,
                      width: numberWidth,
                    ),
                    SizedBox(width: gap),
                    Number(
                      '$sellerCount',
                      'Sellers',
                      aboutBlue,
                      width: numberWidth,
                    ),
                    SizedBox(width: gap),
                    Number(
                      '$orderCount',
                      'Orders',
                      aboutGreen,
                      width: numberWidth,
                    ),
                    SizedBox(width: gap),
                    Number(
                      '$followCount',
                      'Follows',
                      aboutViolet,
                      width: numberWidth,
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: metrics.compact ? 28 : 36),
            AboutNewsCard(
              onTap: () => showInfoSheet(
                context,
                icon: Icons.newspaper_rounded,
                title: 'Transparent Tech Drop',
                body:
                    'A new batch of clear-shell phones, players, and accessories is featured for collectors.',
                actionLabel: 'Explore Collection',
                onAction: () => Navigator.pushNamed(
                  context,
                  '/category',
                  arguments: 'Phones',
                ),
              ),
            ),
            SizedBox(height: metrics.compact ? 18 : 22),
            const HeadquartersMapCard(),
          ],
        ),
      ),
    );
  }
}

class AboutHeroCopy extends StatelessWidget {
  const AboutHeroCopy({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final heroStyle = AboutText.hero.copyWith(fontSize: compact ? 26 : 28);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ABOUT RETROTECH', style: AboutText.eyebrow),
        SizedBox(height: compact ? 18 : 22),
        Text('Retro gear,', style: heroStyle),
        RichText(
          text: TextSpan(
            style: heroStyle,
            children: [
              TextSpan(text: 'trusted '),
              TextSpan(
                text: 'again',
                style: TextStyle(color: aboutRed),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: SizedBox(
                    width: 8,
                    height: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: aboutRed),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 16 : 20),
        Text(
          'A marketplace and community for buying, selling, and preserving Y2K electronics.',
          style: AboutText.subcopy.copyWith(fontSize: compact ? 16 : 17),
        ),
      ],
    );
  }
}

const aboutInk = Color(0xFF080A0F);
const aboutMuted = Color(0xFF5C637A);
const aboutEyebrow = Color(0xFF4791DB);
const aboutBlue = Color(0xFF0573FF);
const aboutRed = Color(0xFFFF080F);
const aboutGreen = Color(0xFF0DB238);
const aboutViolet = Color(0xFF7338F2);
const _headquartersLocation = LatLng(2.8306875, 101.7024375);
const _headquartersZoom = 16.0;

class AboutText {
  static const baseFont = 'Inter';

  static const eyebrow = TextStyle(
    fontFamily: baseFont,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: aboutEyebrow,
  );

  static const hero = TextStyle(
    fontFamily: baseFont,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: aboutInk,
  );

  static const subcopy = TextStyle(
    fontFamily: baseFont,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: aboutMuted,
  );

  static const body = TextStyle(
    fontFamily: baseFont,
    fontSize: 17,
    height: 25 / 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: aboutInk,
  );

  static const ctaCopy = TextStyle(
    fontFamily: baseFont,
    fontSize: 12,
    height: 15 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: aboutMuted,
  );

  static const ctaLink = TextStyle(
    fontFamily: baseFont,
    fontSize: 12,
    height: 15 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: aboutBlue,
  );

  static const section = TextStyle(
    fontFamily: baseFont,
    fontSize: 10,
    height: 13 / 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: aboutEyebrow,
  );

  static const valueTitle = TextStyle(
    fontFamily: baseFont,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const valueCopy = TextStyle(
    fontFamily: baseFont,
    fontSize: 9,
    height: 12 / 9,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: aboutMuted,
  );

  static const metric = TextStyle(
    fontFamily: baseFont,
    fontSize: 22,
    height: 26 / 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const metricLabel = TextStyle(
    fontFamily: baseFont,
    fontSize: 9,
    height: 11 / 9,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: aboutMuted,
  );

  static const newsEyebrow = TextStyle(
    fontFamily: baseFont,
    fontSize: 9,
    height: 11 / 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: aboutBlue,
  );

  static const newsTitle = TextStyle(
    fontFamily: baseFont,
    fontSize: 11,
    height: 13 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: aboutInk,
  );

  static const newsCopy = TextStyle(
    fontFamily: baseFont,
    fontSize: 9,
    height: 11 / 9,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: aboutMuted,
  );
}

class AboutBackground extends StatelessWidget {
  const AboutBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wingWidth = (constraints.maxWidth * 0.68)
              .clamp(210.0, 296.0)
              .toDouble();
          final wingHeight = wingWidth * 225 / 277;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                Assets.background,
                fit: BoxFit.cover,
                alignment: Alignment.topLeft,
                filterQuality: FilterQuality.high,
                cacheWidth: imageCacheDimension(
                  context,
                  constraints.maxWidth,
                  logicalHeight: constraints.maxHeight,
                ),
              ),
              Positioned(
                top: constraints.maxHeight < 740 ? 64 : 78,
                right: -wingWidth * 0.16,
                width: wingWidth,
                height: wingHeight,
                child: Opacity(
                  opacity: 0.92,
                  child: Transform.rotate(
                    angle: 0.06981317007977318,
                    child: Image.asset(
                      Assets.glassButterfly,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      cacheWidth: imageCacheDimension(
                        context,
                        wingWidth,
                        logicalHeight: wingHeight,
                        overscan: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AboutGlassSurface extends StatelessWidget {
  const AboutGlassSurface({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    required this.radius,
    this.opacity = 0.66,
  });

  final Widget child;
  final double width;
  final double height;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final glassSheen = opacity.clamp(0.08, 0.22).toDouble();
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: glassSheen * 1.45),
            offset: Offset(-2, -2),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Color(0xFF1A2942).withValues(alpha: 0.1),
            offset: Offset(0, 16),
            blurRadius: 24,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: maxGlassBlur, sigmaY: maxGlassBlur),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.94),
                width: 1.1,
              ),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AboutIconButton extends StatelessWidget {
  const AboutIconButton({
    super.key,
    required this.icon,
    this.color = aboutInk,
    this.onTap,
    this.size = 44,
    this.iconSize,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: LiquidPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        glowColor: color,
        child: AboutGlassSurface(
          width: size,
          height: size,
          radius: size / 2,
          child: Icon(icon, color: color, size: iconSize ?? size * 0.54),
        ),
      ),
    );
  }
}

class SmallDash extends StatelessWidget {
  const SmallDash(this.color, {super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class ValueCard extends StatelessWidget {
  const ValueCard(
    this.icon,
    this.title,
    this.text,
    this.color, {
    super.key,
    required this.width,
    required this.iconSize,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;
  final double width;
  final double iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scale = (width / 116).clamp(0.86, 1.08).toDouble();
    final height = (112 * scale).clamp(96.0, 120.0).toDouble();
    return LiquidPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      glowColor: color,
      child: AboutGlassSurface(
        width: width,
        height: height,
        radius: 18 * (width / 116).clamp(0.82, 1),
        opacity: 0.52,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 7 * scale,
            vertical: 7 * scale,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AboutGlassSurface(
                width: 34 * scale,
                height: 34 * scale,
                radius: 17 * scale,
                child: Icon(icon, color: color, size: iconSize * scale),
              ),
              SizedBox(height: 5 * scale),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: AboutText.valueTitle.copyWith(color: color),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 3 * scale),
              Text(
                text,
                style: AboutText.valueCopy,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Number extends StatelessWidget {
  const Number(
    this.value,
    this.label,
    this.color, {
    super.key,
    required this.width,
  });

  final String value;
  final String label;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AboutText.metric.copyWith(color: color)),
          ),
          SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AboutText.metricLabel,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class AboutNewsCard extends StatelessWidget {
  const AboutNewsCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        return LiquidPressable(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          glowColor: aboutRed,
          child: AboutGlassSurface(
            width: constraints.maxWidth,
            height: compact ? 78 : 64,
            radius: 30,
            opacity: 0.58,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(31),
                  child: Image.asset(
                    Assets.latestNewsThumbnail,
                    width: compact ? 76 : 93,
                    height: compact ? 78 : 64,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    cacheWidth: imageCacheDimension(context, compact ? 76 : 93),
                    errorBuilder: (context, error, stackTrace) => ProductImage(
                      asset: Assets.gameboy,
                      width: compact ? 76 : 93,
                      height: compact ? 78 : 64,
                    ),
                  ),
                ),
                SizedBox(width: compact ? 12 : 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LATEST NEWS', style: AboutText.newsEyebrow),
                      SizedBox(height: compact ? 3 : 4),
                      Text(
                        'Transparent Tech Drop',
                        style: AboutText.newsTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: compact ? 2 : 3),
                      Text(
                        'Clear-shell devices curated for collectors',
                        style: AboutText.newsCopy,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: compact ? 8 : 12),
                  child: AboutIconButton(
                    icon: Icons.arrow_forward_rounded,
                    color: aboutRed,
                    size: 38,
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HeadquartersMapCard extends StatefulWidget {
  const HeadquartersMapCard({super.key});

  @override
  State<HeadquartersMapCard> createState() => _HeadquartersMapCardState();
}

class _HeadquartersMapCardState extends State<HeadquartersMapCard> {
  late final MapController _mapController = MapController();

  void _centerOnHeadquarters() {
    _mapController.move(
      _headquartersLocation,
      _headquartersZoom,
      id: 'headquarters-recenter',
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        final mapHeight = compact ? 260.0 : 280.0;
        return AboutGlassSurface(
          width: constraints.maxWidth,
          height: compact ? 368 : 392,
          radius: 30,
          opacity: 0.58,
          child: Padding(
            padding: EdgeInsets.all(compact ? 10 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeadquartersMapPreview(
                  height: mapHeight,
                  mapController: _mapController,
                ),
                SizedBox(height: compact ? 10 : 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AboutGlassSurface(
                      width: 38,
                      height: 38,
                      radius: 19,
                      opacity: 0.52,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: aboutRed,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: compact ? 10 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RETROTECH HUB',
                            style: AboutText.newsEyebrow.copyWith(
                              color: aboutBlue,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Demo Headquarters',
                            style: AboutText.newsTitle.copyWith(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Sepang, Selangor, Malaysia',
                            style: AboutText.newsCopy.copyWith(fontSize: 10),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Map data: OpenStreetMap contributors',
                            style: AboutText.metricLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: compact ? 8 : 10),
                    Tooltip(
                      message: 'Center on headquarters',
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: LiquidPressable(
                          onTap: _centerOnHeadquarters,
                          borderRadius: BorderRadius.circular(21),
                          glowColor: aboutRed,
                          child: AboutGlassSurface(
                            width: 42,
                            height: 42,
                            radius: 21,
                            opacity: 0.52,
                            child: Icon(
                              Icons.center_focus_strong_rounded,
                              color: aboutRed,
                              size: 21,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HeadquartersMapPreview extends StatefulWidget {
  const HeadquartersMapPreview({
    super.key,
    required this.height,
    required this.mapController,
  });

  final double height;
  final MapController mapController;

  @override
  State<HeadquartersMapPreview> createState() => _HeadquartersMapPreviewState();
}

class _HeadquartersMapPreviewState extends State<HeadquartersMapPreview> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: FlutterMap(
          mapController: widget.mapController,
          options: const MapOptions(
            initialCenter: _headquartersLocation,
            initialZoom: _headquartersZoom,
            minZoom: 13,
            maxZoom: 18,
            interactionOptions: InteractionOptions(
              flags:
                  InteractiveFlag.drag |
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.doubleTapZoom |
                  InteractiveFlag.scrollWheelZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'RetroTechMarketplace/1.1.2',
              maxNativeZoom: 19,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _headquartersLocation,
                  width: 46,
                  height: 46,
                  alignment: Alignment.bottomCenter,
                  child: Icon(
                    Icons.location_pin,
                    color: aboutRed,
                    size: 42,
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.92),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
