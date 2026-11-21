#!/usr/bin/env bash
# VM4 LAN – chay MOT LAN. Chay: sudo bash lab/vm4-lan/install.sh
source "$(dirname "$0")/../common.sh"
require_root
load_env

# TODO (S1): cai MySQL + file share + resolver noi bo (dnsmasq/BIND), tao DB cho web app
# TODO (S1): cai Docker; docker-compose macvlan 2 container (moi container 1 IP LAN)
# TODO (S1): kiem tra intra-LAN: ket noi giua 2 may LAN phai thay trong conn.log o VM2
# TODO (S3): bat script sinh traffic lanh tinh tu traffic/ (cron/systemd timer)
