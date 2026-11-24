#!/usr/bin/env bash
# Ham dung chung cho cac script trong lab/. Cach dung: source "$(dirname "$0")/../common.sh"
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB_ENV="${LAB_ENV:-$REPO_ROOT/lab/lab.env}"

log()  { echo "[$(date +%H:%M:%S)] $*"; }
die()  { echo "ERROR: $*" >&2; exit 1; }

require_root() { [[ $EUID -eq 0 ]] || die "Chay bang sudo"; }

# MODE: all | packages (can Internet, giai doan A) | configure (offline, giai doan B) | ...
MODE="${MODE:-all}"
want() { [[ "$MODE" == all || "$MODE" == "$1" ]]; }

apt_install() { DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"; }

# chrony_client SERVER_IP : dong bo thoi gian ve VM2, khong dung pool Internet
chrony_client() {
  local server="$1"
  [[ -f /etc/chrony/chrony.conf.orig ]] || cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.orig 2>/dev/null || true
  cat > /etc/chrony/chrony.conf <<EOF
server ${server} iburst
makestep 1.0 3
rtcsync
driftfile /var/lib/chrony/chrony.drift
EOF
  systemctl enable chrony >/dev/null 2>&1 || true
  systemctl restart chrony
  log "chrony client -> ${server}"
}

load_env() {
  [[ -f "$LAB_ENV" ]] || die "Thieu $LAB_ENV"
  # shellcheck disable=SC1090
  source "$LAB_ENV"
  # ghi de rieng cho tung VM (khong commit)
  # shellcheck disable=SC1091
  [[ -f "$REPO_ROOT/lab/lab.local.env" ]] && source "$REPO_ROOT/lab/lab.local.env"
  return 0
}

# install_file SRC DEST [MODE]  - copy idempotent, bao khi file doi
install_file() {
  local src="$1" dest="$2" mode="${3:-0644}"
  install -D -m "$mode" "$src" "$dest"
  log "installed $dest"
}
