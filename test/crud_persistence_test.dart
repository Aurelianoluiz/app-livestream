import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_studio_asr/app/app.dart';

void main() {
  testWidgets('app inicia e exibe o painel principal', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: LiveStudioApp()));
    // Avoid pumpAndSettle here because the app can keep framework animations
    // or async persistence work alive. Advance enough frames for the initial
    // dashboard and seeded data to render without waiting indefinitely.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('LIVE STUDIO ASR'), findsWidgets);
    expect(find.text('EXEMPLO DE LIVE'), findsOneWidget);
    expect(find.text('Cenas'), findsWidgets);
    expect(find.text('Produtos'), findsWidgets);
  });
}
