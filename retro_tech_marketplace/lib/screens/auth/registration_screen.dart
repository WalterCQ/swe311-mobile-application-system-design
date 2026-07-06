import 'package:flutter/material.dart';
import '../../constants/assets.dart';
import '../../constants/theme.dart';
import '../../store/listing_store.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/interaction_helpers.dart';
import '../../widgets/liquid_button.dart';
import '../../widgets/logo_mark.dart';
import '../../widgets/navigation.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, required this.store});

  final ListingStore store;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _agree = true;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      backgroundAsset: Assets.loginBackground,
      backgroundOverlay: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(52, 64, 52, 28),
        children: [
          Align(
            alignment: Alignment.center,
            child: LogoMark(size: 100, heroTag: authLogoHeroTag),
          ),
          SizedBox(height: 44),
          RichText(
            text: TextSpan(
              style: AppTheme.h1.copyWith(fontSize: 32),
              children: [
                TextSpan(text: 'Create your\n'),
                TextSpan(
                  text: 'Retro ',
                  style: TextStyle(color: AppTheme.blue),
                ),
                TextSpan(
                  text: 'Tech',
                  style: TextStyle(color: AppTheme.red),
                ),
                TextSpan(text: '\naccount'),
              ],
            ),
          ),
          SizedBox(height: 24),
          GlassInput(
            controller: _name,
            hint: 'Full Name',
            icon: Icons.person_outline_rounded,
          ),
          SizedBox(height: 12),
          GlassInput(
            controller: _email,
            hint: 'Email Address',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 12),
          GlassInput(
            controller: _password,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: true,
          ),
          SizedBox(height: 12),
          GlassInput(
            controller: _confirm,
            hint: 'Confirm Password',
            icon: Icons.lock_outline_rounded,
            obscure: true,
          ),
          SizedBox(height: 18),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _agree = !_agree),
                child: Icon(
                  _agree ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: AppTheme.red,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  key: const ValueKey('terms-policy-link'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => showInfoSheet(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Terms & Privacy Policy',
                    body:
                        'RetroTech keeps account, listing, order, chat, and community data inside this local coursework demo. No real payment, OAuth, or remote notification service is used.',
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: AppTheme.body.copyWith(fontSize: 12),
                      children: [
                        TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms & Privacy Policy',
                          style: TextStyle(
                            color: AppTheme.blue,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 26),
          LiquidButton(
            label: _submitting ? 'Creating...' : 'Create Account',
            icon: Icons.arrow_forward_rounded,
            onPressed: _handleRegistration,
          ),
          SizedBox(height: 30),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: AppTheme.body.copyWith(fontSize: 12),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text('Log In', style: AppTheme.label),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (_submitting) return;
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final confirm = _confirm.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      showAppSnackBar(context, 'Complete all account fields.');
      return;
    }
    if (!email.contains('@')) {
      showAppSnackBar(context, 'Enter a valid email address.');
      return;
    }
    if (password != confirm) {
      showAppSnackBar(context, 'Passwords do not match.');
      return;
    }
    if (!_agree) {
      showAppSnackBar(context, 'Agree to the terms first.');
      return;
    }
    setState(() => _submitting = true);
    await widget.store.registerLocalAccount(
      displayName: name,
      email: email,
      password: password,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.pushReplacementNamed(context, '/main');
  }
}
