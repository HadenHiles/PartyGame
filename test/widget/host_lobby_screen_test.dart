import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/services/room_service.dart';
import 'package:partygames/screens/host/host_lobby_screen.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('HostLobbyScreen', () {
    setUp(() {
      RoomService.use(MemoryRoomService());
    });

    testWidgets('shows room code and players, starts round', (tester) async {
      final svc = RoomService();
      final hostUid = 'host-1';
      final code = await svc.createRoom(hostUid: hostUid, hostDisplayName: 'Hosty');
      await svc.joinRoom(code: code, uid: 'p2', displayName: 'Pat');

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => HostLobbyScreen(code: code),
          ),
          GoRoute(path: '/host/round/:code', builder: (_, __) => const Placeholder()),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Room code shown
      expect(find.text(code), findsOneWidget);

      // Players list appears (at least one player entry by name)
      await tester.pump();
      expect(find.text('Hosty'), findsOneWidget);
      expect(find.text('Pat'), findsOneWidget);

      // Tap start round
      await tester.tap(find.text('START ROUND 1'));
      await tester.pump();

      // Memory service updates roomStream to phase=author; UI should show Phase: author
      expect(find.textContaining('Phase: author'), findsOneWidget);
    });
  });
}
