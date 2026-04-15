import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Sahi package name aur main.dart import
import 'package:aastrosphere/main.dart'; 

void main() {
  testWidgets('Aastrosphere smoke test', (WidgetTester tester) async {
    // 1. MyApp ki jagah AastrosphereApp use karein
    // 2. ProviderScope zaroori hai kyunki app Riverpod use karti hai
    await tester.pumpWidget(
      const ProviderScope(
        child: AastrosphereApp(),
      ),
    );

    // 3. Verify that the app starts (MaterialApp mil raha hai ya nahi)
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Note: Agar aapko Splash Screen se aage badhna hai test mein:
    // await tester.pump(const Duration(seconds: 3)); 
  });
}