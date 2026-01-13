import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool isLogin = true;
  bool loading = false;
  String? err;

  Future<void> _submit() async {
    setState(() { loading = true; err = null; });
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text.trim(), password: pass.text);
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text.trim(), password: pass.text);
      }
      if (!mounted) return;
      context.go('/customer'); // role-based redirect handled on reload; this is a fast path
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'تسجيل الدخول' : 'إنشاء حساب')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: email, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
            const SizedBox(height: 12),
            TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور')),
            const SizedBox(height: 12),
            if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _submit,
                child: Text(loading ? '...' : (isLogin ? 'دخول' : 'إنشاء')),
              ),
            ),
            TextButton(
              onPressed: loading ? null : () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? 'ما عندي حساب' : 'عندي حساب'),
            ),
            const Divider(),
            const Text('ملاحظة: تعيين دور admin/driver يتم من Supabase (عمود role في جدول users).'),
          ],
        ),
      ),
    );
  }
}
