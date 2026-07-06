import 'package:flutter/material.dart';

import '../../constants/theme.dart';
import '../../store/listing_store.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/navigation.dart';
import '../home/home_screen.dart';

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key, required this.store});

  final ListingStore store;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final items = store.savedListings;
          return ListView(
            padding: EdgeInsets.fromLTRB(22, 18, 22, 30),
            children: [
              TopBar(title: 'Saved Items', showTrailing: false),
              SizedBox(height: 20),
              if (items.isEmpty)
                GlassCard(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        color: AppTheme.red,
                        size: 36,
                      ),
                      SizedBox(height: 10),
                      Text('No saved items yet', style: AppTheme.h2),
                      SizedBox(height: 6),
                      Text(
                        'Tap the heart on any product to save it here.',
                        textAlign: TextAlign.center,
                        style: AppTheme.body,
                      ),
                    ],
                  ),
                )
              else
                ...items.map(
                  (listing) => ListingCard(
                    listing: listing,
                    openStore: store,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/product',
                      arguments: listing,
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
