#!/usr/bin/env bash
# VM1 Kali – chay MOT LAN.
#   sudo bash lab/vm1-kali/install.sh packages    # giai doan A (can Internet)
#   sudo bash lab/vm1-kali/install.sh configure   # giai doan B (offline)
# Luu y: cac buoc INetSim chua duoc kiem chung tren may that.
MODE="${1:-all}"
source "$(dirname "$0")/../common.sh"
require_root
set -a; load_env; set +a

if want packages; then
  log "[packages]"
  apt-get update
  apt_install inetsim chrony dnsutils openssh-server
fi

if want configure; then
  chrony_client "$VM2_EXT_IP"

  log "[inetsim] DNS + HTTP + HTTPS, bind moi dia chi (alias .11/.12/.13 deu tra loi)"
  conf=/etc/inetsim/inetsim.conf
  [[ -f "$conf.orig" ]] || cp "$conf" "$conf.orig"
  sed -i '/^# --- lab-managed ---/,$d' "$conf"
  sed -i -E 's/^(start_service|service_bind_address|dns_bind_port|dns_default_ip|dns_default_domainname)/#\1/' "$conf"
  cat >> "$conf" <<EOF
# --- lab-managed ---
start_service dns
start_service http
start_service https
service_bind_address 0.0.0.0
dns_bind_port 53
dns_default_ip ${VM1_IP}
dns_default_domainname lab.test
EOF
  if ss -lunp 2>/dev/null | grep -q ':53 '; then
    log "CANH BAO: cong 53 dang bi dich vu khac dung (vd systemd-resolved); INetSim co the khong khoi dong"
  fi
  systemctl enable --now inetsim || log "CANH BAO: khong bat duoc service inetsim, kiem tra: journalctl -u inetsim"

  # TODO (S4): authoritative DNS cho domain tunnel (dnscat2/iodine), server nhan exfil, C2 gia lap
fi
