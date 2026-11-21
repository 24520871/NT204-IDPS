#!/usr/bin/env bash
# VM2 – chay MOT LAN: cai goi can thiet roi goi apply.sh. Chay: sudo bash lab/vm2-firewall-zeek/install.sh
source "$(dirname "$0")/../common.sh"
require_root
load_env

log "Cai goi co ban"
# TODO (S1): apt-get install -y nftables chrony python3 ...
# TODO (S1): bat net.ipv4.ip_forward=1 (sysctl)
# TODO (S1): chrony lam nguon thoi gian cho cac VM con lai
# TODO (S2): cai Zeek (kem community_id) -> $ZEEK_HOME
# TODO (S2): cai Splunk Universal Forwarder -> $SPLUNK_UF_HOME
# TODO (S5): tao user he thong 'blockagent', thu muc /etc/block-agent (chmod 700), file token

bash "$(dirname "$0")/apply.sh"
