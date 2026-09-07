import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clod/presentation/shell/responsive_shell.dart';

void main() {
  testWidgets('ResponsiveShell uses NavigationBar on narrow screens', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(MaterialApp(
      home: ResponsiveShell(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child: const Text('Body'),
      ),
    ));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('ResponsiveShell uses NavigationRail on wide screens', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(MaterialApp(
      home: ResponsiveShell(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child: const Text('Body'),
      ),
    ));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
