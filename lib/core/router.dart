import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/shell/responsive_shell.dart';
import '../presentation/views/placeholder_view.dart';
import '../presentation/views/business_profile_view.dart';

import '../presentation/views/customers_view.dart';
import '../presentation/views/customer_form_view.dart';
import '../presentation/views/customer_detail_view.dart';

import '../presentation/views/dashboard_view.dart';
import '../presentation/views/catalogue_view.dart';
import '../presentation/views/item_form_view.dart';
import '../presentation/views/pos_view.dart';
import '../presentation/views/profit_loss_view.dart';
import '../presentation/views/back_office_view.dart';
import '../presentation/views/document_list_view.dart';
import '../presentation/views/document_form_view.dart';
import '../presentation/views/settings_view.dart';

final _shellNavigatorDashboardKey = GlobalKey<NavigatorState>(
  debugLabel: 'dashboard',
);
final _shellNavigatorCustomersKey = GlobalKey<NavigatorState>(
  debugLabel: 'customers',
);
final _shellNavigatorCatalogueKey = GlobalKey<NavigatorState>(
  debugLabel: 'catalogue',
);
final _shellNavigatorPOSKey = GlobalKey<NavigatorState>(debugLabel: 'pos');
final _shellNavigatorDocumentsKey = GlobalKey<NavigatorState>(
  debugLabel: 'documents',
);
final _shellNavigatorBackOfficeKey = GlobalKey<NavigatorState>(
  debugLabel: 'backoffice',
);
final _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(
  debugLabel: 'settings',
);

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ResponsiveShell(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDashboardKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardView(),
                routes: [
                  GoRoute(
                    path: 'pl',
                    builder: (context, state) => const ProfitLossView(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCustomersKey,
            routes: [
              GoRoute(
                path: '/customers',
                builder: (context, state) => const CustomersView(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) =>
                        const CustomerFormView(customerId: 'new'),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => CustomerDetailView(
                      customerId: int.parse(state.pathParameters['id']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => CustomerFormView(
                          customerId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCatalogueKey,
            routes: [
              GoRoute(
                path: '/catalogue',
                builder: (context, state) => const CatalogueView(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) =>
                        const ItemFormView(itemId: 'new'),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) =>
                        ItemFormView(itemId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorPOSKey,
            routes: [
              GoRoute(
                path: '/pos',
                builder: (context, state) => const PosView(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDocumentsKey,
            routes: [
              GoRoute(
                path: '/documents',
                builder: (context, state) => const DocumentListView(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => DocumentFormView(
                      documentType: state.extra as String? ?? 'quote',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorBackOfficeKey,
            routes: [
              GoRoute(
                path: '/back-office',
                builder: (context, state) => const BackOfficeView(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsView(),
                routes: [
                  GoRoute(
                    path: 'business_profile',
                    builder: (context, state) => const BusinessProfileView(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
