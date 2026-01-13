import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../state/session_controller.dart';
import '../../state/theme_controller.dart';

class CustomerHome extends ConsumerWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الزبون'),
        actions: [
          IconButton(onPressed: () => ref.read(themeProvider.notifier).toggle(), icon: const Icon(Icons.brightness_6)),
          IconButton(onPressed: () => ref.read(sessionProvider.notifier).signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: FutureBuilder(
        future: Supabase.instance.client.from('products').select('id,name,price,image_url').eq('is_active', true),
        builder: (c, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final rows = (snap.data as List).cast<Map>();
          if (rows.isEmpty) return const Center(child: Text('لا توجد منتجات بعد. أضف منتجات من لوحة الإدارة.'));
          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (c, i) {
              final r = rows[i];
              return ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: Text('${r['name']}'),
                subtitle: Text('السعر: ${r['price']}'),
                onTap: () async {
                  // very simple "create order" demo
                  if (session.supabaseUserId == null) return;
                  await Supabase.instance.client.from('orders').insert({
                    'customer_id': session.supabaseUserId,
                    'status': 'pending',
                    'total': r['price'],
                    'address_text': 'عنوان تجريبي (عدّله لاحقاً)',
                    'lat': 0,
                    'lng': 0,
                  });
                  if (c.mounted) {
                    ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('تم إنشاء طلب (pending)')));
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
