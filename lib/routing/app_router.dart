import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/host/host_lobby_screen.dart';
import '../screens/player/join_screen.dart';
import '../screens/player/player_waiting_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'join',
      builder: (BuildContext context, GoRouterState state) => const JoinScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'host/:code',
          name: 'host',
          builder: (context, state) => HostLobbyScreen(code: state.pathParameters['code'] ?? '----'),
        ),
        GoRoute(
          path: 'wait/:code',
          name: 'wait',
          builder: (context, state) => PlayerWaitingScreen(code: state.pathParameters['code'] ?? '----'),
        ),
      ],
    ),
  ],
);
