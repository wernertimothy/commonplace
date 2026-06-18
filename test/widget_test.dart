import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:commonplace/main.dart';

void main() {
  testWidgets('App boots to the Projects screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CommonplaceApp()));
    await tester.pump();

    expect(find.text('Projects'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
