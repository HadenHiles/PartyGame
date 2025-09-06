import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:partygames/services/room_service.dart';
import 'package:partygames/screens/player/join_screen.dart';

Future<void> pumpTransition(WidgetTester tester) async {
  // Allow a few frames for AnimatedSwitcher (250ms configured) without waiting forever
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  group('JoinScreen', () {
    setUp(() {
      RoomService.use(MemoryRoomService());
    });

    testWidgets('host flow navigates to host route after selection', (tester) async {
      late GoRouter router;
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const JoinScreen(),
            routes: [GoRoute(path: 'host/:code', builder: (_, state) => Text('Host:${state.pathParameters['code']}'))],
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Select host mode
      await tester.tap(find.text('HOST A GAME'));
      await pumpTransition(tester);

      // Enter optional name and create
      await tester.enterText(find.byType(TextField).first, 'Hosty');
      await tester.tap(find.text('CREATE ROOM'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.textContaining('Host:'), findsOneWidget);
    });

    testWidgets('join flow navigates to wait route with uppercase code', (tester) async {
      final svc = RoomService();
      final code = await svc.createRoom();
      final lower = code.toLowerCase();

      late GoRouter router;
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const JoinScreen(),
            routes: [GoRoute(path: 'wait/:code', builder: (_, state) => Text('Wait:${state.pathParameters['code']}'))],
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Select join mode
      await tester.tap(find.text('JOIN A GAME'));
      await pumpTransition(tester);

      // Two text fields: name then code
      final tfs = find.byType(TextField);
      await tester.enterText(tfs.at(0), 'PlayerX');
      await tester.enterText(tfs.at(1), lower);
      await tester.tap(find.text('JOIN ROOM'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.text('Wait:$code'), findsOneWidget);
    });

    testWidgets('back navigation returns to selection screen', (tester) async {
      late GoRouter router;
      router = GoRouter(
        routes: [GoRoute(path: '/', builder: (_, __) => const JoinScreen())],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Enter join mode
      await tester.tap(find.text('JOIN A GAME'));
      await pumpTransition(tester);
      expect(find.text('Join a Game'), findsOneWidget);

      // Tap back arrow
      await tester.tap(find.byIcon(Icons.arrow_back));
      await pumpTransition(tester);
      expect(find.text('How do you want to start?'), findsOneWidget);

      // Go host mode and back
      await tester.tap(find.text('HOST A GAME'));
      await pumpTransition(tester);
      expect(find.text('Host a Game'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await pumpTransition(tester);
      expect(find.text('How do you want to start?'), findsOneWidget);
    });
  });
}
