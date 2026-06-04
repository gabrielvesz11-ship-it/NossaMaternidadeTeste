#!/usr/bin/env bash
# Wrapper — delega para o script central em ~/bin
exec "$HOME/bin/ios-setup-run.sh" "$@"
Essa mensagem é **normal na primeira instalação** do Jasmim Dev no iPhone (build EAS `development` ou instalação via Xcode). O iOS não deixa o app abrir até você confiar manualmente no certificado de desenvolvedor.

### No iPhone (passo a passo)

1. Abra **Ajustes** → **Geral** → **VPN e Gerenciamento de Dispositivo**
   (em inglês: *Settings → General → VPN & Device Management*).
2. Na seção **Apps de Desenvolvedor** (*Developer App*), toque no perfil listado (nome da sua Apple ID ou da equipe de desenvolvimento).
3. Toque em **Confiar em “…”** (*Trust …*) e confirme.
4. Volte à tela inicial e abra de novo o **Jasmim Dev**.

### Se não aparecer nenhum perfil

- Reinstale o app (QR do `npm run ios:device:install` ou build EAS) e repita os passos acima.
- Confirme que instalou o **Jasmim Dev** (`com.jasmim.app.dev`), não outro bundle.

### Depois de confiar

Rode o fluxo diário:

```bash
npm run ios:device
```

Abra o Jasmim Dev no celular e escaneie o QR do Metro.

**Nota:** builds **TestFlight / produção** não exigem esse passo — só instalações de **desenvolvimento** (dev client).

Incluí esse troubleshooting em `COMO-TESTAR-NO-IPHONE.md` para consulta futura. Se, após confiar, o app ainda não abrir ou crashar na abertura, descreva o que aparece na tela (ou um print) e seguimos.Essa mensagem é **normal na primeira instalação** do Jasmim Dev no iPhone (build EAS `development` ou instalação via Xcode). O iOS não deixa o app abrir até você confiar manualmente no certificado de desenvolvedor.

### No iPhone (passo a passo)

1. Abra **Ajustes** → **Geral** → **VPN e Gerenciamento de Dispositivo**
   (em inglês: *Settings → General → VPN & Device Management*).
2. Na seção **Apps de Desenvolvedor** (*Developer App*), toque no perfil listado (nome da sua Apple ID ou da equipe de desenvolvimento).
3. Toque em **Confiar em “…”** (*Trust …*) e confirme.
4. Volte à tela inicial e abra de novo o **Jasmim Dev**.

### Se não aparecer nenhum perfil

- Reinstale o app (QR do `npm run ios:device:install` ou build EAS) e repita os passos acima.
- Confirme que instalou o **Jasmim Dev** (`com.jasmim.app.dev`), não outro bundle.

### Depois de confiar

Rode o fluxo diário:

```bash
npm run ios:device
```

Abra o Jasmim Dev no celular e escaneie o QR do Metro.

**Nota:** builds **TestFlight / produção** não exigem esse passo — só instalações de **desenvolvimento** (dev client).

Incluí esse troubleshooting em `COMO-TESTAR-NO-IPHONE.md` para consulta futura. Se, após confiar, o app ainda não abrir ou crashar na abertura, descreva o que aparece na tela (ou um print) e seguimos.
