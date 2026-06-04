#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${PROJECT_PATH:-ios/NossaMaternidade.xcodeproj}"
SCHEME="${SCHEME:-NossaMaternidade}"
CONFIGURATION="${CONFIGURATION:-Debug}"
BUNDLE_ID="${BUNDLE_ID:-com.gabrielvesz11.nossamaternidade}"
DEVICE_ID="${DEVICE_ID:-00008150-001145091A05401C}"
DERIVED_DATA="${DERIVED_DATA:-.build/DerivedData}"
DEVICE_TIMEOUT="${DEVICE_TIMEOUT:-30}"
DESTINATION_TIMEOUT="${DESTINATION_TIMEOUT:-30}"
TEAM_ID="${DEVELOPMENT_TEAM:-${APPLE_TEAM_ID:-}}"

if [[ -z "$TEAM_ID" && -f "$PROJECT_PATH/project.pbxproj" ]]; then
  TEAM_ID="$(sed -n 's/.*DEVELOPMENT_TEAM = \([A-Z0-9]\{10\}\);.*/\1/p' "$PROJECT_PATH/project.pbxproj" | head -1)"
fi

if [[ -z "$TEAM_ID" ]]; then
  TEAM_ID="$(security find-identity -v -p codesigning 2>/dev/null | sed -n 's/.*Apple Development:.*(\([A-Z0-9]\{10\}\)).*/\1/p' | head -1)"
fi

if [[ -z "$TEAM_ID" ]]; then
  cat <<'MESSAGE'
Erro: não encontrei um Apple Development Team ID nesta máquina.

Faça uma vez:
1. Abra Xcode > Settings > Accounts.
2. Entre com seu Apple ID.
3. Selecione sua conta e clique em Manage Certificates.
4. Crie/baixe um certificado "Apple Development".
5. Rode de novo:
   APPLE_TEAM_ID=SEU_TEAM_ID scripts/run-on-device.sh

Sem Team ID e certificado, o iOS não aceita instalar app nativo no aparelho.
MESSAGE
  exit 65
fi

if [[ "$TEAM_ID" == "SEU_TEAM_ID" || ! "$TEAM_ID" =~ ^[A-Z0-9]{10}$ ]]; then
  cat <<MESSAGE
Erro: Team ID inválido: "$TEAM_ID".

Use o Team ID real da sua conta Apple Developer, com 10 caracteres.
Exemplo:
   APPLE_TEAM_ID=ABCDE12345 scripts/run-on-device.sh

No Xcode, veja em Settings > Accounts > sua conta > Team.
MESSAGE
  exit 65
fi

echo "Device: $DEVICE_ID"
echo "Bundle: $BUNDLE_ID"
echo "Team: $TEAM_ID"

DEVICE_INFO_JSON="$(mktemp -t nossa-device-info.XXXXXX.json)"

if ! xcrun devicectl device info details --device "$DEVICE_ID" --timeout "$DEVICE_TIMEOUT" --json-output "$DEVICE_INFO_JSON" >/dev/null; then
  cat <<MESSAGE
Erro: o CoreDevice não conseguiu ativar o iPhone.

Device esperado:
   $DEVICE_ID

Tente:
1. Desbloquear o iPhone.
2. Confiar neste Mac no alerta do iOS.
3. Reconectar o cabo.
4. Abrir Window > Devices and Simulators no Xcode e aguardar o aparelho ficar disponível.
5. Rodar de novo.

Diagnóstico útil:
   xcrun devicectl device info details --device "$DEVICE_ID"
MESSAGE
  rm -f "$DEVICE_INFO_JSON"
  exit 70
fi

DDI_SERVICES_AVAILABLE="$(plutil -extract result.deviceProperties.ddiServicesAvailable raw -o - "$DEVICE_INFO_JSON" 2>/dev/null || true)"
TUNNEL_STATE="$(plutil -extract result.connectionProperties.tunnelState raw -o - "$DEVICE_INFO_JSON" 2>/dev/null || true)"
rm -f "$DEVICE_INFO_JSON"

if [[ "$DDI_SERVICES_AVAILABLE" != "true" || "$TUNNEL_STATE" != "connected" ]]; then
  cat <<MESSAGE
Erro: o iPhone está pareado, mas indisponível para instalação.

Estado atual:
   tunnelState=$TUNNEL_STATE
   ddiServicesAvailable=$DDI_SERVICES_AVAILABLE

Tente:
1. Desbloquear o iPhone.
2. Reconectar o cabo.
3. Abrir Window > Devices and Simulators no Xcode e aguardar o aparelho ficar disponível.
4. Rodar de novo.

Diagnóstico útil:
   xcrun devicectl device info details --device "$DEVICE_ID"
MESSAGE
  exit 70
fi

DESTINATION_STARTED_AT="$SECONDS"

until xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -showdestinations 2>/dev/null | grep -q "id:$DEVICE_ID"; do
  if (( SECONDS - DESTINATION_STARTED_AT >= DESTINATION_TIMEOUT )); then
    cat <<MESSAGE
Erro: o Xcode não encontrou o iPhone como destination ativa.

Device esperado:
   $DEVICE_ID

Tente:
1. Desbloquear o iPhone.
2. Confiar neste Mac no alerta do iOS.
3. Reconectar o cabo.
4. Abrir Window > Devices and Simulators no Xcode e aguardar o aparelho ficar disponível.
5. Rodar de novo.

Diagnóstico útil:
   xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -showdestinations
MESSAGE
    exit 70
  fi

  echo "Aguardando o Xcode reconhecer o iPhone..."
  sleep 2
done

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "platform=iOS,id=$DEVICE_ID" \
  -derivedDataPath "$DERIVED_DATA" \
  -allowProvisioningUpdates \
  -allowProvisioningDeviceRegistration \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
  build

PRODUCTS_DIR="$DERIVED_DATA/Build/Products/${CONFIGURATION}-iphoneos"
APP_PATH="$(find "$PRODUCTS_DIR" -maxdepth 1 -type d -name "*.app" -print -quit 2>/dev/null || true)"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Erro: app buildado não encontrado em: $PRODUCTS_DIR"
  exit 66
fi

xcrun devicectl device install app --device "$DEVICE_ID" "$APP_PATH"
xcrun devicectl device process launch --device "$DEVICE_ID" "$BUNDLE_ID" --terminate-existing --activate
