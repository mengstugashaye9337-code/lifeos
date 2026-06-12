import 'dart:async';
import 'package:flutter/foundation.dart';

/// Converts any Stream into a ChangeNotifier.
/// GoRouter's refreshListenable accepts a Listenable —
/// this bridges the gap between Riverpod streams and GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // notify once on creation
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
