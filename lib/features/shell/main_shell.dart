import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/app_state.dart';
import '../account/account_screen.dart';
import '../cart/cart_screen.dart';
import '../catalog/catalog_screen.dart';
import '../home/home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _openCatalog() => setState(() => _index = 1);

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    final titles = ['Accueil', 'Catalogue', 'Panier', 'Compte'];

    final pages = [
      HomeScreen(onOpenCatalog: _openCatalog),
      const CatalogScreen(),
      const CartScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(titles[_index]),
          ],
        ),
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primarySoft,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Accueil',
              ),
              const NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Catalogue',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  child: const Icon(Icons.shopping_bag_rounded),
                ),
                label: 'Panier',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Compte',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
