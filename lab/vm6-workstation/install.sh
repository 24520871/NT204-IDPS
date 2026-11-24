#!/usr/bin/env bash
# VM6 workstation – chay MOT LAN. Chay: sudo bash lab/vm6-workstation/install.sh
source "$(dirname "$0")/../common.sh"
require_root
load_env

# TODO (S1): apt-get install -y dnsutils curl python3 cron chrony  (cai o giai doan A, co Internet)
# TODO (S1): chrony client tro ve $VM2_LAN_IP
# TODO (S3): bat script sinh traffic lanh tinh tu traffic/ (cron/systemd timer)
# Script tan cong UC1-UC4 chay truc tiep tu ban clone: attacks/<uc>/
