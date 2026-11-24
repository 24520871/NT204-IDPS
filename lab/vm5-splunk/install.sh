#!/usr/bin/env bash
# VM5 Splunk – chay MOT LAN.
#   sudo bash lab/vm5-splunk/install.sh packages                      # giai doan A
#   sudo bash lab/vm5-splunk/install.sh configure                     # giai doan B: chrony
#   sudo SPLUNK_DEB=/duong/dan/splunk.deb bash lab/vm5-splunk/install.sh splunk
#       (SPLUNK_ADMIN_PASSWORD de trong moi truong, neu khong script se hoi; KHONG luu trong repo)
# Cong 9997, Add-on for Zeek, index: thuoc S2. Cac buoc Splunk chua duoc kiem chung tren may that.
MODE="${1:-all}"
source "$(dirname "$0")/../common.sh"
require_root
set -a; load_env; set +a

if want packages; then
  log "[packages]"
  apt-get update
  apt_install chrony openssh-server
fi

if want configure; then
  chrony_client "$VM2_MGMT_IP"
fi

# 'splunk' chi chay khi duoc goi ro rang (can file .deb tai tay tu splunk.com)
if [[ "$MODE" == splunk ]]; then
  [[ -f "${SPLUNK_DEB:-}" ]] || die "Dat SPLUNK_DEB=/duong/dan/file.deb"
  log "[splunk] cai $SPLUNK_DEB"
  dpkg -i "$SPLUNK_DEB"
  runas="$(stat -c %U "$SPLUNK_HOME")"
  if [[ -z "${SPLUNK_ADMIN_PASSWORD:-}" ]]; then
    read -rsp "Mat khau admin Splunk: " SPLUNK_ADMIN_PASSWORD; echo
  fi
  mkdir -p "$SPLUNK_HOME/etc/system/local"
  cat > "$SPLUNK_HOME/etc/system/local/user-seed.conf" <<EOF
[user_info]
USERNAME = admin
PASSWORD = ${SPLUNK_ADMIN_PASSWORD}
EOF
  chown "$runas" "$SPLUNK_HOME/etc/system/local/user-seed.conf"
  chmod 600 "$SPLUNK_HOME/etc/system/local/user-seed.conf"

  sudo -u "$runas" "$SPLUNK_HOME/bin/splunk" start --accept-license --answer-yes --no-prompt
  date -I > "$SPLUNK_HOME/.lab_trial_start"
  log "Ngay bat dau trial: $(cat "$SPLUNK_HOME/.lab_trial_start") (ghi vao Changelog trong BUILD_PLAN; het han sau 60 ngay)"

  sudo -u "$runas" "$SPLUNK_HOME/bin/splunk" stop
  "$SPLUNK_HOME/bin/splunk" enable boot-start -user "$runas" -systemd-managed 1 --accept-license --answer-yes --no-prompt
  systemctl start Splunkd || systemctl start splunk || log "CANH BAO: khong khoi dong duoc service Splunk, kiem tra: systemctl list-units | grep -i splunk"
  log "Splunk Web: http://${VM5_HOSTONLY_IP}:8000 (tu may host)"
fi
