#!/usr/bin/with-contenv bash
set -euo pipefail

USER="${OVPN_AS_ADMIN_USER:-openvpn}"
PASS="${APP_PASSWORD:-}"            # Umbrel injeta quando deterministicPassword=true
PASS_FILE="/config/.admin-pass"
SACLI="/usr/local/openvpn_as/scripts/sacli"

# Se por algum motivo não vier do Umbrel, não faz nada
[ -z "$PASS" ] && { echo "[umbrel-openvpn] APP_PASSWORD not set, skipping"; exit 0; }

# aguarda o Access Server ficar operante
for i in {1..60}; do
  if "$SACLI" ConfigQuery >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

# aplica senha e garante privilégios de admin
"$SACLI" --user "$USER" --new_pass "$PASS" SetLocalPassword
"$SACLI" --user "$USER" --key "prop_superuser" --value "true" UserPropPut
"$SACLI" --user "$USER" --key "type" --value "user_connect" UserPropPut

# grava para o portal (/creds.txt)
echo "username: ${USER}" > "$PASS_FILE"
echo "password: ${PASS}" >> "$PASS_FILE"
chmod 600 "$PASS_FILE"

echo "[umbrel-openvpn] Password set from APP_PASSWORD for ${USER}"
