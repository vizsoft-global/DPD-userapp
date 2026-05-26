#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${SUPABASE_ANON_KEY:-}" ]]; then
  echo "Set SUPABASE_ANON_KEY in your environment (from admin .env.local)." >&2
  exit 1
fi

cd "$(dirname "$0")/.."

flutter run \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-https://ytfmsgckjatiserpgdbz.supabase.co}" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  ${SENTRY_DSN:+--dart-define=SENTRY_DSN="$SENTRY_DSN"} \
  ${SENTRY_ENVIRONMENT:+--dart-define=SENTRY_ENVIRONMENT="$SENTRY_ENVIRONMENT"} \
  "$@"
