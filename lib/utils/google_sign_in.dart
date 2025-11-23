import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:netconnect/utils/google_credentials.dart';

class GoogleSignInHelper {
  static const List<String> scopes = [
    'email',
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive.file',
    'https://www.googleapis.com/auth/calendar.app.created',
    'https://www.googleapis.com/auth/calendar.calendarlist.readonly',
    'https://www.googleapis.com/auth/calendar.events.public.readonly',
  ];

  static final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: clientId,
    scopes: scopes,
  );

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<AuthClient> getAuthenticatedClient() async {
    // Check if we have a current user
    var account = googleSignIn.currentUser;
    if (account == null) {
      // Try silent sign-in first
      account = await googleSignIn.signInSilently();
    }
    if (account == null) {
      throw Exception('User not signed in');
    }
    final client = await googleSignIn.authenticatedClient();
    if (client == null) {
      throw Exception('Failed to get authenticated client');
    }
    return client;
  }

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      return await googleSignIn.signIn();
    } catch (error) {
      print('Error signing in: $error');
      rethrow;
    }
  }

  static Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await googleSignIn.signIn();
    } catch (error) {
      print('Error signing in silently: $error');
      return null;
    }
  }

  static Future<GoogleSignInAccount?> signOut() async {
    return await googleSignIn.signOut();
  }
}
