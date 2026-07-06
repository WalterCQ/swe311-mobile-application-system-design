import 'package:flutter/material.dart';
import '../constants/assets.dart';
import '../constants/theme.dart';
import 'aero_background.dart';
import 'glass_card.dart';
import 'liquid_button.dart';
import 'navigation.dart';

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.includeSafeArea = true,
    this.backgroundAsset = Assets.background,
    this.backgroundOverlay = true,
    this.background,
  });

  final Widget child;
  final Widget? bottomNavigationBar;
  final bool includeSafeArea;
  final String backgroundAsset;
  final bool backgroundOverlay;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    final content = includeSafeArea
        ? SafeArea(bottom: false, child: child)
        : child;
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth > 480
              ? 440.0
              : constraints.maxWidth;
          return Center(
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  background ??
                      AeroBackground(
                        asset: backgroundAsset,
                        includeOverlay: backgroundOverlay,
                      ),
                  content,
                  if (bottomNavigationBar != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: bottomNavigationBar!,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FormShell extends StatelessWidget {
  const FormShell({
    super.key,
    required this.title,
    required this.action,
    required this.onSave,
    required this.children,
    this.formKey,
    this.autovalidateMode,
    this.dangerAction,
    this.onDanger,
  });

  final String title;
  final String action;
  final VoidCallback onSave;
  final List<Widget> children;
  final GlobalKey<FormState>? formKey;
  final AutovalidateMode? autovalidateMode;
  final String? dangerAction;
  final VoidCallback? onDanger;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: Stack(
        children: [
          Form(
            key: formKey,
            autovalidateMode: autovalidateMode,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                22,
                18,
                22,
                dangerAction == null ? 104 : 136,
              ),
              children: [
                TopBar(
                  title: title,
                  trailing: title.contains('Edit')
                      ? Icons.visibility_outlined
                      : null,
                ),
                SizedBox(height: 22),
                ...children,
              ],
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: dangerAction == null ? 22 : 54,
            child: LiquidButton(
              label: action,
              icon: Icons.check_circle_outline_rounded,
              onPressed: onSave,
            ),
          ),
          if (dangerAction != null)
            Positioned(
              left: 22,
              right: 22,
              bottom: 12,
              child: TextButton(
                onPressed: onDanger,
                child: Text(
                  dangerAction!,
                  style: AppTheme.label.copyWith(color: AppTheme.red),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FormSection extends StatelessWidget {
  const FormSection({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6, bottom: subtitle == null ? 10 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.h2.copyWith(fontSize: 16)),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(subtitle!, style: AppTheme.body.copyWith(fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class GlassFormPanel extends StatelessWidget {
  const GlassFormPanel({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 28,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: margin,
      radius: radius,
      padding: padding,
      opacity: 0.24,
      borderOpacity: 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
