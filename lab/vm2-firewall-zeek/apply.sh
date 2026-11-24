#!/usr/bin/env bash
# VM2 – ap dung cau hinh tu repo (chay lai duoc nhieu lan, idempotent).
# Dung sau moi lan: git pull. Chay: sudo bash lab/vm2-firewall-zeek/apply.sh
source "$(dirname "$0")/../common.sh"
require_root
set -a; load_env; set +a
HERE="$(cd "$(dirname "$0")" && pwd)"

log "[nftables]"
VARS='${VM2_IF_EXT} ${VM2_IF_DMZ} ${VM2_IF_LAN} ${VM2_IF_MGMT} ${VM3_IP} ${VM4_IP} ${VM5_IP} ${VM1_UPDATE_IP} ${BLOCK_AGENT_PORT}'
command -v envsubst >/dev/null || die "Thieu envsubst (apt install gettext-base)"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
envsubst "$VARS" < "$HERE/nftables/ruleset.nft.tmpl" > "$tmp"
nft -c -f "$tmp"                      # kiem tra cu phap truoc khi nap
install -m 0644 "$tmp" /etc/nftables.conf
nft -f /etc/nftables.conf
systemctl enable nftables >/dev/null 2>&1 || true

log "[zeek]"
# TODO (S2): copy zeek/local.zeek, zeek/signatures/*.sig, zeek/intel/*.intel vao $ZEEK_HOME/share/zeek/site/
#   "$ZEEK_HOME/bin/zeekctl" deploy

log "[splunk forwarder]"
# TODO (S2): copy uf/inputs.conf, uf/outputs.conf vao $SPLUNK_UF_HOME/etc/system/local/ ; restart UF

log "[block-agent]"
# TODO (S5): copy block-agent/agent.py vao /opt/block-agent ; cai systemd unit ; systemctl restart block-agent

log "apply xong"
