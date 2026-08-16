import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_studio_asr/app/app.dart';
import 'package:live_studio_asr/services/auth_service.dart';
import 'package:path/path.dart' as p;

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('live_studio_auth_test_');
    await AuthService.initializeForTest(p.normalize(dir.path));
  });

  testWidgets('app exige login e então exibe o painel principal', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final auth = AuthService();
    await auth.logout();

    await tester.pumpWidget(const ProviderScope(child: LiveStudioApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('LIVE STUDIO ASR'), findsWidgets);
    expect(find.text('Entrar'), findsOneWidget);

    await tester.tap(find.text('Entrar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('EXEMPLO DE LIVE'), findsOneWidget);
    expect(find.text('Cenas'), findsWidgets);
    expect(find.text('Produtos'), findsWidgets);
  });
}
