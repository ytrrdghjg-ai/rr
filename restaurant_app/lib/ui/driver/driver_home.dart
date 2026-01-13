import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../state/session_controller.dart';
import '../../state/theme_controller.dart';

class DriverHome extends ConsumerStatefulWidget {
  const DriverHome({super.key});
  @override
  ConsumerState<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends ConsumerState<DriverHome> {
  LatLng pos = const LatLng(33.5138, 36.2765); // default Damascus-ish
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _pushLocationMock());
  }

  Future<void> _pushLocationMock() async {
    final s = ref.read(sessionProvider);
    if (s.supabaseUserId == null) return;
    // move slightly for demo
    pos = LatLng(pos.latitude + 0.0002, pos.longitude + 0.0002);

    await Supabase.instance.client.from('driver_locations').upsert({
      'driver_id': s.supabaseUserId,
      'lat': pos.latitude,
      'lng': pos.longitude,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'driver_id');
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السائق'),
        actions: [
          IconButton(onPressed: () => ref.read(themeProvider.notifier).toggle(), icon: const Icon(Icons.brightness_6)),
          IconButton(onPressed: () => ref.read(sessionProvider.notifier).signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: pos, initialZoom: 15),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.res.delivery',
          ),
          MarkerLayer(markers: [
            Marker(
              point: pos,
              width: 48,
              height: 48,
              child: const Icon(Icons.directions_bike, size: 36),
            ),
          ]),
        ],
      ),
    );
  }
}
