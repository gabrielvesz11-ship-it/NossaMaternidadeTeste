# Decisão canônica TheLionGab Nossa/Nath - 2026-05-21

## Sumário executivo

Recomendação objetiva: usar `TheLionGab/nathalia-app` como fonte de verdade operacional do produto Nossa Maternidade/Nath agora. Ele é o repositório mais completo em produto, backend, release, testes, documentação e cobertura iOS/Android.

`TheLionGab/Finaly` deve ficar congelado como referência Swift nativa e possível sucessor iOS-first, mas não deve disputar release enquanto `nathalia-app` estiver ativo com o mesmo bundle ID. Ambos usam `br.com.nossamaternidade.app`, então qualquer submit novo precisa primeiro resolver versionamento/build e ownership da App Store.

Decisão prática: congelar qualquer submit até o plano de colisão abaixo ser aplicado. Depois disso, todo desenvolvimento de produto, backend, EAS, RevenueCat, Supabase, QA e release deve partir de `TheLionGab/nathalia-app`.

## Inventário dos repositórios relacionados

| Repositório | Status | Stack | Papel recomendado |
|---|---|---|---|
| `TheLionGab/nathalia-app` | Ativo, privado | Expo 55, TypeScript, Supabase, RevenueCat, Sentry, PostHog | Canônico operacional |
| `TheLionGab/Finaly` | Ativo, privado | SwiftUI, SwiftData, iOS nativo | Referência Swift / sucessor pausado |
| `TheLionGab/Nossa-Maternidade-NathaliaValente` | Arquivado, privado | Expo/TypeScript | Snapshot histórico; extrair notas se necessário |
| `TheLionGab/NossaMaternidade` | Arquivado, privado | React Native/TypeScript | Snapshot antigo; não usar como fonte |
| `TheLionGab/Nossa-Maternidade` | Arquivado, privado | React Native/TypeScript | Snapshot antigo pesado; não usar como fonte |

Observação de acesso: os clones temporários foram criados em `/tmp/theliongab-nossa-plan.YhLwnZ` enquanto a credencial `TheLionGab` estava ativa. No fim da execução, o `gh` local voltou a expor apenas `gabrielvesz11-ship-it`, então novas consultas privadas a `TheLionGab` falharam. O documento usa evidência dos clones temporários e comandos locais.

## Matriz de decisão

| Critério | `nathalia-app` Expo | `Finaly` Swift | Vencedor |
|---|---|---|---|
| Produto atual | App completo com onboarding, NathIA, Mundo Nath, premium, notificações, auth e release gates | App iOS mais enxuto com gestação, diário, agenda, contrações, onboarding emocional | Expo |
| Plataformas | iOS, Android e web estático via Expo | iOS apenas | Expo |
| Backend | Supabase client, migrations, Edge Functions, nath-chat, notifications, webhook, delete account | Histórico indica app local SwiftData sem Supabase | Expo |
| Pagamentos | RevenueCat via `react-native-purchases`, entitlement e release gate | Plano de integração RevenueCat; não é produto backend completo | Expo |
| Release | EAS build/submit, EAS deploy, CI, release gate, config pública, privacy manifest Expo | Workflow Xcode/TestFlight presente | Expo |
| Testes | 18 suites / 192 testes passando | Build genérico passou; testes unitários parecem placeholder | Expo |
| Qualidade automatizada | Typecheck, Biome, Jest, audit high, Expo config | Xcode build/test workflow; sem barra equivalente de produto/backend | Expo |
| Risco operacional | Node local precisa `>=22 <25`; há 10 vulnerabilidades low/moderate; região Supabase antiga foi marcada como risco | Bundle/build colide com Expo; iOS-only; backend ausente | Expo, com bloqueios |
| Velocidade de mercado | Mais próximo de release multi-plataforma | Requer rebuild de backend, auth, paywall e release | Expo |
| Estratégia iOS-first | Menos nativo, dependente de Expo/EAS | Melhor para app iOS puro e UX nativa | Swift |

Conclusão: `nathalia-app` vence para continuidade operacional e release. `Finaly` só deve vencer se a decisão de negócio for abandonar Android/Expo e reiniciar como produto exclusivamente iOS nativo.

## Evidência técnica

### `TheLionGab/nathalia-app`

- `package.json`: Expo 55, React Native 0.83.6, TypeScript 5.9, Supabase, RevenueCat, Sentry, PostHog, React Query, Expo Router e scripts de release.
- `.github/workflows`: CI com typecheck, Biome, Jest, audit high, Expo config/export; workflow manual de EAS Build; workflows Claude.
- `app.config.ts`: bundle iOS `br.com.nossamaternidade.app`, Android package igual, Apple Sign-In, associated domains, privacy manifests, Expo Updates e EAS project ID.
- `supabase/`: migrations `001` a `016`, Edge Functions `nath-ai`, `nath-chat`, notifications, webhook e delete account.
- `docs/release-gate.md`: gate operacional completo para code freeze, infra, build, QA físico, assinatura, push, observabilidade e GO/NO-GO.
- `docs/known-landmines.md`: riscos conhecidos, arquivos sensíveis, limitações Expo/EAS/RN, Supabase e merge.
- Validação local em clone temporário:
  - `npm ci`: passou, com aviso de engine porque o ambiente usa Node 26 e o projeto exige `>=22 <25`; audit report mostrou 10 vulnerabilidades low/moderate.
  - `npm run typecheck`: passou.
  - `npm run lint`: passou, 116 arquivos checados.
  - `npm run test:ci`: passou, 18 suites e 192 testes; há warnings de `act(...)` em alguns testes.
  - `npm run config:check`: passou e confirmou config pública.
  - `npm run audit:high`: passou; vulnerabilidades observadas são low/moderate.

### `TheLionGab/Finaly`

- `ANALYSIS.md`: registra Swift nativo como sucessor pretendido, mas também registra colisão com o bundle do Expo.
- `MACOS_MIGRATION.md`: documenta bundle ID `br.com.nossamaternidade.app`, Apple Team ID, ASC App ID, `CURRENT_PROJECT_VERSION` 25 e pipeline TestFlight.
- `.github/workflows/build-check.yml`: build/test Xcode e job TestFlight em push para `main`.
- Código Swift: 45 arquivos Swift, SwiftUI/SwiftData, telas Home, Diário, Agenda, Contrações, Perfil, onboarding emocional, NathIA e Mundo da Nath.
- Validação local em clone temporário:
  - `xcodebuild -list`: reconheceu targets `NossaMaternidade`, tests, UI tests e scheme `NossaMaternidade`.
  - `xcodebuild test` com `iPhone 16` falhou porque o simulador não existe no ambiente.
  - `xcodebuild build` genérico para iOS Simulator passou com `BUILD SUCCEEDED`.

## Bloqueios antes de submit

1. **Colisão de bundle ID**: `nathalia-app` e `Finaly` usam `br.com.nossamaternidade.app`.
2. **Build number**: `nathalia-app` expõe `ios.buildNumber: "1"` e `android.versionCode: 1`; `Finaly` documenta `CURRENT_PROJECT_VERSION: 25`. Antes de TestFlight, o canônico precisa usar build number maior que todos os builds já enviados.
3. **Conta ativa local**: a credencial `TheLionGab` precisa estar disponível no `gh` antes de qualquer ação remota.
4. **Node local**: alinhar Node para `>=22 <25`; o ambiente atual rodou com Node 26 e gerou `EBADENGINE`.
5. **Supabase região**: auditoria histórica do Expo apontou projeto em `us-east-2`, não `sa-east-1`; confirmar se ainda é produção e decidir formalmente se isso bloqueia release.
6. **QA físico**: release gate exige iPhone real e Android real; emulador não basta.

## Plano de consolidação pós-decisão

### Fase 1 - Travar fonte de verdade

- Declarar `TheLionGab/nathalia-app` como canônico em um ADR ou doc `docs/repo-canonical.md` atualizado.
- Marcar `Finaly` como referência Swift congelada, sem submits para o bundle de produção.
- Atualizar README/AGENTS do workspace ativo para evitar confusão entre Swift e Expo.

### Fase 2 - Resolver release identity

- Conferir App Store Connect e Play Console para último build aceito.
- Atualizar `ios.buildNumber` e `android.versionCode` no `nathalia-app` para valores superiores ao histórico real.
- Confirmar owner EAS `nossa-maternidade`, ASC App ID, Apple Team ID e associated domains.
- Validar que `Finaly` não tem pipeline ativo capaz de subir o mesmo bundle.

### Fase 3 - Fechar gates técnicos

- Rodar no ambiente correto: Node 22 ou 24, `npm ci`, `npm run preflight`, `npm run release:check`.
- Confirmar EAS secrets de Supabase, RevenueCat, Sentry e Expo.
- Confirmar Supabase production project, região, migrations e Edge Functions.
- Rodar smoke de Supabase e validar webhook RevenueCat.

### Fase 4 - Arquivar/rebaixar históricos

- Manter `nathalia-app` ativo.
- Manter `Finaly` ativo apenas se houver backlog explícito de rewrite Swift; caso contrário, arquivar depois de extrair onboarding emocional e telas úteis.
- Manter os repos arquivados como snapshots; não reativar `NossaMaternidade`, `Nossa-Maternidade` ou `Nossa-Maternidade-NathaliaValente` sem justificativa.

### Fase 5 - QA e submit

- Executar o `docs/release-gate.md` do `nathalia-app`.
- Fazer build EAS iOS/Android em profile production.
- Validar QA físico completo: auth, onboarding, NathIA, paywall, restore purchases, push e Sentry.
- Só submeter após GO explícito no scorecard.

## Decisão final

Fonte canônica recomendada: `TheLionGab/nathalia-app`.

Uso de `Finaly`: referência Swift e opção futura de rewrite iOS-first, não fonte de release atual.

Regra de segurança operacional: nenhum submit novo para `br.com.nossamaternidade.app` até resolver build number, credenciais `TheLionGab`, projeto Supabase de produção e release gate físico.

## Comandos executados

- `gh auth status`
- `gh repo view TheLionGab/nathalia-app --json ...` (falhou no fim por ausência de credencial `TheLionGab`)
- `npm ci`
- `npm run typecheck`
- `npm run lint`
- `npm run test:ci`
- `npm run config:check`
- `npm run audit:high`
- `xcodebuild -list -project ios/NossaMaternidade.xcodeproj`
- `xcodebuild test ... -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'` (falhou por simulador ausente)
- `xcodebuild build ... -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO`
- `rg` para padrões comuns de segredo

## Limites da avaliação

- A avaliação não criou issues, não arquivou repos, não alterou remotes e não fez push.
- A credencial `TheLionGab` não estava mais ativa no fim; novas chamadas `gh` privadas não resolveram.
- A validação Swift foi build genérico, não teste em simulador específico.
- A validação Expo foi local sem secrets de produção; EAS, Supabase remoto, RevenueCat sandbox e QA físico continuam pendentes.
