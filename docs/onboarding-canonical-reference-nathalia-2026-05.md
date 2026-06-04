# Onboarding Canonical Reference — Nathália App (Real Product)
**Data:** 2026-05 | **Status:** Memorized source of truth for native SwiftUI redesign  
**Fontes primárias:** 
- Código real: `hooks/useOnboardingFlow.ts`, `app/(onboarding)/index.tsx`, `components/onboarding/OnboardingFlowComponents.tsx`
- Copy emocional: `docs/copy/onboarding-content.ts` (inclui SWIFT_ONBOARDING_COPY)
- Evidência visual: Screenshots anteriores + **Image #1 + Image #2** enviadas pelo usuário (maio 2026)

---

## 1. As 4 Opções de Momento (não-negociáveis — fonte canônica)

Exato do `useOnboardingFlow.ts:88-93`:

```ts
MOMENT_OPTIONS = [
  { value: 'pregnant',           label: 'Estou grávida',           iconName: 'flower-outline' },
  { value: 'baby_born',          label: 'Meu bebê já nasceu',      iconName: 'happy-outline' },
  { value: 'trying',             label: 'Estou tentando engravidar', iconName: 'heart-outline' },
  { value: 'supporting_someone', label: 'Quero acompanhar alguém', iconName: 'people-outline' },
]
```

**Lições visuais das imagens:**
- Cards com ícone em círculo colorido (não apenas SF Symbol solto).
- Label curta, forte, sem subtítulo longo no card de momento (o contexto vem no título da tela).
- Seleção single → auto-advance forte (speed-to-value).

**Gap atual no nativo:** Opções ainda genéricas ("Tentando engravidar", "Já tive meu bebê", "Planejando o futuro", "Estou grávida") — não batem com as 4 reais acima.

---

## 2. Pains (MainPain) — 6 opções exatas

```ts
PAIN_OPTIONS = [
  { value: 'sleep',            label: 'Sono meu ou do bebê',       iconName: 'moon-outline' },
  { value: 'anxiety',          label: 'Ansiedade e medo',          iconName: 'rainy-outline' },
  { value: 'breastfeeding',    label: 'Amamentação',               iconName: 'water-outline' },
  { value: 'body_self_esteem', label: 'Corpo e autoestima',        iconName: 'body-outline' },
  { value: 'loneliness',       label: 'Solidão',                   iconName: 'person-outline' },
  { value: 'no_time',          label: 'Rotina sem tempo pra mim',  iconName: 'time-outline' },
]
```

Multi-select (Set). Tela: "O que mais está pesando hoje?" + "Pode escolher mais de um."

---

## 3. Desired Feelings — 6 opções exatas

```ts
FEELING_OPTIONS = [
  { value: 'calm',       label: 'Calma',       iconName: 'leaf-outline' },
  { value: 'strength',   label: 'Força',       iconName: 'flame-outline' },
  { value: 'confidence', label: 'Confiança',   iconName: 'star-outline' },
  { value: 'connection', label: 'Conexão',     iconName: 'sparkles-outline' },
  { value: 'lightness',  label: 'Leveza',      iconName: 'sunny-outline' },
  { value: 'direction',  label: 'Direção',     iconName: 'compass-outline' },
]
```

Multi-select. Tela costuma vir com copy de normalização forte.

---

## 4. Estrutura do Fluxo Real (6 passos lógicos, 8 etapas mostradas no progress)

`ONBOARDING_STEPS = ['welcome', 'moment', 'baby-name', 'pain', 'feelings', 'summary']`

- **welcome**: Copy poderosa de acolhimento ("Aqui você não precisa dar conta de tudo").
- **moment**: 4 cards acima (single, auto-advance).
- **baby-name**: Input + "Não sei / ainda não escolhi" toggle (importante para quem está tentando ou grávida cedo).
- **pain**: Multi-select das 6 dores/pesos (Image #1 / #2 provavelmente mostram execução visual deste ou do feelings).
- **feelings**: Multi-select dos 6 sentimentos desejados.
- **summary**: Reflete escolhas de volta com personality + input de nome (ou nome já coletado) + CTA final. Usa SummaryCards com tons (coral / sage / lavender).

**Total steps exposto:** 8 (para sensação de progresso gentil).

---

## 5. O Que Image #1 + Image #2 + Screenshots Anteriores Revelaram (Visual + Tom)

(Internalizado a partir das imagens enviadas + código que as produz):

- **Cards de opção (OptionCard)**: 
  - Ícone dentro de círculo com fundo quando selecionado.
  - Label limpa, tipografia hierárquica clara.
  - Checkmark trailing (círculo preenchido no multi).
  - Staggered FadeInDown por índice (80ms + 45ms delay).
  - Pressed state sutil + haptics.
  - Suporte nativo a multiSelect (acessibilidade checkbox vs radio).

- **Progress**: Não é barra genérica. Tem um pequeno avatar circular da Nathia (nossaV1Images.nathia) + track animado. Transmite "companhia" e cuidado.

- **Shell / Background**: Washs suaves nos cantos e inferior (cornerWash + lowerWash) criando profundidade sem peso. Dark mode support.

- **Copy emocional (normalização)**:
  - "Pode responder com sinceridade. Isso serve apenas para personalizar melhor o app."
  - Skip warning: "Sem essas respostas, recomendações e sugestões ficam menos personalizadas ao que você está vivendo agora."
  - Welcome: "Aqui você não precisa dar conta de tudo" + "acolhimento sem cobrança e sem julgamento".

- **Summary cards**: 3 tons distintos (coral/sage/lavender) com ícones + título/subtítulo. Usados para refletir o "você escolheu X, então vamos te entregar Y".

- **Velocidade + Ritmo**: Single-select avança sozinho. Multi-select permite continuar quando quiser (pelo menos 1 recomendado). Nome no final ou dedicado.

- **Acessibilidade**: Hit slop generoso, labels, states, largeText multipliers. Feito para grávidas/cansadas.

---

## 6. Princípios de Design Emocional Extraídos (o que faz "sentir cuidado")

1. **Normalização sem julgamento** — dores difíceis são nomeadas com naturalidade (ansiedade, solidão, corpo, amamentação).
2. **"Quero acompanhar alguém"** é caminho de primeira classe (rede de apoio — avós, parceiras, etc.).
3. **Preview da experiência** no summary antes do commit.
4. **Progresso visível com personagem** (Nathia no progresso) → reduz ansiedade de "quanto falta".
5. **Micro-interações premium** (stagger, spring, haptics leves, ícones que mudam de cor/estado).
6. **Copy que protege** — skip não é agressivo; é honesto sobre perda de valor.

---

## 7. Gaps Atuais do SwiftUI Nativo (para fechar no redesign)

- Moment options incorretos (ver seção 1).
- Cards são lista vertical full-width (referência parece mais refinada em grid ou com mais breathing room + círculo de ícone).
- Sem step dedicado baby-name (nome só no final; pode ser ok ou precisa separar).
- ProgressBar atual é simples (sem avatar/personagem).
- Sem "Pular" com o modal/cópia cuidadosa.
- Animações por card (stagger) ainda não no nível do reference.
- Summary ainda não usa tons visuais diferenciados + preview rico.
- Ausência de alguns micro-textos de acolhimento (ex: "Cada dia é uma descoberta nova").

**O que já está forte no nativo:**
- TabView + spring page transition.
- Haptics (light/selection/success/error).
- OnboardingStepContainer + PrimaryButton com disabled.
- Persistência SwiftData + Supabase + RevenueCat gate.
- Design system terroso/terracota (vamos manter e só portar padrões de interação/polish).

---

## 8. Plano de Redesign Cirúrgico (Proposto — aguardando "apply")

**Fluxo alvo para nativo (5 passos compactos, mantendo alma):**
1. Welcome (copy forte adaptada do SWIFT_ONBOARDING_COPY)
2. Moment (exatamente as 4 opções reais + ícones apropriados no sistema terroso)
3. Pains (multi — 6 opções reais, grid ou lista refinada)
4. Feelings (multi — 6 opções reais)
5. Name + Summary impactante (com SummaryCards tonais + confirmação final)

**Componentes a evoluir (Core/Design/OnboardingComponents.swift + AppComponents):**
- `OnboardingOptionCard`: adicionar círculo de fundo pro ícone, stagger support via index, pressed + selected states mais próximos do reference.
- Novo `OnboardingProgressWithAvatar` (ou evoluir o atual) — usar asset pequeno ou SF + círculo.
- `OnboardingSummaryCard` com 3-4 tons terrosos adaptados (terracota, sage, areia, lavanda suave).
- `OnboardingScreenShell` com washes sutis se couber no tema atual.
- Header com back + progress + "Pular" (com Alert/Sheet cuidadoso).

**Copy prioritária (adaptar tom terroso mantendo calor):**
- Usar labels exatas das 4 opções.
- "O que mais está pesando hoje?" / "Pode escolher mais de um."
- Summary que ecoa: "Você está [momento]. O que mais pesa: [pains]. Quer se sentir: [feelings]."
- Nome: "Como você gosta de ser chamada?"

**P0 (para próximo build físico):**
- Trocar as 4 moment options para as reais + ícones corretos.
- Refinar OnboardingOptionCard (círculo + visual das imagens).
- Adicionar stagger + haptics refinados.
- Progress com personagem (mesmo que simples por enquanto).
- Testar fluxo completo no device físico.

**P1:**
- Baby-name step ou toggle no summary.
- Pular com copy protetora.
- Summary cards tonais bonitos.
- Persistir progresso parcial (como v4 no reference).

**P2:**
- Ilustrações/ícones custom em vez de só SF Symbols.
- Dark mode polishing.
- A/B ou métricas de drop-off (futuro).

**Critérios de aceitação (para validar no device):**
- As 4 opções de momento aparecem exatamente como no app real.
- Multi-select de pains e feelings funciona suave com haptics e visual selected premium.
- Progress transmite "cuidado" (avatar ou equivalente).
- Summary reflete escolhas de forma emocional e bonita.
- Usuário consegue completar sem travar; hasCompletedOnboarding = true → Paywall ou Main.

---

## 9. Oportunidades Únicas do Nativo (não copiar, elevar)

- Haptics mais ricos que Expo (AppHaptics já existe — usar mais: .selectionChanged, .impact etc.).
- Matched Geometry Effect em transições de card → summary.
- Spring animations nativas de primeira classe (já usa em TabView).
- SwiftData + offline-first desde o onboarding.
- Performance e fluidez que React Native ainda não entrega no mesmo nível.

---

**Memorizado.**  
Este documento é a fonte única de verdade para o próximo passo do onboarding nativo.  

Qualquer mudança no fluxo ou copy deve rastrear de volta para cá (especialmente as 4 opções + labels de pain/feeling + princípios de "cuidado").

---

*Próximo comando esperado do usuário: "plan", "ajusta X", "mais detalhes no Y", ou "apply" (para começar implementação cirúrgica).*