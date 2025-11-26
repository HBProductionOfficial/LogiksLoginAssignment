import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate({String reason = 'Please authenticate'}) async {
    try {
      // Newer local_auth API (2.2+): use `options`
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,     // set false to allow device PIN fallback
          stickyAuth: true,        // keeps auth active when app goes background
          useErrorDialogs: true,   // shows system dialogs
        ),
      );
    } on PlatformException catch (e) {
      // Common codes: notAvailable, notEnrolled, passcodeNotSet, lockedOut, permanentlyLockedOut
      // You can surface e.code/e.message to the UI if needed.
      return false;
    }
  }

  Future<void> cancel() => _auth.stopAuthentication();
}