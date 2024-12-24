import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_4/models/user.dart' as app_user;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    return await _supabase.auth
        .signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmailPassword(
      String email, String password, String name, String phone) async {
    final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone_number': phone});
    return response;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  app_user.User? getCurrentUser() {
    final session = _supabase.auth.currentSession;
    final supabase_user = session?.user;
    final trimmedEmail = supabase_user?.email?.trim().toLowerCase();
    final emailHash = trimmedEmail != null
        ? md5.convert(utf8.encode(trimmedEmail)).toString()
        : '';

    return app_user.User(
        supabase_user?.userMetadata?["name"] as String? ?? "anon",
        supabase_user?.email ?? '',
        supabase_user?.userMetadata?["phone_number"] as String? ?? '',
        emailHash.isEmpty
            ? 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fthumbs.dreamstime.com%2Fb%2Fdefault-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg&f=1&nofb=1&ipt=5a3b8df2fbe61251fb5d0c178caf961f7fe07fce4bada9d2fc824089aa650a47&ipo=images'
            : 'https://www.gravatar.com/avatar/$emailHash');
  }

  Future<void> updateUserProfile(
      String name, String phone, String email) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await _supabase.from('profiles').upsert(
          {'id': user.id, 'name': name, 'phone_number': phone, 'email': email});
    }
  }
}
