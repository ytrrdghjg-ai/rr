import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../state/session_controller.dart';
import '../../state/theme_controller.dart';

class AdminHome extends ConsumerStatefulWidget {
  const AdminHome({super.key});
  @override
  ConsumerState<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends ConsumerState<AdminHome> {
  final Map<String, LatLng> drivers = {};
  RealtimeChannel? _ch;

  @override
  void initState() {
    super.initState();
    _listenDrivers();
  }

  Future<void> _listenDrivers() async {
    final supa = Supabase.instance.client;

    // seed with current locations
    final rows = await supa.from('driver_locations').select('driver_id,lat,lng');
    for (final r in (rows as List).cast<Map>()) {
      drivers['${r['driver_id']}'] = LatLng(
        (r['lat'] as num).toDouble(),
        (r['lng'] as num).toDouble(),
      );
    }
    if (mounted) setState(() {});

    // IMPORTANT: subscribe returns RealtimeChannel (not StreamSubscription)
    _ch = supa
        .channel('admin_driver_locations')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'driver_locations',
          callback: (payload) {
            final rec = payload.newRecord;

            final id = rec['driver_id']?.toString();
            final lat = rec['lat'];
            final lng = rec['lng'];
            if (id == null || lat == null || lng == null) return;

            drivers[id] = LatLng((lat as num).toDouble(), (lng as num).toDouble());
            if (mounted) setState(() {});
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    final supa = Supabase.instance.client;
    if (_ch != null) {
      _ch!.unsubscribe();
      // بعض نسخ supabase_flutter: removeChannel موجود على realtime
      supa.realtime.removeChannel(_ch!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = drivers.values.toList();
    final center = points.isNotEmpty ? points.first : const LatLng(33.5138, 36.2765);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        actions: [
          IconButton(
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
            icon: const Icon(Icons.brightness_6),
          ),
          IconButton(
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 13),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.res.delivery',
                ),
                MarkerLayer(
                  markers: drivers.entries.map((e) {
                    return Marker(
                      point: e.value,
                      width: 48,
                      height: 48,
                      child: const Icon(Icons.location_on, size: 38),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('السائقين المتصلين: ${drivers.length}'),
          ),
        ],
      ),
    );
  }
}
