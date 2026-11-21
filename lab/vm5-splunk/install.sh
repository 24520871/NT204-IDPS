#!/usr/bin/env bash
# VM5 – chay MOT LAN. Chay: sudo bash lab/vm5-splunk/install.sh
source "$(dirname "$0")/../common.sh"
require_root
load_env

# TODO (S1/S2): cai Splunk Enterprise (.deb/.tgz tai thu cong, khong commit) -> $SPLUNK_HOME
# TODO (S2): bat receiving port 9997
# TODO (S2): cai Splunk Add-on for Zeek (tai thu cong tu Splunkbase)
# TODO (S1): GHI NGAY BAT DAU TRIAL 60 ngay vao BUILD_PLAN (Changelog)

bash "$(dirname "$0")/deploy_app.sh"
