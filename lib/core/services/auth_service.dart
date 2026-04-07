import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  static const String _sessionKey = 'current_session';

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user.
  User? get currentUser => _auth.currentUser;

  /// Login with email and password.
  Future<UserModel> login(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return _mapFirebaseUserToModel(credential.user!, isNewUser: false);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register a new user.
  Future<UserModel> signup(String name, String email, String password) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);
      
      return _mapFirebaseUserToModel(credential.user!, isNewUser: true);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with Google.
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      
      return _mapFirebaseUserToModel(userCredential.user!, isNewUser: isNewUser);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception("Google Sign-In failed: $e");
    }
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Logout.
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    
    // Also clear legacy session if any
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  /// Restore session (using Firebase's built-in persistence).
  Future<UserModel?> restoreSession() async {
    final user = _auth.currentUser;
    if (user != null) {
      return _mapFirebaseUserToModel(user, isNewUser: false);
    }
    return null;
  }

  /// Update session metadata (placeholder for future Firestore integration).
  Future<void> updateSession(UserModel user) async {
    // Firebase Auth handles this mostly. This could update Firestore user doc.
  }

  /// Map Firebase User to App UserModel.
  UserModel _mapFirebaseUserToModel(User user, {required bool isNewUser}) {
    return UserModel(
      id: user.uid,
      email: user.email ?? "",
      name: user.displayName ?? "Sacred Soul",
      isNewUser: isNewUser,
    );
  }

  /// Handle Firebase Auth specific errors.
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception("The email address is badly formatted.");
      case 'user-not-found':
        return Exception("No user found with this email.");
      case 'wrong-password':
        return Exception("Incorrect password. Please try again.");
      case 'email-already-in-use':
        return Exception("An account already exists for this email.");
      case 'weak-password':
        return Exception("The password is too weak.");
      case 'user-disabled':
        return Exception("This user has been disabled.");
      case 'operation-not-allowed':
        return Exception("Operation not allowed.");
      default:
        return Exception(e.message ?? "An unknown authentication error occurred.");
    }
  }
}
