#!/usr/bin/env bash
# VM2 – chay MOT LAN.
#   sudo bash lab/vm2-firewall-zeek/install.sh packages    # giai doan A (can Internet)
#   sudo bash lab/vm2-firewall-zeek/install.sh configure   # giai doan B (offline)
MODE="${1:-all}"
source "$(dirname "$0")/../common.sh"
require_root
set -a; load_env; set +a
HERE="$(cd "$(dirname "$0")" && pwd)"

if want packages; then
  log "[packages]"
  apt-get update
  apt_install nftables chrony tcpdump openssh-server
  # TODO (S2): Zeek (kem community_id), Splunk Universal Forwarder
fi

if want configure; then
  log "[sysctl] ip_forward, tat IPv6"
  cat > /etc/sysctl.d/90-lab.conf <<EOF
net.ipv4.ip_forward=1
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
EOF
  sysctl --system >/dev/null

  log "[chrony] VM2 lam nguon thoi gian cho lab"
  [[ -f /etc/chrony/chrony.conf.orig ]] || cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.orig 2>/dev/null || true
  cat > /etc/chrony/chrony.conf <<EOF
local stratum 10
allow ${EXT_NET}
allow ${DMZ_NET}
allow ${LAN_NET}
allow ${MGMT_NET}
makestep 1.0 3
rtcsync
driftfile /var/lib/chrony/chrony.drift
EOF
  systemctl enable chrony >/dev/null 2>&1 || true
  systemctl restart chrony

  bash "$HERE/apply.sh"
  # TODO (S5): user blockagent, /etc/block-agent/token
fi
