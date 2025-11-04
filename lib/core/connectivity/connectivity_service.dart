import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();
  static final instance = ConnectivityService._();

  final _controller = StreamController<bool>.broadcast();
  bool _online = true;

  bool get isOnline => _online;
  Stream<bool> get onlineStream => _controller.stream;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  Future<void> start() async {
    final initial = await Connectivity().checkConnectivity(); // List<ConnectivityResult>
    _online = _fromResults(initial);
    _controller.add(_online);

    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final now = _fromResults(results);
      if (now != _online) {
        _online = now;
        _controller.add(_online);
      }
    });
  }

  bool _fromResults(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}

