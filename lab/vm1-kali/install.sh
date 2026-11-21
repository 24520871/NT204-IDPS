#!/usr/bin/env bash
# VM1 Kali – chay MOT LAN. Chay: sudo bash lab/vm1-kali/install.sh
source "$(dirname "$0")/../common.sh"
require_root
load_env

# TODO (S1): gan IP alias (VM1_UPDATE_SERVER_IP, VM1_C2_IP, VM1_EXFIL_IP) len NIC ext-net
# TODO (S1): cai + cau hinh INetSim (HTTP/HTTPS/DNS gia lap)
# TODO (S1): authoritative DNS cho domain tunnel (dnscat2/iodine server)
# TODO (S1): server nhan exfil + C2 gia lap
# Script tan cong chay truc tiep tu ban clone: attacks/<uc>/
