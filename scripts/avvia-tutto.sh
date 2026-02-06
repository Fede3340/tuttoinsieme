#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -n "${CODESPACE_NAME:-}" && -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]]; then
  export NUXT_PUBLIC_API_BASE="https://${CODESPACE_NAME}-8000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
else
  export NUXT_PUBLIC_API_BASE="http://127.0.0.1:8000"
fi

if ! command -v composer >/dev/null 2>&1; then
  echo "Composer non disponibile nel container."
  exit 1
fi

if [[ -f "${ROOT_DIR}/laravel-spedizionefacile-main/composer.json" ]]; then
  if [[ ! -d "${ROOT_DIR}/laravel-spedizionefacile-main/vendor" ]]; then
    (cd "${ROOT_DIR}/laravel-spedizionefacile-main" && composer install --no-interaction --prefer-dist)
  fi
fi

if [[ -f "${ROOT_DIR}/laravel-spedizionefacile-main/.env.example" && ! -f "${ROOT_DIR}/laravel-spedizionefacile-main/.env" ]]; then
  cp "${ROOT_DIR}/laravel-spedizionefacile-main/.env.example" "${ROOT_DIR}/laravel-spedizionefacile-main/.env"
fi

if [[ -f "${ROOT_DIR}/laravel-spedizionefacile-main/.env" ]]; then
  DB_PATH="${ROOT_DIR}/laravel-spedizionefacile-main/database/database.sqlite"
  touch "${DB_PATH}"
  if grep -q "^DB_CONNECTION=" "${ROOT_DIR}/laravel-spedizionefacile-main/.env"; then
    sed -i "s|^DB_CONNECTION=.*|DB_CONNECTION=sqlite|" "${ROOT_DIR}/laravel-spedizionefacile-main/.env"
  else
    echo "DB_CONNECTION=sqlite" >> "${ROOT_DIR}/laravel-spedizionefacile-main/.env"
  fi
  if grep -q "^DB_DATABASE=" "${ROOT_DIR}/laravel-spedizionefacile-main/.env"; then
    sed -i "s|^DB_DATABASE=.*|DB_DATABASE=${DB_PATH}|" "${ROOT_DIR}/laravel-spedizionefacile-main/.env"
  else
    echo "DB_DATABASE=${DB_PATH}" >> "${ROOT_DIR}/laravel-spedizionefacile-main/.env"
  fi
  if ! grep -q "^APP_KEY=" "${ROOT_DIR}/laravel-spedizionefacile-main/.env" || grep -q "^APP_KEY=$" "${ROOT_DIR}/laravel-spedizionefacile-main/.env"; then
    (cd "${ROOT_DIR}/laravel-spedizionefacile-main" && php artisan key:generate --force)
  fi
fi

if [[ -f "${ROOT_DIR}/nuxt-spedizionefacile-master/package.json" ]]; then
  if [[ ! -d "${ROOT_DIR}/nuxt-spedizionefacile-master/node_modules" ]]; then
    (cd "${ROOT_DIR}/nuxt-spedizionefacile-master" && npm install)
  else
    (cd "${ROOT_DIR}/nuxt-spedizionefacile-master" && npm install --prefer-offline --no-audit >/tmp/nuxt-npm-install.log 2>&1 || true)
  fi
fi

if ! pgrep -f "artisan serve --host 0.0.0.0 --port 8000" >/dev/null 2>&1; then
  (cd "${ROOT_DIR}/laravel-spedizionefacile-main" && php artisan serve --host 0.0.0.0 --port 8000 > /tmp/laravel.log 2>&1 &)
fi

if ! pgrep -f "nuxt dev.*--port 3000" >/dev/null 2>&1; then
  (cd "${ROOT_DIR}/nuxt-spedizionefacile-master" && npm run dev -- --host 0.0.0.0 --port 3000 > /tmp/nuxt.log 2>&1 &)
  sleep 4
  if ! pgrep -f "nuxt dev.*--port 3000" >/dev/null 2>&1; then
    (cd "${ROOT_DIR}/nuxt-spedizionefacile-master" && npx nuxi dev --host 0.0.0.0 --port 3000 >> /tmp/nuxt.log 2>&1 &)
  fi
fi

echo "Backend: ${NUXT_PUBLIC_API_BASE}"
