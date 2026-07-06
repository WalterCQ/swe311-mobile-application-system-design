import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/assets.dart';
import '../../constants/theme.dart';
import '../../services/demo_auth_service.dart';
import '../../store/listing_store.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/interaction_helpers.dart';
import '../../widgets/liquid_button.dart';
import '../../widgets/logo_mark.dart';
import '../../widgets/navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.store});

  final ListingStore store;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = true;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ResponsiveMetrics.of(context);
    final horizontalPadding = metrics.compact ? 32.0 : 40.0;
    return GlassScaffold(
      backgroundAsset: Assets.loginBackground,
      backgroundOverlay: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          metrics.compact ? 58 : 64,
          horizontalPadding,
          28,
        ),
        children: [
          Center(
            child: LogoMark(
              size: metrics.compact ? 110 : 120,
              heroTag: authLogoHeroTag,
            ),
          ),
          SizedBox(height: metrics.compact ? 56 : 64),
          Center(
            child: RichText(
              text: TextSpan(
                style: AppTheme.h1.copyWith(fontSize: 32),
                children: [
                  TextSpan(
                    text: 'Welcome ',
                    style: TextStyle(color: AppTheme.blue),
                  ),
                  TextSpan(
                    text: 'Back',
                    style: TextStyle(color: AppTheme.red),
                  ),
                  accentSquare(size: 8),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Log in to continue your journey.',
            textAlign: TextAlign.center,
            style: AppTheme.body,
          ),
          SizedBox(height: 34),
          GlassInput(
            controller: _email,
            hint: 'Username or Email',
            icon: Icons.person_outline_rounded,
          ),
          SizedBox(height: 14),
          GlassInput(
            controller: _password,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: true,
          ),
          SizedBox(height: 18),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _remember = !_remember),
                child: GlassCard(
                  width: 34,
                  height: 34,
                  radius: 17,
                  padding: EdgeInsets.zero,
                  child: Icon(
                    _remember ? Icons.check_rounded : Icons.circle_outlined,
                    color: AppTheme.red,
                    size: 18,
                  ),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Remember me',
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.body,
                ),
              ),
              GestureDetector(
                key: const ValueKey('forgot-password-link'),
                onTap: () => _showPasswordReset(context),
                child: Text(
                  'Forgot password?',
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.label.copyWith(
                    color: AppTheme.blue,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 28),
          LiquidButton(
            label: _submitting ? 'Checking...' : 'Log In',
            icon: Icons.arrow_forward_rounded,
            onPressed: _handleLogin,
          ),
          SizedBox(height: 40),
          Center(child: SocialLoginCluster(store: widget.store)),
          SizedBox(height: 46),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: AppTheme.body.copyWith(fontSize: 12),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: Text('Sign Up', style: AppTheme.label),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_submitting) return;
    final identifier = _email.text.trim();
    final password = _password.text;
    if (identifier.isEmpty || password.isEmpty) {
      showAppSnackBar(context, 'Enter username and password.');
      return;
    }
    setState(() => _submitting = true);
    final authenticated = await widget.store.signInWithLocalAccount(
      identifier: identifier,
      password: password,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!authenticated) {
      showAppSnackBar(context, 'Invalid username or password.');
      return;
    }
    Navigator.pushReplacementNamed(context, '/main');
  }

  Future<void> _showPasswordReset(BuildContext context) async {
    final identifierController = TextEditingController();
    final passwordController = TextEditingController();
    var message = '';
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.white.withValues(alpha: 0.38),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: GlassCard(
                  radius: 28,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  opacity: 0.84,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_reset_rounded,
                        color: AppTheme.blue,
                        size: 30,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Reset Local Password',
                        style: AppTheme.h2.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reset the password for your locally registered account. The default account stays ABC / 123.',
                        style: AppTheme.body.copyWith(height: 1.45),
                      ),
                      const SizedBox(height: 14),
                      GlassInput(
                        key: const ValueKey('reset-username-field'),
                        controller: identifierController,
                        hint: 'Username or Email',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 12),
                      GlassInput(
                        key: const ValueKey('reset-password-field'),
                        controller: passwordController,
                        hint: 'New Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                      ),
                      if (message.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          message,
                          style: AppTheme.body.copyWith(
                            color: AppTheme.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      LiquidButton(
                        label: 'Reset Password',
                        height: 48,
                        onPressed: () async {
                          final identifier = identifierController.text.trim();
                          final newPassword = passwordController.text;
                          if (identifier.isEmpty || newPassword.isEmpty) {
                            setSheetState(
                              () => message = 'Enter account and new password.',
                            );
                            return;
                          }
                          if (DemoAuthService.isDefaultAccount(identifier)) {
                            setSheetState(
                              () => message =
                                  'Default account remains ABC / 123.',
                            );
                            return;
                          }
                          final changed = await widget.store.resetLocalPassword(
                            identifier: identifier,
                            newPassword: newPassword,
                          );
                          if (!sheetContext.mounted) return;
                          if (!changed) {
                            setSheetState(
                              () => message = 'No local account found.',
                            );
                            return;
                          }
                          Navigator.pop(sheetContext);
                          if (!mounted) return;
                          showAppSnackBar(context, 'Password reset locally.');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    identifierController.dispose();
    passwordController.dispose();
  }
}

class SocialLoginCluster extends StatelessWidget {
  const SocialLoginCluster({super.key, required this.store});

  final ListingStore store;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final clusterWidth = constraints.maxWidth
            .clamp(256.0, 360.0)
            .toDouble();
        final gap = clusterWidth < 300 ? 10.0 : 12.0;
        final buttonWidth = ((clusterWidth - gap * 2) / 3)
            .clamp(78.0, 108.0)
            .toDouble();
        final buttonHeight = (buttonWidth * 0.62).clamp(54.0, 66.0).toDouble();
        return SizedBox(
          width: clusterWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0x61BFC7D6)),
                      child: SizedBox(height: 1),
                    ),
                  ),
                  SizedBox(
                    width: 126,
                    child: Text(
                      'Or continue with',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0x61BFC7D6)),
                      child: SizedBox(height: 1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26),
              Row(
                children: [
                  SocialButton(
                    semanticLabel: 'Continue with Google',
                    asset: Assets.googleIcon,
                    width: buttonWidth,
                    height: buttonHeight,
                    iconWidth: 26.4,
                    iconHeight: 26.4,
                    onTap: () => _signIn(context, DemoAuthProvider.google),
                  ),
                  SizedBox(width: gap),
                  SocialButton(
                    semanticLabel: 'Continue with Apple',
                    asset: Assets.appleIcon,
                    width: buttonWidth,
                    height: buttonHeight,
                    iconWidth: 24,
                    iconHeight: 30,
                    onTap: () => _signIn(context, DemoAuthProvider.apple),
                  ),
                  SizedBox(width: gap),
                  SocialButton(
                    semanticLabel: 'Continue with Facebook',
                    asset: Assets.facebookIcon,
                    width: buttonWidth,
                    height: buttonHeight,
                    iconWidth: 28.8,
                    iconHeight: 28.8,
                    onTap: () => _signIn(context, DemoAuthProvider.facebook),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _signIn(BuildContext context, DemoAuthProvider provider) async {
    await store.signInWithDemoProvider(provider);
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.asset,
    required this.semanticLabel,
    required this.width,
    required this.height,
    required this.iconWidth,
    required this.iconHeight,
    required this.onTap,
  });

  final String asset;
  final String semanticLabel;
  final double width;
  final double height;
  final double iconWidth;
  final double iconHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = height * 0.38;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: LiquidPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        glowColor: AppTheme.blue,
        pressedScale: 0.96,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.54),
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1A2942).withValues(alpha: 0.13),
                        offset: Offset(0, 12),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        color: Colors.white.withValues(alpha: 0.54),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.72),
                          width: 1,
                        ),
                      ),
                      child: SvgPicture.asset(
                        asset,
                        width: iconWidth,
                        height: iconHeight,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
