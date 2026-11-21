#!/usr/bin/env bash
# VM3 Web DMZ – chay MOT LAN. Chay: sudo bash lab/vm3-web-dmz/install.sh
source "$(dirname "$0")/../common.sh"
require_root
load_env

# TODO (S1): cai web server + ung dung co lo hong thuc thi lenh (DVWA hoac app tu viet)
# TODO (S1): file config tro DB toi $VM4_LAN_IP:3306 (thong tin DB dung cho pivot UC5)
# TODO (S1): kiem tra chi egress 3306 + update server
