import 'package:flutter/material.dart';

import '../constants/theme.dart';

class PaymentMethodOption {
  const PaymentMethodOption({
    required this.id,
    required this.logoAsset,
    required this.title,
    required this.subtitle,
    required this.processingNote,
    required this.color,
  });

  final String id;
  final String logoAsset;
  final String title;
  final String subtitle;
  final String processingNote;
  final Color color;

  static const visa = PaymentMethodOption(
    id: 'visa',
    logoAsset: 'assets/payment/visa.svg',
    title: 'Visa ending 2048',
    subtitle: 'Saved card',
    processingNote: 'Instant confirmation',
    color: AppTheme.blue,
  );

  static const options = [
    visa,
    PaymentMethodOption(
      id: 'apple-pay',
      logoAsset: 'assets/payment/apple-pay.svg',
      title: 'Apple Pay',
      subtitle: 'Wallet payment',
      processingNote: 'Confirm with device passcode',
      color: AppTheme.ink,
    ),
    PaymentMethodOption(
      id: 'tng',
      logoAsset: 'assets/payment/touch-n-go-ewallet.svg',
      title: "Touch 'n Go eWallet",
      subtitle: 'Malaysia eWallet',
      processingNote: 'Authorise in wallet',
      color: AppTheme.blue,
    ),
    PaymentMethodOption(
      id: 'bank',
      logoAsset: 'assets/payment/fpx-logo.png',
      title: 'Online Banking',
      subtitle: 'FPX transfer',
      processingNote: 'Redirect to bank login',
      color: AppTheme.green,
    ),
  ];

  static PaymentMethodOption byId(String id) {
    return options.firstWhere((method) => method.id == id, orElse: () => visa);
  }
}
