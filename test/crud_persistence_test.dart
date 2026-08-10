import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_studio_asr/app/app.dart';

void main() {
  testWidgets('app inicia', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LiveStudioApp()));
    expect(find.text('LIVE STUDIO ASR'), findsOneWidget);
    expect(find.text('Cenas'), findsOneWidget);
    expect(find.text('Produtos'), findsOneWidget);
  });
}
