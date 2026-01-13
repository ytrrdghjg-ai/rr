import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { customer, driver, admin }

class SessionState {
  final bool isAuthed;
  final UserRole role;
  final String? firebaseUid;
  final String? supabaseUserId; // row id in users table

  const SessionState({
    required this.isAuthed,
    required this.role,
    required this.firebaseUid,
    required this.supabaseUserId,
  });

  const SessionState.signedOut() : this(isAuthed: false, role: UserRole.customer, firebaseUid: null, supabaseUserId: null);
}

final sessionProvider = StateNotifierProvider<SessionController, SessionState>((ref) => SessionController());

class SessionController extends StateNotifier<SessionState> {
  SessionController() : super(const SessionState.signedOut()) {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        state = const SessionState.signedOut();
        return;
      }
      await _ensureSupabaseUser(user.uid, user.email);
    });
  }

  Future<void> _ensureSupabaseUser(String firebaseUid, String? email) async {
    final supa = Supabase.instance.client;

    final existing = await supa.from('users').select('id, role').eq('firebase_uid', firebaseUid).maybeSingle();

    if (existing != null) {
      state = SessionState(
        isAuthed: true,
        role: _mapRole(existing['role'] as String?),
        firebaseUid: firebaseUid,
        supabaseUserId: existing['id'] as String?,
      );
      return;
    }

    // default new users as customer
    final inserted = await supa
        .from('users')
        .insert({
          'firebase_uid': firebaseUid,
          'role': 'customer',
          'name': email ?? 'مستخدم',
        })
        .select('id, role')
        .single();

    state = SessionState(
      isAuthed: true,
      role: _mapRole(inserted['role'] as String?),
      firebaseUid: firebaseUid,
      supabaseUserId: inserted['id'] as String?,
    );
  }

  UserRole _mapRole(String? r) {
    switch (r) {
      case 'admin':
        return UserRole.admin;
      case 'driver':
        return UserRole.driver;
      default:
        return UserRole.customer;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
