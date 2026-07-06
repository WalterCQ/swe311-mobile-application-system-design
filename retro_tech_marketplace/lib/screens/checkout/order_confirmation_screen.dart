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
          _ConfirmationHero(order: item),
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
  const _ConfirmationHero({required this.order});

  final OrderRecord order;

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
            'Order placed with selected payment method.',
            textAlign: TextAlign.center,
            style: AppTheme.body.copyWith(fontSize: 13),
          ),
          SizedBox(height: 18),
          Divider(color: AppTheme.line),
          SizedBox(height: 14),
          Row(
            children: [
              ProductImage(asset: order.imageAsset, width: 62, height: 62),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.listingTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Order #${order.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.label,
                    ),
                    Text(
                      'Selected ${order.paymentMethodTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.body.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            order.totalLabel,
            style: AppTheme.h1.copyWith(fontSize: 30, color: AppTheme.blue),
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
                  _ProgressChip('Order Placed', Icons.done_rounded, true),
                  _ProgressChip(
                    'Payment Selected',
                    Icons.credit_card_rounded,
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
                    '${order.status} with ${order.paymentMethodTitle}',
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
    protectionFee: 0,
    paymentMethodId: method.id,
    paymentMethodTitle: method.title,
    status: 'Placed',
    createdAt: DateTime.now(),
  );
}
