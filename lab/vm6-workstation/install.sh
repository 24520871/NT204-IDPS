#!/usr/bin/env bash
# VM6 workstation – chay MOT LAN.
#   sudo bash lab/vm6-workstation/install.sh packages    # giai doan A (can Internet)
#   sudo bash lab/vm6-workstation/install.sh configure   # giai doan B (offline)
MODE="${1:-all}"
source "$(dirname "$0")/../common.sh"
require_root
set -a; load_env; set +a

if want packages; then
  log "[packages]"
  apt-get update
  apt_install dnsutils curl python3 cron chrony openssh-server nmap netcat-openbsd smbclient
fi

if want configure; then
  chrony_client "$VM2_LAN_IP"
  # DNS da duoc tro ve VM4 trong netplan (lab/render-netplan.sh vm6)
  # TODO (S4): bat script sinh traffic lanh tinh tu traffic/ (cron/systemd timer)
fi
# Script tan cong UC1-UC4 chay truc tiep tu ban clone: attacks/<uc>/
