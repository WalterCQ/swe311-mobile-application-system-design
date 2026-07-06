import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../services/update_service.dart';
import '../../store/listing_store.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/logo_mark.dart';
import '../../widgets/navigation.dart';
import '../../widgets/update_prompt.dart';
import 'help_support_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.store});

  final ListingStore store;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool checkingUpdates = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final profile = widget.store.profile;
        return GlassScaffold(
          child: ListView(
            padding: EdgeInsets.fromLTRB(22, 18, 22, 32),
            children: [
              TopBar(
                title: 'Settings',
                trailing: Icons.info_outline_rounded,
                onTrailingTap: () => Navigator.pushNamed(context, '/about'),
              ),
              SizedBox(height: 22),
              GlassCard(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [
                    LogoMark(size: 58, heroTag: accountLogoHeroTag),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style: AppTheme.h2.copyWith(fontSize: 16),
                          ),
                          Text(
                            profile.username,
                            style: AppTheme.body.copyWith(fontSize: 12),
                          ),
                          Text(
                            'Profile, local demo settings, and app updates',
                            style: AppTheme.body.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              GlassListSection(
                children: [
                  _SettingsSwitch(
                    Icons.notifications_outlined,
                    'Notifications',
                    'One-minute launch test notification only',
                    widget.store.notifications,
                    (value) {
                      widget.store.setNotifications(value);
                    },
                  ),
                  _SettingsSwitch(
                    Icons.lock_outline_rounded,
                    'Privacy',
                    'Hide saved item count on your profile',
                    widget.store.privacy,
                    (value) {
                      widget.store.setPrivacy(value);
                    },
                  ),
                  _SettingsRow(
                    Icons.shield_outlined,
                    'Help Center',
                    subtitle: 'Selling, payments, safety, and order support',
                    openPage: const HelpSupportScreen(),
                    routeSettings: const RouteSettings(name: '/help'),
                  ),
                  _SettingsRow(
                    Icons.system_update_alt_rounded,
                    'App Update',
                    subtitle: 'Check GitHub Releases for the latest APK',
                    value: checkingUpdates
                        ? 'Checking...'
                        : 'v${UpdateService.fallbackVersion}',
                    onTap: _checkForUpdates,
                  ),
                ],
              ),
              SizedBox(height: 28),
              GlassCard(
                radius: 24,
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(Icons.logout_rounded, color: AppTheme.red),
                  title: Text(
                    'Log Out',
                    style: TextStyle(
                      color: AppTheme.red,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onTap: () async {
                    await widget.store.signOut();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkForUpdates() async {
    if (checkingUpdates) return;
    setState(() => checkingUpdates = true);
    await checkForAppUpdate(
      context,
      service: const UpdateService(),
      userInitiated: true,
    );
    if (!mounted) return;
    setState(() => checkingUpdates = false);
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow(
    this.icon,
    this.label, {
    this.subtitle,
    this.value,
    this.openPage,
    this.routeSettings,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? value;
  final Widget? openPage;
  final RouteSettings? routeSettings;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final page = openPage;
    if (page != null) {
      return OpenMotionListRow(
        icon: icon,
        title: label,
        subtitle: subtitle,
        value: value,
        openPage: page,
        routeSettings: routeSettings,
      );
    }
    return GlassListRow(
      icon: icon,
      title: label,
      subtitle: subtitle,
      value: value,
      onTap: onTap,
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch(
    this.icon,
    this.label,
    this.subtitle,
    this.value,
    this.onChanged,
  );

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.blue,
      secondary: Icon(icon, color: AppTheme.blue),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle, style: AppTheme.body.copyWith(fontSize: 11)),
    );
  }
}
