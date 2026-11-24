#!/usr/bin/env bash
# Sinh /etc/netplan/60-lab.yaml tu lab/<vm>/netplan/60-lab.yaml.tmpl va lab/lab.env.
# Chay: sudo bash lab/render-netplan.sh vm2   (vm1|vm2|vm3|vm4|vm5|vm6)
# Sau do: sudo netplan apply
source "$(dirname "$0")/common.sh"
require_root
load_env

vm="${1:-}"
tmpl=$(ls "$REPO_ROOT"/lab/${vm}-*/netplan/60-lab.yaml.tmpl 2>/dev/null | head -1 || true)
[[ -n "$vm" && -f "$tmpl" ]] || die "Dung: render-netplan.sh vm1|vm2|vm3|vm4|vm5|vm6"
command -v envsubst >/dev/null || die "Thieu envsubst (apt install gettext-base)"

out=/etc/netplan/60-lab.yaml
set -a; source "$LAB_ENV"; set +a
envsubst < "$tmpl" > "$out"
chmod 600 "$out"
log "wrote $out - kiem tra roi chay: netplan apply"
