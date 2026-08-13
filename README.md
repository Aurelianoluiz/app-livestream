# LIVE STUDIO ASR

Painel Flutter multiplataforma para organização profissional de transmissões ao vivo, com Web + Android e módulos de Cenas, Produtos, Ofertas, Transmissões, Overlays, Biblioteca de Mídia e Configurações.

## Estado atual

- Flutter + Material 3.
- Riverpod para estado da interface.
- Hive para persistência local das coleções e configurações.
- Exemplos visuais locais para todos os módulos.
- `flutter_svg` para renderização correta das artes SVG.
- Adapter OBS WebSocket preparado sem simulação de conexão.
- GitHub Actions para CI, Web Preview e builds Android.
- GitHub Pages publicado para o preview Web.
- Identidade ativa: **LIVE STUDIO ASR**.

## Preview Web

https://aurelianoluiz.github.io/app-livestream/

## Execução local

Na primeira preparação do projeto, gere as plataformas Flutter que não estiverem presentes:

```bash
flutter create --platforms web,android --org com.asr.live_studio --project-name live_studio_asr .
flutter pub get
flutter analyze
flutter test --coverage
flutter run -d chrome
```

Builds de distribuição:

```bash
flutter build web --release
flutter build apk --release
flutter build appbundle --release
```

## Web

O workflow `.github/workflows/web-preview.yml` gera o projeto Web quando necessário, executa análise/testes, cria o build release e publica no GitHub Pages.

## Android

O workflow `.github/workflows/build-artifacts.yml` prepara a plataforma Android e gera APK/AAB. Para publicação na Google Play, configure uma assinatura de produção com keystore e os secrets correspondentes no GitHub Actions; nenhum segredo é armazenado no código.

## OBS Studio

Configure em **Configurações → OBS Studio**:

- Host: normalmente `localhost` quando o OBS está no mesmo computador.
- Porta: `4455` para OBS WebSocket 5.x.
- Senha: a mesma configurada no OBS.
- Reconexão automática: preferência do usuário.

A aplicação não considera o OBS conectado sem uma conexão real.

## Biblioteca e exemplos

Os exemplos ficam em `assets/illustrations/` e `assets/images/` e são carregados localmente, sem dependência de CDN ou URLs externas.

## Estrutura

- `lib/`: código da aplicação.
- `lib/features/`: telas e módulos.
- `lib/providers/`: estado e persistência.
- `lib/services/`: armazenamento Hive.
- `lib/core/obs/`: integração OBS.
- `assets/`: branding, imagens, ilustrações, overlays e templates.
- `test/`: testes automatizados.
- `docs/`: documentação de uso e release.
- `.github/workflows/`: CI, build e preview.

## Marca

A identidade ativa do projeto é exclusivamente **LIVE STUDIO ASR**. O relatório da varredura da marca antiga está em `analysis/occurrences-report.txt`.
