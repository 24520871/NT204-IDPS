#!/usr/bin/env bash
# Ham dung chung cho cac script trong lab/. Cach dung: source "$(dirname "$0")/../common.sh"
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB_ENV="${LAB_ENV:-$REPO_ROOT/lab/lab.env}"

log()  { echo "[$(date +%H:%M:%S)] $*"; }
die()  { echo "ERROR: $*" >&2; exit 1; }

require_root() { [[ $EUID -eq 0 ]] || die "Chay bang sudo"; }

load_env() {
  [[ -f "$LAB_ENV" ]] || die "Thieu $LAB_ENV (copy tu lab/lab.env.example va dien gia tri)"
  # shellcheck disable=SC1090
  source "$LAB_ENV"
}

# install_file SRC DEST [MODE]  - copy idempotent, bao khi file doi
install_file() {
  local src="$1" dest="$2" mode="${3:-0644}"
  install -D -m "$mode" "$src" "$dest"
  log "installed $dest"
}
