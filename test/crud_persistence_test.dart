import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_studio_asr/features/auth/login_page.dart';
import 'package:live_studio_asr/services/auth_service.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('live_studio_auth_test_');
    await AuthService.initializeForTest(dir.path);
    addTearDown(() async {
      await AuthService.resetTestInitialization();
    });
  });

  test('AuthService accepts the default account and persists session', () async {
    final auth = AuthService();
    await auth.logout();

    expect(await auth.isAuthenticated(), isFalse);

    final success = await auth.login(
      AuthService.defaultUsername,
      AuthService.defaultPassword,
    );

    expect(success, isTrue);
    expect(await auth.isAuthenticated(), isTrue);
    expect(await auth.currentUser(), AuthService.defaultUsername);

    await auth.logout();
    expect(await auth.isAuthenticated(), isFalse);
    expect(await auth.currentUser(), isNull);
  });

  test('AuthService rejects invalid credentials', () async {
    final auth = AuthService();
    await auth.logout();

    final success = await auth.login(
      AuthService.defaultUsername,
      'senha-incorreta',
    );

    expect(success, isFalse);
    expect(await auth.isAuthenticated(), isFalse);
  });

  testWidgets('LoginPage renders and calls onLoggedIn after successful authentication', (tester) async {
    var loggedIn = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          authenticate: (username, password) async =>
              username == AuthService.defaultUsername && password == AuthService.defaultPassword,
          onLoggedIn: () async {
            loggedIn = true;
          },
        ),
      ),
    );

    expect(find.text('LIVE STUDIO ASR'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), AuthService.defaultUsername);
    await tester.enterText(find.byType(TextFormField).at(1), AuthService.defaultPassword);
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(loggedIn, isTrue);
  });
}
