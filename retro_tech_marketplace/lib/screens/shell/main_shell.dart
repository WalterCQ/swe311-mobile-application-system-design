import 'package:flutter/material.dart';
import '../../store/listing_store.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/navigation.dart';
import '../home/home_screen.dart';
import '../home/categories_screen.dart';
import '../profile/account_profile_screen.dart';
import '../settings/chat_thread_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.store, this.initialIndex = 0});

  final ListingStore store;
  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = _shellIndexFor(widget.initialIndex);
  late final _categoriesSearchController = CategoriesSearchController();
  late final List<Widget> _pages = [
    HomeScreen(
      store: widget.store,
      onSearchTap: _openCategorySearch,
      onProfileTap: _openProfile,
    ),
    CategoriesScreen(
      store: widget.store,
      searchTrigger: _categoriesSearchController,
    ),
    InboxScreen(store: widget.store, inShell: true),
    AccountProfileScreen(store: widget.store),
  ];

  int _shellIndexFor(int navIndex) {
    if (navIndex == 2) return 0;
    return navIndex > 2 ? navIndex - 1 : navIndex;
  }

  void _openCategorySearch() {
    setState(() => _index = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _categoriesSearchController.openSearch();
    });
  }

  void _openProfile() {
    setState(() => _index = 3);
  }

  @override
  void dispose() {
    _categoriesSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _index,
        onTap: (index) {
          if (index == 2) {
            Navigator.pushNamed(context, '/create-listing');
            return;
          }
          setState(() => _index = index > 2 ? index - 1 : index);
        },
      ),
      child: SizedBox.expand(
        child: Stack(
          children: [
            for (var pageIndex = 0; pageIndex < _pages.length; pageIndex++)
              AnimatedShellPage(
                active: pageIndex == _index,
                currentIndex: _index,
                pageIndex: pageIndex,
                child: _pages[pageIndex],
              ),
          ],
        ),
      ),
    );
  }
}

class AnimatedShellPage extends StatelessWidget {
  const AnimatedShellPage({
    super.key,
    required this.active,
    required this.currentIndex,
    required this.pageIndex,
    required this.child,
  });

  final bool active;
  final int currentIndex;
  final int pageIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hiddenOffset = pageIndex < currentIndex
        ? const Offset(-0.045, 0)
        : const Offset(0.045, 0);

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !active,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          opacity: active ? 1 : 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            offset: active ? Offset.zero : hiddenOffset,
            child: HeroMode(
              enabled: active,
              child: TickerMode(enabled: active, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
