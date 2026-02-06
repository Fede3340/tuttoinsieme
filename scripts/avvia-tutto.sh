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

if [[ -f "${ROOT_DIR}/nuxt-spedizionefacile-master/package.json" ]]; then
  if [[ ! -d "${ROOT_DIR}/nuxt-spedizionefacile-master/node_modules" ]]; then
    (cd "${ROOT_DIR}/nuxt-spedizionefacile-master" && npm install)
  fi
fi

if ! pgrep -f "artisan serve --host 0.0.0.0 --port 8000" >/dev/null 2>&1; then
  (cd "${ROOT_DIR}/laravel-spedizionefacile-main" && php artisan serve --host 0.0.0.0 --port 8000 > /tmp/laravel.log 2>&1 &)
fi

if ! pgrep -f "nuxt dev.*--port 3000" >/dev/null 2>&1; then
  (cd "${ROOT_DIR}/nuxt-spedizionefacile-master" && npm run dev -- --host 0.0.0.0 --port 3000 > /tmp/nuxt.log 2>&1 &)
fi

echo "Backend: ${NUXT_PUBLIC_API_BASE}"
