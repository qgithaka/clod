import 'package:flutter/material.dart';

class ResponsiveShell extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const ResponsiveShell({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    NavigationDestination(icon: Icon(Icons.people), label: 'Customers'),
    NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Catalogue'),
    NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'POS'),
    NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Documents'),
    NavigationDestination(icon: Icon(Icons.business_center), label: 'Back-Office'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  static const List<NavigationRailDestination> _railDestinations = [
    NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
    NavigationRailDestination(icon: Icon(Icons.people), label: Text('Customers')),
    NavigationRailDestination(icon: Icon(Icons.inventory_2), label: Text('Catalogue')),
    NavigationRailDestination(icon: Icon(Icons.point_of_sale), label: Text('POS')),
    NavigationRailDestination(icon: Icon(Icons.receipt_long), label: Text('Documents')),
    NavigationRailDestination(icon: Icon(Icons.business_center), label: Text('Back-Office')),
    NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile: NavigationBar at bottom
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: _destinations,
            ),
          );
        } else {
          // Desktop/Tablet: NavigationRail on left
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  destinations: _railDestinations,
                  extended: constraints.maxWidth >= 1200,
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }
      },
    );
  }
}
