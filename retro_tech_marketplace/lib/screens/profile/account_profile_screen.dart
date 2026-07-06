import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../store/listing_store.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/liquid_button.dart';
import '../../widgets/logo_mark.dart';
import '../../widgets/navigation.dart';
import '../checkout/delivery_address_screen.dart';
import '../checkout/order_confirmation_screen.dart';
import '../product/my_listings_screen.dart';
import '../settings/settings_screen.dart';
import 'edit_profile_screen.dart';
import 'saved_items_screen.dart';

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({super.key, required this.store});

  final ListingStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final metrics = ResponsiveMetrics.of(context);
        final profile = store.profile;
        return ListView(
          padding: metrics.pageInsetsWithNav,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: OpenMotionContainer(
                radius: 23,
                openPage: SettingsScreen(store: store),
                routeSettings: const RouteSettings(name: '/settings'),
                closedBuilder: (openContainer) => CircleGlassButton(
                  icon: Icons.settings_rounded,
                  onTap: openContainer,
                ),
              ),
            ),
            SizedBox(height: 2),
            Center(child: LogoMark(size: 94, heroTag: accountLogoHeroTag)),
            SizedBox(height: 12),
            Center(
              child: Text(
                profile.displayName,
                style: AppTheme.h1.copyWith(fontSize: 26),
              ),
            ),
            Center(
              child: Text(
                profile.username,
                style: AppTheme.body.copyWith(fontSize: 14),
              ),
            ),
            SizedBox(height: 4),
            Center(
              child: Text(
                store.privacy ? 'Private local profile' : profile.bio,
                style: AppTheme.body,
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: OpenMotionContainer(
                radius: 18,
                openPage: EditProfileScreen(store: store),
                routeSettings: const RouteSettings(name: '/edit-profile'),
                closedBuilder: (openContainer) => TextButton(
                  onPressed: openContainer,
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(112, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: AppTheme.label.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Marketplace Dashboard',
              style: AppTheme.h2.copyWith(fontSize: 16),
            ),
            SizedBox(height: 10),
            GlassListSection(
              children: [
                ProfileRow(
                  'My Listings',
                  Icons.sell_outlined,
                  null,
                  openPage: MyListingsScreen(store: store),
                  routeSettings: const RouteSettings(name: '/my-listings'),
                ),
                ProfileRow(
                  'Orders',
                  Icons.inventory_2_outlined,
                  null,
                  openPage: OrdersScreen(store: store),
                  routeSettings: const RouteSettings(name: '/orders'),
                ),
                ProfileRow(
                  'Delivery Address',
                  Icons.location_on_outlined,
                  null,
                  openPage: DeliveryAddressScreen(store: store),
                  routeSettings: const RouteSettings(name: '/delivery-address'),
                ),
                ProfileRow(
                  'Saved Items',
                  Icons.favorite_border_rounded,
                  null,
                  openPage: SavedItemsScreen(store: store),
                  routeSettings: const RouteSettings(name: '/saved-items'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class ProfileRow extends StatelessWidget {
  const ProfileRow(
    this.title,
    this.icon,
    this.onTap, {
    super.key,
    this.openPage,
    this.routeSettings,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? openPage;
  final RouteSettings? routeSettings;

  @override
  Widget build(BuildContext context) {
    final page = openPage;
    if (page != null) {
      return OpenMotionListRow(
        icon: icon,
        title: title,
        dense: true,
        openPage: page,
        routeSettings: routeSettings,
      );
    }
    return GlassListRow(icon: icon, title: title, onTap: onTap, dense: true);
  }
}

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    super.key,
    required this.user,
    required this.time,
    required this.text,
    required this.asset,
    this.handle,
    this.likes,
    this.replies,
    this.liked = false,
    this.reposted = false,
    this.sourceLabel,
    this.onReply,
    this.onLike,
    this.onRepost,
    this.onTap,
  });

  final String user;
  final String time;
  final String text;
  final String asset;
  final String? handle;
  final int? likes;
  final int? replies;
  final bool liked;
  final bool reposted;
  final String? sourceLabel;
  final VoidCallback? onReply;
  final VoidCallback? onLike;
  final VoidCallback? onRepost;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final metrics = ResponsiveMetrics.of(context);
    final compact = metrics.compact;
    final replyLabel = replies == null ? null : '${replies!}';
    final likeLabel = likes == null ? null : '${likes!}';

    return GlassCard(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.fromLTRB(14, 14, 14, 12),
      radius: 26,
      opacity: 0.48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: ProductImage(
              asset: asset,
              width: compact ? 40 : 44,
              height: compact ? 40 : 44,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sourceLabel != null) ...[
                  Text(
                    sourceLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.label.copyWith(color: AppTheme.muted),
                  ),
                  SizedBox(height: 5),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 7,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            user,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          if (handle != null)
                            Text(
                              handle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.body.copyWith(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(time, style: AppTheme.body.copyWith(fontSize: 11)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  text,
                  style: AppTheme.body.copyWith(
                    color: AppTheme.ink,
                    fontSize: 14.5,
                    height: 1.34,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    _CommunityCardAction(
                      Icons.chat_bubble_outline_rounded,
                      key: ValueKey('community-card-reply-$user'),
                      label: replyLabel,
                      color: AppTheme.blue,
                      onTap: onReply,
                    ),
                    SizedBox(width: 16),
                    _CommunityCardAction(
                      liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey('community-card-like-$user'),
                      label: likeLabel,
                      color: AppTheme.red,
                      active: liked,
                      onTap: onLike,
                    ),
                    SizedBox(width: 16),
                    _CommunityCardAction(
                      Icons.repeat_rounded,
                      key: ValueKey('community-card-repost-$user'),
                      label: null,
                      color: reposted ? AppTheme.blue : AppTheme.muted,
                      active: reposted,
                      onTap: onRepost,
                    ),
                    const Spacer(),
                    _CommunityCardAction(
                      Icons.chevron_right_rounded,
                      key: ValueKey('community-card-open-$user'),
                      label: null,
                      color: AppTheme.muted,
                      onTap: onTap,
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

class _CommunityCardAction extends StatelessWidget {
  const _CommunityCardAction(
    this.icon, {
    super.key,
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
            Icon(icon, color: color, size: 17),
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
