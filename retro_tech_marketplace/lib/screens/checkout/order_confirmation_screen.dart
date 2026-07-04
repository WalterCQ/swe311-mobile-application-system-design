import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../models/order_record.dart';
import '../../store/listing_store.dart';
import '../../store/seed_data.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/liquid_button.dart';
import '../../widgets/logo_mark.dart';
import '../../widgets/navigation.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.store, this.order});

  final ListingStore store;
  final OrderRecord? order;

  @override
  Widget build(BuildContext context) {
    final item = order ?? _fallbackOrder(store);
    return GlassScaffold(
      child: ListView(
        padding: EdgeInsets.fromLTRB(22, 22, 22, 30),
        children: [
          Center(child: Text('RetroTech', style: AppTheme.h2)),
          SizedBox(height: 24),
          _ConfirmationHero(),
          SizedBox(height: 16),
          _ReceiptSummaryCard(order: item),
          SizedBox(height: 16),
          _ConfirmationTimeline(),
          SizedBox(height: 24),
          LiquidButton(
            label: 'Track Order',
            icon: Icons.my_location_rounded,
            onPressed: () =>
                Navigator.pushNamed(context, '/order-detail', arguments: item),
          ),
          SizedBox(height: 6),
          TextButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/main',
              (route) => false,
            ),
            icon: Icon(Icons.home_outlined, color: AppTheme.blue, size: 20),
            label: Text('Back to Home', style: AppTheme.label),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationHero extends StatelessWidget {
  const _ConfirmationHero();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.fromLTRB(18, 22, 18, 22),
      borderOpacity: 0.94,
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.green.withValues(alpha: 0.12),
              border: Border.all(color: AppTheme.green.withValues(alpha: 0.28)),
            ),
            child: Icon(Icons.done_rounded, color: AppTheme.green, size: 52),
          ),
          SizedBox(height: 18),
          Text(
            'Order Confirmed',
            textAlign: TextAlign.center,
            style: AppTheme.h1,
          ),
          SizedBox(height: 8),
          Text(
            'Payment completed. The seller has been notified.',
            textAlign: TextAlign.center,
            style: AppTheme.body.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ReceiptSummaryCard extends StatelessWidget {
  const _ReceiptSummaryCard({required this.order});

  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(18),
      borderOpacity: 0.92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Receipt Summary',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.h2.copyWith(fontSize: 16),
                ),
              ),
              SizedBox(width: 12),
              _StatusPill(label: order.status),
            ],
          ),
          SizedBox(height: 14),
          Text(
            order.totalLabel,
            style: AppTheme.h1.copyWith(fontSize: 30, color: AppTheme.blue),
          ),
          SizedBox(height: 4),
          Text(
            'Paid via ${order.paymentMethodTitle}',
            style: AppTheme.body.copyWith(fontSize: 13),
          ),
          SizedBox(height: 16),
          Divider(color: AppTheme.line),
          SizedBox(height: 12),
          Row(
            children: [
              ProductImage(asset: order.imageAsset, width: 74, height: 74),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.listingTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('Seller: ${order.seller}', style: AppTheme.body),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _ReceiptRow(
            icon: Icons.confirmation_number_outlined,
            title: 'Order number',
            value: '#${order.id}',
          ),
          _ReceiptRow(
            icon: Icons.credit_card_outlined,
            title: 'Payment method',
            value: order.paymentMethodTitle,
          ),
          _ReceiptRow(
            icon: Icons.inventory_2_outlined,
            title: 'Current status',
            value: order.status,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.green.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: AppTheme.label.copyWith(color: AppTheme.green, fontSize: 11),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.blue, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(title, style: AppTheme.body.copyWith(fontSize: 13)),
          ),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationTimeline extends StatelessWidget {
  const _ConfirmationTimeline();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.fromLTRB(14, 16, 14, 14),
      borderOpacity: 0.92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Next Steps', style: AppTheme.h2.copyWith(fontSize: 16)),
          SizedBox(height: 14),
          Row(
            children: [
              _TimelineStep(
                label: 'Paid',
                icon: Icons.done_rounded,
                complete: true,
              ),
              _TimelineConnector(complete: true),
              _TimelineStep(
                label: 'Seller Notified',
                icon: Icons.notifications_rounded,
                complete: true,
              ),
              _TimelineConnector(complete: false),
              _TimelineStep(
                label: 'Preparing Shipment',
                icon: Icons.inventory_2_outlined,
                complete: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector({required this.complete});

  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 2,
      margin: EdgeInsets.only(bottom: 28),
      color: (complete ? AppTheme.blue : AppTheme.line).withValues(alpha: 0.82),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.complete,
  });

  final String label;
  final IconData icon;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final color = complete ? AppTheme.blue : AppTheme.muted;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: complete ? 0.14 : 0.08),
              border: Border.all(color: color.withValues(alpha: 0.24)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.body.copyWith(
              fontSize: 10,
              height: 1.16,
              color: complete ? AppTheme.ink : AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, required this.store});

  final ListingStore store;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final orders = store.orders;
          return ListView(
            padding: EdgeInsets.fromLTRB(22, 18, 22, 30),
            children: [
              TopBar(title: 'Orders'),
              SizedBox(height: 20),
              if (orders.isEmpty)
                GlassCard(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: AppTheme.blue,
                        size: 34,
                      ),
                      SizedBox(height: 10),
                      Text('No orders yet', style: AppTheme.h2),
                      SizedBox(height: 6),
                      Text(
                        'Buy a listing to create your first tracked order.',
                        textAlign: TextAlign.center,
                        style: AppTheme.body,
                      ),
                    ],
                  ),
                )
              else
                ...orders.map(
                  (order) => _OrderCard(
                    order: order,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/order-detail',
                      arguments: order,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({
    super.key,
    required this.store,
    this.order,
    this.orderId,
  });

  final ListingStore store;
  final OrderRecord? order;
  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final item =
            order ??
            (orderId == null ? null : store.orderById(orderId!)) ??
            (store.orders.isEmpty ? _fallbackOrder(store) : store.orders.first);
        return GlassScaffold(
          child: ListView(
            padding: EdgeInsets.fromLTRB(22, 18, 22, 30),
            children: [
              TopBar(title: 'Order Detail'),
              SizedBox(height: 20),
              _OrderCard(order: item),
              SizedBox(height: 18),
              Text('Status', style: AppTheme.h2.copyWith(fontSize: 16)),
              SizedBox(height: 12),
              Row(
                children: [
                  _ProgressChip('Paid', Icons.done_rounded, true),
                  _ProgressChip(
                    'Seller Notified',
                    Icons.notifications_rounded,
                    true,
                  ),
                  _ProgressChip('Preparing', Icons.inventory_2_outlined, false),
                ],
              ),
              SizedBox(height: 18),
              GlassListSection(
                children: [
                  GlassListRow(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Order ID',
                    value: item.id,
                  ),
                  GlassListRow(
                    icon: Icons.credit_card_outlined,
                    title: 'Payment',
                    value: item.paymentMethodTitle,
                  ),
                  GlassListRow(
                    icon: Icons.local_shipping_outlined,
                    title: 'Delivery',
                    value: 'Pos Laju',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, this.onTap});

  final OrderRecord order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LiquidPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      glowColor: AppTheme.blue,
      child: GlassCard(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            ProductImage(asset: order.imageAsset, width: 62, height: 62),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.listingTitle,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text('Order #${order.id}', style: AppTheme.label),
                  Text(
                    '${order.status} via ${order.paymentMethodTitle}',
                    style: AppTheme.body.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              order.totalLabel,
              style: AppTheme.label.copyWith(color: AppTheme.red),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  const _ProgressChip(this.label, this.icon, this.done);

  final String label;
  final IconData icon;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 12),
        radius: 20,
        child: Column(
          children: [
            Icon(icon, color: done ? AppTheme.blue : AppTheme.muted),
            SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.body.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

OrderRecord _fallbackOrder(ListingStore store) {
  final listing = seedListings.first;
  final method = store.selectedPaymentMethod;
  return OrderRecord(
    id: 'RT2048',
    listingId: listing.id,
    listingTitle: listing.shortTitle,
    seller: listing.seller,
    imageAsset: listing.imageAsset,
    itemPrice: listing.price,
    shipping: 35,
    protectionFee: 15,
    paymentMethodId: method.id,
    paymentMethodTitle: method.title,
    status: 'Paid',
    createdAt: DateTime.now(),
  );
}
