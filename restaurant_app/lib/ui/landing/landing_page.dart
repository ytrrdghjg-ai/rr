import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _pc = PageController();
  int _i = 0;

  final slides = const [
    ('اطلب بسرعة', 'اختَر وجبتك خلال ثواني'),
    ('توصيل احترافي', 'سائقين جاهزين لتوصيل طلبك'),
    ('إشعارات فورية', 'تأكيد، تجهيز، بالطريق، تم التسليم'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pc,
                itemCount: slides.length,
                onPageChanged: (v) => setState(() => _i = v),
                itemBuilder: (c, idx) {
                  final s = slides[idx];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fastfood, size: 96),
                        const SizedBox(height: 24),
                        Text(s.$1, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 12),
                        Text(s.$2, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (j) => Padding(
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(radius: 4, backgroundColor: j == _i ? Theme.of(context).colorScheme.primary : Colors.grey),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('تسجيل الدخول / إنشاء حساب'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
