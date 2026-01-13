import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'state/session_controller.dart';
import 'ui/landing/landing_page.dart';
import 'ui/auth/login_page.dart';
import 'ui/customer/customer_home.dart';
import 'ui/admin/admin_home.dart';
import 'ui/driver/driver_home.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);

  String initial = '/landing';
  if (session.isAuthed) {
    initial = session.role == UserRole.admin
        ? '/admin'
        : session.role == UserRole.driver
            ? '/driver'
            : '/customer';
  }

  return GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(path: '/landing', builder: (c, s) => const LandingPage()),
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      GoRoute(path: '/customer', builder: (c, s) => const CustomerHome()),
      GoRoute(path: '/driver', builder: (c, s) => const DriverHome()),
      GoRoute(path: '/admin', builder: (c, s) => const AdminHome()),
    ],
  );
});
