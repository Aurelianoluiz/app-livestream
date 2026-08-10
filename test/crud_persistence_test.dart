import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_studio_asr/app/app.dart';
void main(){testWidgets('app inicia', (tester) async { await tester.pumpWidget(const ProviderScope(child: LiveStudioApp())); expect(find.text('LIVE STUDIO ASR'), findsOneWidget); });}
