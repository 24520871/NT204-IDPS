#!/usr/bin/env bash
# VM4 LAN server – chay MOT LAN. Chay: sudo bash lab/vm4-lan/install.sh
source "$(dirname "$0")/../common.sh"
require_root
load_env

# TODO (S1): apt-get install -y mysql-server dnsmasq samba chrony  (giai doan A)
# TODO (S1): MySQL: tao DB + user cho web app tu $VM3_IP, listen $VM4_IP:3306
# TODO (S1): file share (Samba/NFS)
# TODO (S1): dnsmasq lam resolver noi bo, forward ra DNS INetSim tren $VM1_IP
# TODO (S1): chrony client tro ve $VM2_LAN_IP
# TODO (S1): kiem tra VM2 thay luu luong VM6 <-> VM4 (tcpdump tren NIC LAN cua VM2)
