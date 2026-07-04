// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gupta_capitals/pages/user_dashboard.dart';

void main() {
  testWidgets('User dashboard shows rent and broker details', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: UserDashboard()));

    expect(find.text('Welcome back, Rohan'), findsOneWidget);
    expect(find.text('Monthly Rent'), findsOneWidget);
    expect(find.text('Broker Contact'), findsOneWidget);
    expect(find.text('+91 98765 43210'), findsOneWidget);
    expect(find.text('Flat 302, Rosewood Apartments'), findsOneWidget);
  });
}
