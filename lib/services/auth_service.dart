import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_4/models/user.dart' as app_user;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signUpWithEmailPassword(
      String email, String password, String name, String phone) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await credential.user!.updateDisplayName(name);
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'phone_number': phone,
      'email': email,
    });
    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<app_user.User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    await Future.delayed(const Duration(seconds: 1));

    final doc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final trimmedEmail = firebaseUser.email?.trim().toLowerCase();
      final emailHash = trimmedEmail != null
          ? md5.convert(utf8.encode(trimmedEmail)).toString()
          : '';

      return app_user.User(
        data['name'] ?? "anon",
        firebaseUser.email ?? '',
        data['phone_number'] ?? '',
        emailHash.isEmpty
            ? 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fthumbs.dreamstime.com%2Fb%2Fdefault-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg&f=1&nofb=1&ipt=5a3b8df2fbe61251fb5d0c178caf961f7fe07fce4bada9d2fc824089aa650a47&ipo=images'
            : 'https://www.gravatar.com/avatar/$emailHash',
      );
    } else {
      return null;
    }
  }

  Future<void> updateUserProfile(
      String name, String phone, String email) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.updateEmail(email);
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'phone_number': phone,
        'email': email,
      });
    }
  }
}
