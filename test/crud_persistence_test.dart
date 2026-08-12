import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_studio_asr/app/app.dart';

void main() {
  testWidgets('app inicia e exibe o painel principal', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: LiveStudioApp()));
    await tester.pumpAndSettle();

    expect(find.text('LIVE STUDIO ASR'), findsWidgets);
    expect(find.text('EXEMPLO DE LIVE'), findsOneWidget);
    expect(find.text('Cenas'), findsWidgets);
    expect(find.text('Produtos'), findsWidgets);
  });
}
