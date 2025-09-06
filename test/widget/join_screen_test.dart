import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:partygames/services/room_service.dart';
import 'package:partygames/screens/player/join_screen.dart';

void main() {
  group('JoinScreen', () {
    setUp(() {
      RoomService.use(MemoryRoomService());
    });

    testWidgets('host flow navigates to host route', (tester) async {
      // Router to capture navigation
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

      await tester.enterText(find.byType(TextField).first, 'Hosty');
      await tester.tap(find.text('HOST GAME'));
      await tester.pump(); // start async
      await tester.pump(const Duration(milliseconds: 100)); // allow navigation

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

      final textFields = find.byType(TextField);
      // First is name, second is code
      await tester.enterText(textFields.at(0), 'PlayerX');
      await tester.enterText(textFields.at(1), lower);
      await tester.tap(find.text('JOIN GAME'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Wait:$code'), findsOneWidget); // should show uppercase original
    });
  });
}
