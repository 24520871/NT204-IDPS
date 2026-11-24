#!/usr/bin/env bash
# VM1 Kali – chay MOT LAN. Chay: sudo bash lab/vm1-kali/install.sh
source "$(dirname "$0")/../common.sh"
require_root
load_env

# TODO (S1): gan IP alias ($VM1_UPDATE_IP, $VM1_C2_IP, $VM1_EXFIL_IP) - da co trong netplan template
# TODO (S1): cai + cau hinh INetSim (HTTP/HTTPS/DNS gia lap) - cai o giai doan A
# TODO (S1): authoritative DNS cho domain tunnel (dnscat2/iodine server)
# TODO (S1): server nhan exfil + C2 gia lap
# TODO (S1): chrony client tro ve $VM2_EXT_IP
# Script tan cong chay truc tiep tu ban clone: attacks/<uc>/
