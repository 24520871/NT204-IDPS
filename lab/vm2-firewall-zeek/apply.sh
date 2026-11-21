#!/usr/bin/env bash
# VM2 – ap dung cau hinh tu repo (chay lai duoc nhieu lan, idempotent).
# Dung sau moi lan: git pull. Chay: sudo bash lab/vm2-firewall-zeek/apply.sh
source "$(dirname "$0")/../common.sh"
require_root
load_env
HERE="$(cd "$(dirname "$0")" && pwd)"

log "[nftables]"
# TODO (S1): thay IF_* trong ruleset.nft bang gia tri tu lab.env (envsubst), kiem tra: nft -c -f
#   install_file "$HERE/nftables/ruleset.nft" /etc/nftables.conf
#   nft -c -f /etc/nftables.conf && systemctl reload nftables

log "[zeek]"
# TODO (S2): copy zeek/local.zeek, zeek/signatures/*.sig, zeek/intel/*.intel vao $ZEEK_HOME/share/zeek/site/
#   "$ZEEK_HOME/bin/zeekctl" deploy

log "[splunk forwarder]"
# TODO (S2): copy uf/inputs.conf, uf/outputs.conf vao $SPLUNK_UF_HOME/etc/system/local/ ; restart UF

log "[block-agent]"
# TODO (S5): copy block-agent/agent.py vao /opt/block-agent ; cai systemd unit ; systemctl restart block-agent

log "apply xong"
