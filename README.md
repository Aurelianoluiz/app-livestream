# LIVE STUDIO ASR

Painel Flutter para organização de transmissões ao vivo, com módulos de Cenas, Produtos, Ofertas, Transmissões, Overlays e Mídia.

## Estado V1

- Flutter + Material 3.
- Riverpod para estado da interface.
- Hive disponível como camada de persistência para coleções simples.
- Arquitetura de integração OBS mantida em `lib/core/obs/obs_adapter.dart` como adapter/stub; nenhuma conexão falsa é simulada.
- Workflows de CI e build preparados em `.github/workflows/`.

## Execução

```bash
flutter pub get
flutter analyze
flutter test --coverage
flutter build web --release
flutter build apk --release
flutter build appbundle --release
```

O workflow de artefatos executa `flutter create --platforms web,android .` quando as pastas de plataforma ainda não existem.

## Estrutura

O código de aplicação fica em `lib/`, testes em `test/`, documentação em `docs/` e ativos em `assets/`.

## Marca

A identidade ativa do projeto é exclusivamente **LIVE STUDIO ASR**. A verificação de ocorrências da marca antiga é registrada em `analysis/occurrences-report.txt`.
