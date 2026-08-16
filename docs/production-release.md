# LIVE STUDIO ASR — Production Release Checklist

## Estado atual

- Flutter application version: `1.0.0+1`
- Web build: validated by CI
- Android APK: validated by CI
- Android AAB: validated by CI
- GitHub Pages: validated by CI
- Production Android signing: **NOT CONFIGURED**

## Antes da publicação na Google Play

1. Criar uma keystore de produção fora do repositório.
2. Nunca versionar a keystore, senha ou alias.
3. Configurar os segredos necessários no GitHub Actions.
4. Criar `android/key.properties` apenas durante o workflow ou localmente, conforme a estratégia de CI.
5. Alterar `android/app/build.gradle` para usar `signingConfigs.release` quando os segredos de produção estiverem disponíveis.
6. Gerar novamente o AAB de release assinado.
7. Conferir `applicationId`, `versionCode` e `versionName` antes do upload.
8. Fazer teste de instalação do APK/AAB em ambiente de homologação.

## Segurança

Não coloque no GitHub:

- keystore `.jks` / `.keystore`;
- senhas de keystore;
- credenciais do OBS;
- tokens de APIs;
- arquivos `.env` com segredos.

## CI/CD

Os workflows atuais validam análise, testes e builds. A assinatura de produção deve ser adicionada somente quando os secrets de publicação estiverem configurados.

## Critério de conclusão da publicação Android

A publicação Android somente deve ser considerada **PRODUÇÃO** quando o AAB estiver assinado com a chave de lançamento da aplicação. O AAB atual é válido como artefato de build/homologação, mas não deve ser apresentado como AAB de produção assinado.
