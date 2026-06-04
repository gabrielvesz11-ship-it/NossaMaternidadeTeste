# Avaliacao comparativa dos repositorios Nossa/Nath - 2026-05-21

## Sumario executivo

Recomendacao: manter `NossaMaternidadeTeste` como repositorio canonico, usando o workspace atual como base de profissionalizacao. Ele ja concentra arquitetura SwiftUI/SwiftData, Supabase via Edge Function, RevenueCat placeholders, scripts, CI, SwiftLint, docs de contribuicao, politica de seguranca e schema backend.

Os demais repositorios `LionGabDev` relacionados a Nossa/Nath sao prototipos Rork com alta duplicacao, baixa governanca e configuracao incompleta. Eles devem ser arquivados depois que ideias de produto forem registradas como issues ou notas: onboarding emocional, Mundo da Nath, Mães Valente, diario, agenda, contracoes, NathIA offline/fallback e assets aprovados.

`TheLionGab/nathalia-app` nao foi resolvido pelo GitHub CLI em 2026-05-21. A conta `TheLionGab` acessivel contem apenas `TheLionGab/claude-code` e `TheLionGab/rork-rork-go-app-starter`; nenhum deles corresponde a `nathalia-app`.

## Ranking

Escala: 0-100, ponderando aderencia ao produto, qualidade estrutural, configuracao, manutencao, documentacao, seguranca e facilidade de consolidacao.

| Rank | Repositorio | Nota | Decisao | Motivo |
|---:|---|---:|---|---|
| 1 | Workspace local `NossaMaternidadeTeste` | 84 | Canonico | Melhor base de engenharia: SwiftUI, SwiftData, Supabase, NathIA proxy, RevenueCat placeholders, CI, lint, docs e scripts. |
| 2 | `LionGabDev/rork-rorknossamaternidade` | 58 | Extrair ideias | Fluxos ricos de NathIA, Mundo da Nath, onboarding/paywall e comunidade; ainda e gerado, sem CI/docs e com config sensivel em arquivo Swift. |
| 3 | `LionGabDev/App-Nath-liaValente` | 58 | Extrair ideias | Clone equivalente ao anterior, util como referencia de produto; nao deve virar canonico. |
| 4 | `LionGabDev/rork-app-nath` | 56 | Extrair ideias | Conteudo semelhante aos prototipos Nath, com entitlements e mais superficie; validar ideias, nao migrar codigo bruto. |
| 5 | `LionGabDev/Best-Nossa-Maternidade` | 54 | Extrair ideias com cautela | Tem NathIA, Mundo da Nath e Mães Valente; tambem contem `Secrets.swift`, sem CI e sem governanca. |
| 6 | `LionGabDev/NossaMaternidade` | 52 | Arquivar depois de documentar | App SwiftData local com onboarding emocional e docs de handoff; menor aderencia ao backend atual. |
| 7 | `LionGabDev/NossaMaternidade-IOS` | 52 | Arquivar depois de documentar | Praticamente duplicado de `NossaMaternidade`; privado e sem valor canonico adicional claro. |
| 8 | `LionGabDev/Nossa-Maternidade-Nath` | 50 | Extrair ideias | Variante privada com Mundo Nath, comunidade, NathIA e paywall; revisar por API, clone SSH falhou. |
| 9 | `LionGabDev/rork-nossa-maternidade-blue-clone-635` | 44 | Arquivar / extrair conceito NICU se desejado | Prototipo NICU/OLED com Supabase direto e credenciais hardcoded em arquivo dedicado. |
| 10 | `LionGabDev/Nath-lia` | 44 | Arquivar | Duplicado privado do prototipo Blue/NICU; sem razao para manter separado. |
| 11 | `LionGabDev/rork-nossa-maternidade-blue-clone` | 44 | Arquivar | Mesmo eixo do Blue/NICU; clone SSH bloqueado, arvore lida via API. |
| 12 | `LionGabDev/rork-mamavida` | 40 | Arquivar | SwiftUI basico de gestacao, utilidade menor e sobreposto por outros repos. |
| 13 | `LionGabDev/Nossa-Maternidade-Rork` | 36 | Arquivar | Expo/React Native, fora da direcao nativa atual; pode inspirar checklist/tracker. |
| 14 | `LionGabDev/rork-rotina-da-mam-e` | 34 | Arquivar | Expo voltado a rotina/equipe; baixa aderencia ao produto maternidade atual. |
| 15 | `LionGabDev/rork-best-maternity-app-list` | 24 | Arquivar | Swift minimo `Maternity`, pouca superficie de produto. |
| 16 | `LionGabDev/rork-best-maternity-app-list-clone` | 5 | Excluir depois da janela de arquivo | Apenas README basico pelo inventario API; sem codigo util observado. |

## Inventario GitHub

Todos os repositorios abaixo tem branch padrao `main`, zero stars, zero issues abertas e zero PRs abertas na consulta feita. `LionGabDev/NossaMaternidade` tem 1 fork; os demais tem 0 forks. Nenhum retornou `licenseInfo` pelo GitHub, embora o workspace local tenha `LICENSE.md` proprietario ainda nao refletido como licenca detectada.

| Repositorio | Visibilidade | Linguagem | Ultimo push UTC | Inspecao |
|---|---|---|---|---|
| `LionGabDev/NossaMaternidadeTeste` | Publico | Swift | 2026-05-18 | Clone remoto + workspace local |
| `LionGabDev/rork-rorknossamaternidade` | Publico | Swift | 2026-05-14 | Clone temporario |
| `LionGabDev/rork-best-maternity-app-list-clone` | Privado | N/A | 2026-05-14 | API tree/readme; clone SSH falhou |
| `LionGabDev/rork-best-maternity-app-list` | Privado | Swift | 2026-05-14 | API tree; clone SSH falhou |
| `LionGabDev/NossaMaternidade-IOS` | Privado | Swift | 2026-05-14 | Clone temporario |
| `LionGabDev/Best-Nossa-Maternidade` | Publico | Swift | 2026-05-14 | Clone temporario |
| `LionGabDev/rork-rotina-da-mam-e` | Privado | TypeScript | 2026-05-11 | API tree/package; clone SSH falhou |
| `LionGabDev/NossaMaternidade` | Publico | Swift | 2026-05-07 | Clone temporario |
| `LionGabDev/rork-mamavida` | Publico | Swift | 2026-05-06 | Clone temporario |
| `LionGabDev/rork-nossa-maternidade-blue-clone-635` | Publico | Swift | 2026-04-16 | Clone temporario |
| `LionGabDev/rork-nossa-maternidade-blue-clone` | Privado | Swift | 2026-04-16 | API tree; clone SSH falhou |
| `LionGabDev/Nath-lia` | Privado | Swift | 2026-04-16 | API tree; clone SSH falhou |
| `LionGabDev/Nossa-Maternidade-Rork` | Privado | TypeScript | 2026-03-31 | API tree/package; clone SSH falhou |
| `LionGabDev/Nossa-Maternidade-Nath` | Privado | Swift | 2026-03-27 | API tree; clone SSH falhou |
| `LionGabDev/rork-app-nath` | Privado | Swift | 2026-03-27 | API tree; clone SSH falhou |
| `LionGabDev/App-Nath-liaValente` | Privado | Swift | 2026-03-27 | Clone temporario |

## Avaliacao do canonico

Base avaliada: workspace local `/Users/mac/Developer/NossaMaternidadeTeste`, porque ele contem a profissionalizacao em andamento que ainda nao aparece integralmente no clone remoto `LionGabDev/NossaMaternidadeTeste`.

Pontos fortes:

- Estrutura clara por `Core`, `Features`, `Models`, `supabase`, `scripts` e `docs`.
- SwiftData com schema explicito para perfil, chat, uso diario, diario semanal e assinatura.
- NathIA passa por proxy Supabase Edge Function; regra correta de nao embarcar `ANTHROPIC_API_KEY` no app.
- Configuracao via build settings, Info.plist, ambiente e `.xcconfig` ignorado; `Secrets.local.xcconfig` documentado como local.
- `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `CHANGELOG.md`, ADR e docs de consolidacao presentes.
- CI de iOS em GitHub Actions com build/test/lint e workflow de higiene com gitleaks.
- SwiftLint configurado para bloquear force unwrap/cast/try, linhas longas, funcoes grandes e arquivos grandes.
- Scripts padronizados: `build-simulator.sh`, `build-device-nosign.sh`, `quality-check.sh`, `run-on-device.sh`.
- Supabase `schema.sql` habilita RLS para tabelas de perfil, chat, uso, diario, assinatura e storage privado.

Riscos e lacunas:

- O remoto `LionGabDev/NossaMaternidadeTeste` ainda parece estar no snapshot Rork bruto; a profissionalizacao esta no working tree local e precisa virar PR/merge.
- `SupabaseService` e servicos externos ainda sao `final class`; isso e justificavel para lifetime/SDK, mas deve continuar excepcional.
- Testes cobrem calculo de gestacao, config, NathIA proxy e assinatura, mas ainda faltam testes para payloads Supabase, falhas de storage, limites de uso, modelos SwiftData e UI critica.
- RevenueCat ainda e placeholder; integracao real e entitlement validation precisam de decisao antes de paywall publico.
- O arquivo `.xcodebuildmcp/config.yaml` fixa simulador local `iPhone 17 Pro Max` por UUID; util localmente, mas fragil entre maquinas.
- Branch atual esta com muitos arquivos modificados/deletados e varios docs/configs ainda untracked; alto risco de divergencia ate consolidar em PR.

Configuracoes relevantes do canonico:

| Area | Arquivo | Avaliacao |
|---|---|---|
| Build iOS | `.github/workflows/ios-ci.yml` | Correto para PR/main; usa macOS 15, SwiftLint e `xcodebuild clean test`. |
| Higiene | `.github/workflows/repo-hygiene.yml` | Verifica docs obrigatorios, bloqueia env/Secrets local e roda gitleaks. |
| Lint | `.swiftlint.yml` | Boa barra inicial; `function_body_length` warning 40/error 80 alinha com AGENTS. |
| Config app | `ios/Config/App.xcconfig` | Sem valores reais; usa include opcional para `Secrets.local.xcconfig`. |
| Config local | `ios/Config/Secrets.xcconfig.example` | Exemplo adequado; nao deve conter chaves reais. |
| XcodeBuildMCP | `.xcodebuildmcp/config.yaml` | Facilita build local, mas o UUID do simulador nao e portavel. |
| Supabase | `supabase/schema.sql` | RLS presente; revisar ownership de `anonymous_user_id` antes de migracao real. |
| Edge Function | `supabase/functions/nath-ai/index.ts` | Direcao correta para proteger Anthropic; verificar secrets no dashboard Supabase, nao no repo. |

## Avaliacao dos prototipos

`rork-rorknossamaternidade`, `App-Nath-liaValente` e `rork-app-nath` formam a familia Nath mais rica. Eles tem models para `ChatMessage`, `NathPost`, `ContentPreference`, `JournalEntry`, servicos de NathIA, premium, storage, onboarding, Mundo da Nath, cuidados e comunidade/desabafo. O valor esta no produto e na copy; o codigo deve ser tratado como referencia, nao como fonte para copy/paste amplo.

`Best-Nossa-Maternidade` tem uma proposta de produto forte: NathIA, Mães Valente, Mundo da Nath, diario, agenda e contracoes. O risco e alto porque existe `Secrets.swift` com slots para provedores de IA, nao ha CI e a arquitetura e gerada. Aproveitar fluxo e conteudo, nao infraestrutura.

`NossaMaternidade` e `NossaMaternidade-IOS` sao bons historicos do app SwiftData local. O proprio `ANALYSIS.md` registra riscos relevantes: seeding de dados ficticios sem guard de producao, falta de CI, possivel colisao de bundle/build com Expo antigo e ausencia de privacy manifest. Arquivar apos extrair onboarding emocional e eventuais ideias de diario/agenda/contracoes.

`rork-nossa-maternidade-blue-clone-635`, `rork-nossa-maternidade-blue-clone` e `Nath-lia` sao variantes NICU/OLED com Supabase direto, views `NeuralDashboard`, `SanctuaryDiary`, `DeepEntryModal` e auth flow. Podem inspirar uma futura vertente UTI neonatal, mas hoje destoam da marca atual e usam padrao perigoso de credenciais hardcoded em `SupabaseCredentials.swift`.

`Nossa-Maternidade-Rork` e `rork-rotina-da-mam-e` sao Expo/React Native. Ambos usam Expo Router, React Query/Zustand ou providers locais, mas estao fora da decisao atual de iOS nativo. O maximo recomendado e transformar boas ideias de checklist/tracker/rotina em issues.

`rork-best-maternity-app-list` e `rork-best-maternity-app-list-clone` nao justificam manutencao. O clone retornou apenas README basico; o repo principal parece app Swift minimo `Maternity`.

## Padroes de excelencia e configuracao

Barra desejada para o canonico:

- Um unico repositorio de produto com branch protection, PR obrigatorio, CI obrigatorio e gitleaks ativo.
- Nenhum arquivo `Secrets.swift`, `.env`, `Secrets.local.xcconfig` ou credencial real versionado.
- Toda integracao de IA por backend/proxy; app mobile nunca deve receber chave Anthropic/OpenAI/Gemini privada.
- SwiftUI funcional por feature, servicos isolados para rede/SDK/persistencia e testes nos limites de falha.
- Docs minimos sempre presentes: README, CONTRIBUTING, SECURITY, LICENSE, ADRs e consolidacao.
- Prototipos arquivados como referencia historica; ideias entram no canonico como issues ou documentos, nao como repos vivos.

Gaps comuns nos prototipos:

- Sem workflows `.github`, sem SwiftLint ou qualidade automatizada.
- README minimo "Created by Rork" ou PLAN gerado como prompt, sem handoff operacional.
- Testes padrao de template, sem cobertura de regras de negocio.
- Configuracao sensivel em Swift (`Config.swift`, `Secrets.swift`, `SupabaseCredentials.swift`).
- Duplicacao extrema de projetos, targets e nomes de app.
- Falta de licenca detectavel, politica de seguranca e governanca de branch.

## Recomendacao de consolidacao

Manter:

- `NossaMaternidadeTeste` como unico canonico ate o merge da profissionalizacao.
- Renomear para `NossaMaternidade` depois que o repo antigo for arquivado/renomeado, preservando redirects GitHub.

Extrair ideias antes de arquivar:

- NathIA: fallback offline, crisis detector, historico limitado, copy empatica e gating premium.
- Produto Nath: Mundo da Nath, Mães Valente, comunidade moderada, conteudo exclusivo e social proof.
- Gestacao: diario, agenda, contracoes, onboarding emocional, calculos de semana e exportacao.
- NICU: apenas se houver decisao de produto para vertente UTI neonatal; caso contrario, arquivar sem migrar.

Arquivar:

- Todos os repositorios listados no ranking exceto o canonico.
- Primeiro arquivar publicos/duplicados obvios; depois privados que exigem revisao de assets/segredos.

Excluir depois de janela de 30 dias:

- `rork-best-maternity-app-list-clone`, se confirmado que nao contem codigo alem de README.
- Qualquer repo vazio/sem produto apos backup de notas e confirmacao manual.

## Checklist da proxima fase

1. Fazer PR da profissionalizacao atual do workspace e rodar CI.
2. Corrigir remote local para o owner canonico real, se a organizacao final for `LionGabDev`.
3. Ativar branch protection em `main`: PR obrigatorio, CI obrigatorio, gitleaks obrigatorio.
4. Criar issues de migracao de ideias dos prototipos, uma por fluxo de produto.
5. Arquivar prototipos Rork apos registrar ideias e riscos.
6. Substituir qualquer padrao de `Secrets.swift` por `.xcconfig` local ignorado ou secrets backend.
7. Expandir testes para Supabase payloads, storage, SwiftData defaults, NathIA error states e paywall.
8. Validar privacy manifest, bundle ID, build number e configuracao App Store Connect antes de TestFlight.

## Comandos e limites da avaliacao

Comandos usados:

- `gh repo list LionGabDev --limit 100 --json ...`
- `gh repo view TheLionGab/nathalia-app --json ...`
- `gh repo list TheLionGab --limit 100 --json ...`
- `gh repo clone <repo> <tmpdir> -- --depth=1 --quiet`
- `gh api repos/<repo>/git/trees/main?recursive=1`
- `gh api repos/<repo>/contents/...`
- `rg`, `find`, `sed`, `awk`, `git status`

Limites:

- Alguns repositorios privados foram visiveis pela API, mas falharam no clone Git/SSH com `Repository not found`; nesses casos a avaliacao usou arvore/API.
- Nao houve auditoria linha a linha de todos os arquivos; a profundidade foi triagem comparativa.
- Nenhuma migracao, push, archive ou alteracao remota foi executada.
- Valores sensiveis nao foram copiados para este relatorio; arquivos suspeitos foram mencionados por nome/padrao, nao por valor.
