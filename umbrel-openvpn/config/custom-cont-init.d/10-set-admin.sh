#!/usr/bin/with-contenv bash
set -euo pipefail

USER="${OVPN_AS_ADMIN_USER:-admin}"
PASS_FILE="/config/.admin-pass"

PASS_FROM_UMBREL="${APP_PASSWORD:-}"

if [ ! -f "$PASS_FILE" ]; then
  if [ -z "$PASS_FROM_UMBREL" ]; then
    PASS="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16)"
  else
    PASS="$PASS_FROM_UMBREL"
  fi

  if ! id "$USER" >/dev/null 2>&1; then
    adduser -D "$USER"
  fi
  echo "${USER}:${PASS}" | chpasswd

  echo "username: ${USER}" > "$PASS_FILE"
  echo "password: ${PASS}" >> "$PASS_FILE"
  chmod 600 "$PASS_FILE"

  echo "[umbrel-openvpn] Admin credentials set from APP_PASSWORD for ${USER}"
fi
