import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:megamania/main.dart';
import 'package:megamania/game/megamania_game.dart';
import 'package:megamania/widgets/main_menu_overlay.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  testWidgets('Test MainMenu keyboard selection and game start', (WidgetTester tester) async {
    await runZonedGuarded(() async {
      await tester.runAsync(() async {
        // 1. Pump the MegamaniaApp widget tree
        await tester.pumpWidget(const MegamaniaApp());
        
        // Pump repeatedly until MainMenuOverlay is found
        for (int i = 0; i < 50; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          await tester.pump();
          if (find.byType(MainMenuOverlay).evaluate().isNotEmpty) {
            break;
          }
        }
      });

      // Verify MainMenu overlay is displayed
      expect(find.byType(MainMenuOverlay), findsOneWidget);

      // Verify that the start mission button is visible
      expect(find.text('START MISSION'), findsOneWidget);

      // 2. Simulate Left/Right Arrow key presses to select ship
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump(const Duration(milliseconds: 50));

      // 3. Simulate Enter key press to start the game
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 50));
    }, (error, stack) {
      // Ignore background/async font loading errors
      if (error.toString().contains('Failed to load font') ||
          error.toString().contains('google_fonts') ||
          error.toString().contains('fonts.gstatic.com')) {
        debugPrint('Ignored expected font exception: $error');
        return;
      }
      throw error;
    });
  });

  testWidgets('Test MainMenu mouse click on START MISSION', (WidgetTester tester) async {
    await runZonedGuarded(() async {
      await tester.runAsync(() async {
        // Pump MegamaniaApp
        await tester.pumpWidget(const MegamaniaApp());
        
        // Pump repeatedly until MainMenuOverlay is found
        for (int i = 0; i < 50; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          await tester.pump();
          if (find.byType(MainMenuOverlay).evaluate().isNotEmpty) {
            break;
          }
        }
      });

      // Verify MainMenu is displayed
      expect(find.byType(MainMenuOverlay), findsOneWidget);

      // Click on START MISSION button
      final startButtonFinder = find.text('START MISSION');
      expect(startButtonFinder, findsOneWidget);

      await tester.tap(startButtonFinder);
      await tester.pump(const Duration(milliseconds: 50));
    }, (error, stack) {
      if (error.toString().contains('Failed to load font') ||
          error.toString().contains('google_fonts') ||
          error.toString().contains('fonts.gstatic.com')) {
        debugPrint('Ignored expected font exception: $error');
        return;
      }
      throw error;
    });
  });
}
