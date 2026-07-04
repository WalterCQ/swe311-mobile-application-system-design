import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/theme.dart';
import '../../models/payment_method.dart';
import '../../store/listing_store.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/navigation.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({
    super.key,
    required this.store,
    this.closeOnSelect = false,
  });

  final ListingStore store;
  final bool closeOnSelect;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return GlassScaffold(
          child: ListView(
            padding: EdgeInsets.fromLTRB(22, 18, 22, 28),
            children: [
              TopBar(title: 'Payment Methods', showTrailing: false),
              SizedBox(height: 18),
              Text('Select payment', style: AppTheme.h2),
              SizedBox(height: 6),
              Text(
                'Choose the method used for this checkout.',
                style: AppTheme.body.copyWith(fontSize: 13),
              ),
              SizedBox(height: 14),
              GlassCard(
                padding: EdgeInsets.zero,
                radius: 22,
                opacity: 0.58,
                borderOpacity: 0.9,
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < PaymentMethodOption.options.length;
                      index++
                    ) ...[
                      _PaymentTile(
                        PaymentMethodOption.options[index],
                        selected:
                            store.selectedPaymentMethod.id ==
                            PaymentMethodOption.options[index].id,
                        onTap: () async {
                          await store.selectPaymentMethod(
                            PaymentMethodOption.options[index].id,
                          );
                          if (closeOnSelect && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      if (index < PaymentMethodOption.options.length - 1)
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 70,
                          color: AppTheme.line.withValues(alpha: 0.7),
                        ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 12),
              _PaymentFooter(),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile(
    this.method, {
    required this.selected,
    required this.onTap,
  });

  final PaymentMethodOption method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 74),
        color: selected
            ? AppTheme.red.withValues(alpha: 0.06)
            : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _PaymentLogo(method: method),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.h2.copyWith(fontSize: 15),
                  ),
                  SizedBox(height: 3),
                  Text(
                    method.processingNote,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            _SelectionMark(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 160),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppTheme.red : Colors.transparent,
        border: Border.all(
          color: selected ? AppTheme.red : AppTheme.line,
          width: 1.4,
        ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, color: AppTheme.white, size: 16)
          : null,
    );
  }
}

class _PaymentLogo extends StatelessWidget {
  const _PaymentLogo({required this.method});

  final PaymentMethodOption method;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: method.color.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: EdgeInsets.all(7),
        child: method.logoAsset.endsWith('.svg')
            ? SvgPicture.asset(
                method.logoAsset,
                key: ValueKey('payment-logo-${method.id}'),
                fit: BoxFit.contain,
                width: 32,
                height: 32,
              )
            : Image.asset(
                method.logoAsset,
                key: ValueKey('payment-logo-${method.id}'),
                fit: BoxFit.contain,
                width: 34,
                height: 28,
              ),
      ),
    );
  }
}

class _PaymentFooter extends StatelessWidget {
  const _PaymentFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: AppTheme.blue,
              size: 16,
            ),
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Secure checkout. Review the total before paying.',
              style: AppTheme.body.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
