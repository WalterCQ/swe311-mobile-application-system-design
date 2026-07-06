import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/theme.dart';

const maxGlassBlur = 0.0;

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 30,
    this.opacity = 0.54,
    this.blur = 24,
    this.borderOpacity = 0.72,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double opacity;
  final double blur;
  final double borderOpacity;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final glassBlur = blur.clamp(0.0, maxGlassBlur).toDouble();
    final glassSheen = opacity.clamp(0.08, 0.22).toDouble();
    final glassFillOpacity = opacity.clamp(0.16, 0.58).toDouble();
    final glassBorderOpacity = borderOpacity.clamp(0.86, 0.96).toDouble();
    final glassContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.white.withValues(alpha: glassFillOpacity),
        border: Border.all(
          color: Colors.white.withValues(alpha: glassBorderOpacity),
          width: 1.1,
        ),
      ),
      child: Material(type: MaterialType.transparency, child: child),
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: glassSheen * 1.55),
            offset: Offset(-2, -2),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Color(0xFF1A2942).withValues(alpha: 0.1),
            offset: Offset(0, 18),
            blurRadius: 28,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: glassBlur == 0
            ? glassContent
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
                child: glassContent,
              ),
      ),
    );
  }
}

class ResponsiveMetrics {
  const ResponsiveMetrics({
    required this.width,
    required this.height,
    required this.pagePadding,
    required this.topGap,
    required this.gutter,
    required this.bottomNavHeight,
    required this.bottomSafeInset,
    required this.cardRadius,
  });

  final double width;
  final double height;
  final double pagePadding;
  final double topGap;
  final double gutter;
  final double bottomNavHeight;
  final double bottomSafeInset;
  final double cardRadius;

  factory ResponsiveMetrics.of(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final bottomSafeInset = MediaQuery.viewPaddingOf(context).bottom;
    final shellWidth = mediaSize.width > 480 ? 440.0 : mediaSize.width;
    final compactWidth = shellWidth < 360;
    final compactHeight = mediaSize.height < 740;
    final compact = compactWidth || compactHeight;
    return ResponsiveMetrics(
      width: shellWidth,
      height: mediaSize.height,
      pagePadding: compactWidth ? 16 : 22,
      topGap: compactHeight ? 12 : 18,
      gutter: compactWidth ? 12 : 16,
      bottomNavHeight: compact ? 74 : 82,
      bottomSafeInset: bottomSafeInset,
      cardRadius: compact ? 24 : 30,
    );
  }

  bool get compact => width < 360 || height < 740;

  EdgeInsets get pageInsets =>
      EdgeInsets.fromLTRB(pagePadding, topGap, pagePadding, 28);

  EdgeInsets get pageInsetsWithNav => EdgeInsets.fromLTRB(
    pagePadding,
    topGap,
    pagePadding,
    bottomNavHeight + bottomSafeInset + 48,
  );

  double get homeCardHeight =>
      (height * (compact ? 0.255 : 0.25)).clamp(176.0, 218.0).toDouble();

  double get listingActionCardHeight =>
      (height * 0.225).clamp(170.0, 198.0).toDouble();

  double get detailImageHeight =>
      (height * (compact ? 0.34 : 0.39)).clamp(230.0, 350.0).toDouble();

  int get categoryColumns => width >= 440 ? 3 : 2;

  double get categoryCardAspectRatio => categoryColumns >= 3 ? 0.86 : 0.9;

  double scaled(double value, {double min = 0, double? max}) {
    final scaledValue = value * (width / 390);
    return scaledValue.clamp(min, max ?? value * 1.12).toDouble();
  }
}

class GlassStatCard extends StatelessWidget {
  const GlassStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color = AppTheme.blue,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(vertical: 9),
      radius: 20,
      child: Column(
        children: [
          Icon(icon, color: color, size: 17),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.ink),
          ),
          Text(label, style: AppTheme.body.copyWith(fontSize: 9)),
        ],
      ),
    );
  }
}

class GlassListSection extends StatelessWidget {
  const GlassListSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class GlassListRow extends StatelessWidget {
  const GlassListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.badge,
    this.onTap,
    this.iconColor = AppTheme.blue,
    this.badgeColor = AppTheme.blue,
    this.dense = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final String? badge;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color badgeColor;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        dense: dense,
        minVerticalPadding: dense ? 4 : null,
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w800)),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: AppTheme.body.copyWith(fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            else if (value != null)
              Text(value!, style: AppTheme.body.copyWith(fontSize: 12)),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  const ProfileStat(
    this.value,
    this.label,
    this.icon, {
    super.key,
    this.color = AppTheme.blue,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassStatCard(
        value: value,
        label: label,
        icon: icon,
        color: color,
      ),
    );
  }
}
