import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

enum DemoAuthProvider { local, google, apple, facebook }

extension DemoAuthProviderDetails on DemoAuthProvider {
  String get label {
    switch (this) {
      case DemoAuthProvider.local:
        return 'Local';
      case DemoAuthProvider.google:
        return 'Google';
      case DemoAuthProvider.apple:
        return 'Apple';
      case DemoAuthProvider.facebook:
        return 'Facebook';
    }
  }

  String get storageValue => name;

  UserProfile get profile {
    switch (this) {
      case DemoAuthProvider.local:
        return DemoAuthService.defaultLocalProfile;
      case DemoAuthProvider.google:
        return const UserProfile(
          displayName: 'Google Demo Collector',
          username: '@google_collector',
          email: 'google.collector@retrotech.demo',
          bio: 'Signed in with Google demo auth.',
          location: 'Kuala Lumpur',
          sellerName: 'Google Demo Collector',
          preferredContact: 'Google demo account',
        );
      case DemoAuthProvider.apple:
        return const UserProfile(
          displayName: 'Apple Demo Collector',
          username: '@apple_collector',
          email: 'apple.collector@retrotech.demo',
          bio: 'Signed in with Apple demo auth.',
          location: 'Kuala Lumpur',
          sellerName: 'Apple Demo Collector',
          preferredContact: 'Apple demo account',
        );
      case DemoAuthProvider.facebook:
        return const UserProfile(
          displayName: 'Facebook Demo Collector',
          username: '@facebook_collector',
          email: 'facebook.collector@retrotech.demo',
          bio: 'Signed in with Facebook demo auth.',
          location: 'Kuala Lumpur',
          sellerName: 'Facebook Demo Collector',
          preferredContact: 'Facebook demo account',
        );
    }
  }
}

class LocalAuthAccount {
  const LocalAuthAccount({
    required this.username,
    required this.email,
    required this.password,
    required this.profile,
  });

  final String username;
  final String email;
  final String password;
  final UserProfile profile;

  bool matches(String identifier, String candidatePassword) {
    final normalized = identifier.trim().toLowerCase();
    return candidatePassword == password &&
        (normalized == username.toLowerCase() ||
            normalized == email.toLowerCase());
  }
}

class DemoAuthService {
  const DemoAuthService._();

  static const defaultUsername = 'ABC';
  static const defaultPassword = '123';
  static const providerKey = 'demo_auth_provider';
  static const _localUsernameKey = 'local_auth_username';
  static const _localEmailKey = 'local_auth_email';
  static const _localPasswordKey = 'local_auth_password';
  static const _localDisplayNameKey = 'local_auth_display_name';

  static const defaultLocalProfile = UserProfile(
    displayName: defaultUsername,
    username: '@ABC',
    email: 'abc@retrotech.demo',
    bio: 'Default coursework demo account.',
    location: 'Kuala Lumpur',
    sellerName: 'RetroTech Collector',
    preferredContact: 'In-app message',
  );

  static DemoAuthProvider? providerFromValue(String? value) {
    for (final provider in DemoAuthProvider.values) {
      if (provider.storageValue == value) return provider;
    }
    return null;
  }

  static Future<void> saveProvider(DemoAuthProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(providerKey, provider.storageValue);
  }

  static Future<void> clearProvider() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(providerKey);
  }

  static Future<UserProfile?> validateLocalCredentials(
    String identifier,
    String password,
  ) async {
    final trimmedIdentifier = identifier.trim();
    if (_matchesDefaultAccount(trimmedIdentifier, password)) {
      return defaultLocalProfile;
    }

    final account = await loadLocalAccount();
    if (account != null && account.matches(trimmedIdentifier, password)) {
      return account.profile;
    }
    return null;
  }

  static Future<UserProfile> registerLocalAccount({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final trimmedName = displayName.trim();
    final trimmedEmail = email.trim();
    final username = trimmedName.isEmpty
        ? _usernameFromEmail(trimmedEmail)
        : trimmedName;
    final profile = UserProfile(
      displayName: trimmedName.isEmpty ? username : trimmedName,
      username: '@${username.replaceAll(' ', '').toLowerCase()}',
      email: trimmedEmail,
      bio: 'Local RetroTech coursework account.',
      location: 'Kuala Lumpur',
      sellerName: username,
      preferredContact: 'In-app message',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localUsernameKey, username);
    await prefs.setString(_localEmailKey, trimmedEmail);
    await prefs.setString(_localPasswordKey, password);
    await prefs.setString(_localDisplayNameKey, profile.displayName);
    return profile;
  }

  static Future<bool> resetLocalPassword({
    required String identifier,
    required String newPassword,
  }) async {
    final account = await loadLocalAccount();
    if (account == null) return false;
    final normalized = identifier.trim().toLowerCase();
    final matchesAccount =
        normalized == account.username.toLowerCase() ||
        normalized == account.email.toLowerCase();
    if (!matchesAccount) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localPasswordKey, newPassword);
    return true;
  }

  static Future<LocalAuthAccount?> loadLocalAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_localUsernameKey);
    final email = prefs.getString(_localEmailKey);
    final password = prefs.getString(_localPasswordKey);
    final displayName = prefs.getString(_localDisplayNameKey);
    if (username == null ||
        username.isEmpty ||
        email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      return null;
    }
    return LocalAuthAccount(
      username: username,
      email: email,
      password: password,
      profile: UserProfile(
        displayName: displayName?.isNotEmpty == true ? displayName! : username,
        username: '@${username.replaceAll(' ', '').toLowerCase()}',
        email: email,
        bio: 'Local RetroTech coursework account.',
        location: 'Kuala Lumpur',
        sellerName: username,
        preferredContact: 'In-app message',
      ),
    );
  }

  static bool isDefaultAccount(String identifier) {
    return identifier.trim().toLowerCase() == defaultUsername.toLowerCase();
  }

  static bool _matchesDefaultAccount(String identifier, String password) {
    return isDefaultAccount(identifier) && password == defaultPassword;
  }

  static String _usernameFromEmail(String email) {
    final index = email.indexOf('@');
    if (index <= 0) return 'localcollector';
    return email.substring(0, index);
  }
}
