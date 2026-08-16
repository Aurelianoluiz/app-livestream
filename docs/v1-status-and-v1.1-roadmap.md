# LIVE STUDIO ASR — V1 Status e Roadmap V1.1

## V1 — estado encerrado

Versão: `1.0.0+1`

A V1 foi validada no GitHub Actions com análise, testes, build Web, APK e AAB. O Web Preview também foi publicado com sucesso no GitHub Pages.

### Validado

- Dashboard operacional.
- Cenas, Produtos, Ofertas, Transmissões, Overlays e Biblioteca de Mídia.
- Persistência local com Hive.
- Login local da V1.
- Integração real com OBS WebSocket 5.x.
- Controles de transmissão e troca de cena via OBS.
- Reconexão automática conforme a configuração da sessão.
- Testes de regressão para `LiveRecord` e operações do CRUD.
- CI, build Web e publicação GitHub Pages.
- Builds Android de validação.

## Pendências explicitamente fora da V1

- Assinatura Android de produção e publicação Google Play.
- Autenticação de servidor para produção/comercialização.
- Teste operacional com uma instalação física do OBS deve ser feito no ambiente final do usuário.

## V1.1 — prioridades

1. Autenticação e usuários via backend seguro.
2. Exportação/importação e backup das configurações e dados locais.
3. Monitoramento operacional mais detalhado da conexão OBS.
4. Melhorias de métricas e histórico das transmissões.
5. Refinamento de acessibilidade e responsividade.
6. Preparação de release Android assinado quando o processo de publicação for autorizado.

## Regra de release

Nenhuma mudança da V1.1 deve reabrir correções já aprovadas sem uma falha de regressão comprovada.

Toda alteração deve passar por:

`flutter analyze` → `flutter test` → build Web → build Android → Web Preview/Pages.
