import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/host/host_lobby_screen.dart';
import '../screens/host/host_round_screen.dart';
import '../screens/player/join_screen.dart';
import '../screens/player/player_waiting_screen.dart';
import '../screens/player/r1_author_screen.dart';

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
          path: 'host/round/:code',
          name: 'hostRound',
          builder: (context, state) => HostRoundScreen(code: state.pathParameters['code'] ?? '----'),
        ),
        GoRoute(
          path: 'wait/:code',
          name: 'wait',
          builder: (context, state) => PlayerWaitingScreen(code: state.pathParameters['code'] ?? '----'),
        ),
        GoRoute(
          path: 'r1/author/:code',
          name: 'r1Author',
          builder: (context, state) => R1AuthorScreen(code: state.pathParameters['code'] ?? '----'),
        ),
      ],
    ),
  ],
);
