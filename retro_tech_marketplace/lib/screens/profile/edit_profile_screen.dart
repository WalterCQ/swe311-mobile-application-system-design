import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../store/listing_store.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/logo_mark.dart';
import '../../widgets/navigation.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.store});

  final ListingStore store;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _displayName = TextEditingController(
    text: widget.store.profile.displayName,
  );
  late final _username = TextEditingController(
    text: widget.store.profile.username,
  );
  late final _email = TextEditingController(text: widget.store.profile.email);
  late final _bio = TextEditingController(text: widget.store.profile.bio);
  late final _location = TextEditingController(
    text: widget.store.profile.location,
  );
  late final _seller = TextEditingController(
    text: widget.store.profile.sellerName,
  );
  late final _contact = TextEditingController(
    text: widget.store.profile.preferredContact,
  );
  bool _submitted = false;

  @override
  void dispose() {
    _displayName.dispose();
    _username.dispose();
    _email.dispose();
    _bio.dispose();
    _location.dispose();
    _seller.dispose();
    _contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormShell(
      title: 'Edit Profile',
      action: 'Save Profile',
      onSave: _save,
      formKey: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      children: [
        Center(child: LogoMark(size: 110, heroTag: accountLogoHeroTag)),
        SizedBox(height: 20),
        GlassFormPanel(
          children: [
            FormSection(
              title: 'Public Profile',
              subtitle:
                  'These details appear on your profile and buyer messages.',
            ),
            GlassInput(
              controller: _displayName,
              label: 'Display Name',
              hint: 'Retro Tech',
              icon: Icons.person_outline_rounded,
              requiredField: true,
              textInputAction: TextInputAction.next,
              validator: _required('Enter a display name.'),
            ),
            SizedBox(height: 12),
            GlassInput(
              controller: _username,
              label: 'Username',
              hint: '@retrotech',
              icon: Icons.alternate_email_rounded,
              requiredField: true,
              textInputAction: TextInputAction.next,
              validator: _required('Enter a username.'),
            ),
            SizedBox(height: 12),
            GlassInput(
              controller: _email,
              label: 'Email',
              hint: 'retro@tech.market',
              icon: Icons.email_outlined,
              requiredField: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _emailValidator,
            ),
            SizedBox(height: 12),
            GlassInput(
              controller: _bio,
              label: 'Bio',
              hint: 'Collect rare. Live timeless.',
              icon: Icons.edit_outlined,
              maxLines: 2,
              textInputAction: TextInputAction.newline,
            ),
            SizedBox(height: 12),
            GlassInput(
              controller: _location,
              label: 'Location',
              hint: 'Kuala Lumpur',
              icon: Icons.location_on_outlined,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 18),
            FormSection(
              title: 'Marketplace Identity',
              subtitle:
                  'Use a seller name and contact method buyers can trust.',
            ),
            GlassInput(
              controller: _seller,
              label: 'Seller Name',
              hint: 'RetroTech Collector',
              icon: Icons.storefront_outlined,
              requiredField: true,
              textInputAction: TextInputAction.next,
              validator: _required('Enter a seller name.'),
            ),
            SizedBox(height: 12),
            GlassInput(
              controller: _contact,
              label: 'Preferred Contact',
              hint: 'In-app message',
              icon: Icons.chat_bubble_outline_rounded,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    await widget.store.saveProfile(
      UserProfile(
        displayName: _displayName.text.trim(),
        username: _username.text.trim(),
        email: _email.text.trim(),
        bio: _bio.text.trim(),
        location: _location.text.trim(),
        sellerName: _seller.text.trim(),
        preferredContact: _contact.text.trim(),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  FormFieldValidator<String> _required(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter an email address.';
    final validEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!validEmail.hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }
}
