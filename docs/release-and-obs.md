# Release, Android e OBS — LIVE STUDIO ASR

## Builds

A workflow de artefatos executa automaticamente no push da branch `feature/live-studio-asr`:

- `flutter analyze`
- `flutter test --coverage`
- `flutter build web --release`
- `flutter build apk --release`
- `flutter build appbundle --release`

O workflow gera a estrutura Android/Web com `flutter create` dentro do runner, evitando manter arquivos de plataforma gerados no repositório quando eles não forem necessários ao código-fonte.

Os artefatos ficam disponíveis na execução do GitHub Actions.

## Android release

O APK e o AAB do CI são artefatos de validação e não estão configurados com uma chave de assinatura de produção. Para publicação na Play Store, configure um keystore e as credenciais de assinatura como secrets do ambiente de produção. Nunca coloque keystore, senha ou arquivo de credenciais no Git.

Secrets recomendados para uma futura etapa de assinatura:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

## Ícones e splash

Os assets de identidade ficam em `assets/branding/`. A geração final de ícones adaptativos Android pode ser feita durante a preparação do pacote de produção sem alterar a identidade visual do aplicativo.

## OBS WebSocket

`lib/core/obs/obs_adapter.dart` implementa o protocolo OBS WebSocket v5 diretamente.

Padrão de conexão:

- Host: `localhost`
- Porta: `4455`
- Senha: opcional, conforme a configuração do OBS

A autenticação segue o desafio/salt do OBS WebSocket v5. O adapter expõe `connect`, `disconnect` e `call` para comandos RPC.

Para uso real, o computador/dispositivo que executa o aplicativo precisa conseguir alcançar o endpoint do OBS. Em Web, o navegador também estará sujeito às regras de rede e segurança do ambiente.

## GitHub Actions

O CI usa apenas `GITHUB_TOKEN` implícito para leitura do repositório e upload de artifacts. Nenhum segredo de OBS ou Android é armazenado no código.

## Promoção para main

A branch `feature/live-studio-asr` permanece separada de `main`. A promoção deve ocorrer através do Pull Request, depois de confirmar CI e builds verdes.
