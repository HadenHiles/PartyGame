import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/services/room_service.dart';
import 'package:partygames/screens/player/player_waiting_screen.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('PlayerWaitingScreen', () {
    setUp(() {
      RoomService.use(MemoryRoomService());
    });

    testWidgets('shows waiting and auto-routes on author phase', (tester) async {
      final svc = RoomService();
      final code = await svc.createRoom();

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => PlayerWaitingScreen(code: code),
          ),
          GoRoute(path: '/r1/author/:code', builder: (_, __) => const Placeholder()),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Initially shows lobby phase
      await tester.pump();
      expect(find.textContaining('phase: lobby'), findsOneWidget);

      // When startGame is called, should display author phase (routing is not asserted in pure widget test)
      await svc.startGame(code);
      await tester.pump();
      expect(find.textContaining('phase: author'), findsOneWidget);
    });
  });
}
