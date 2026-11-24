#!/usr/bin/env bash
# VM4 LAN server – chay MOT LAN.
#   sudo bash lab/vm4-lan/install.sh packages    # giai doan A (can Internet)
#   sudo bash lab/vm4-lan/install.sh configure   # giai doan B (offline)
MODE="${1:-all}"
source "$(dirname "$0")/../common.sh"
require_root
set -a; load_env; set +a

if want packages; then
  log "[packages]"
  apt-get update
  apt_install mysql-server dnsmasq samba chrony dnsutils openssh-server
fi

if want configure; then
  chrony_client "$VM2_LAN_IP"

  log "[mysql] bind ${VM4_IP}, DB dvwa, user dvwa chi tu ${VM3_IP}"
  cat > /etc/mysql/mysql.conf.d/99-lab.cnf <<EOF
[mysqld]
bind-address = ${VM4_IP}
EOF
  systemctl enable mysql >/dev/null 2>&1 || true
  systemctl restart mysql
  mysql <<EOF
CREATE DATABASE IF NOT EXISTS dvwa;
CREATE USER IF NOT EXISTS 'dvwa'@'${VM3_IP}' IDENTIFIED BY '${LAB_ONLY_DB_PASSWORD}';
ALTER USER 'dvwa'@'${VM3_IP}' IDENTIFIED BY '${LAB_ONLY_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'${VM3_IP}';
FLUSH PRIVILEGES;
EOF

  log "[dnsmasq] resolver noi bo, forward toi INetSim (${VM1_IP})"
  cat > /etc/dnsmasq.d/lab.conf <<EOF
listen-address=${VM4_IP}
bind-interfaces
no-resolv
server=${VM1_IP}
log-queries
log-facility=/var/log/dnsmasq.log
EOF
  systemctl enable dnsmasq >/dev/null 2>&1 || true
  systemctl restart dnsmasq

  log "[samba] share /srv/share (guest, chi dung trong lab)"
  mkdir -p /srv/share
  chmod 0777 /srv/share
  if ! grep -q '^\[public\]' /etc/samba/smb.conf; then
    sed -i '/^\[global\]/a\   map to guest = Bad User' /etc/samba/smb.conf
    cat >> /etc/samba/smb.conf <<EOF

[public]
   path = /srv/share
   guest ok = yes
   read only = no
   browseable = yes
EOF
  fi
  systemctl restart smbd

  log "Xong. Kiem chung intra-LAN: tren VM2 chay tcpdump khi VM6 ket noi VM4 (xem scripts/verify-s1.sh vm2 capture)"
fi
