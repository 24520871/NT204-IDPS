#!/usr/bin/env bash
# Kiem thu S1 tren tung VM: bash scripts/verify-s1.sh vm1|vm2|vm3|vm4|vm5|vm6 [capture]
# In PASS/FAIL tung dong va luu output vao evaluation/evidence/s1/<vm>-<ngay gio>.txt
# - Luong CHO PHEP: ket noi phai thanh cong.
# - Luong BI CHAN: phai TIMEOUT (firewall drop). Neu ket noi thanh cong hoac bi RST thi goi tin da toi dich => FAIL.
# 'capture' (chi vm2): bat tcpdump 15 giay tren NIC LAN de kiem chung Zeek thay luong VM6 <-> VM4.
source "$(dirname "$0")/../lab/common.sh"
set +e
set -a; load_env; set +a

vm="${1:-}"
[[ "$vm" =~ ^vm[1-6]$ ]] || die "Dung: verify-s1.sh vm1|vm2|vm3|vm4|vm5|vm6 [capture]"

out_dir="$REPO_ROOT/evaluation/evidence/s1"
mkdir -p "$out_dir"
out="$out_dir/${vm}-$(date +%Y%m%d-%H%M).txt"
exec > >(tee "$out") 2>&1

pass=0; fail=0
ok()  { echo "PASS  $*"; pass=$((pass+1)); }
bad() { echo "FAIL  $*"; fail=$((fail+1)); }

# tcp_rc HOST PORT -> 0 mo | 124 timeout | khac: bi tu choi/khong toi duoc
tcp_rc() { timeout 3 bash -c "exec 3<>/dev/tcp/$1/$2" 2>/dev/null; echo $?; }

expect_open() {          # host port mo-ta
  local rc; rc=$(tcp_rc "$1" "$2")
  [[ "$rc" == 0 ]] && ok "$3 ($1:$2 mo)" || bad "$3 ($1:$2 ky vong MO, rc=$rc: 124=timeout, khac=bi tu choi/khong co dich vu)"
}
expect_blocked() {       # host port mo-ta
  local rc; rc=$(tcp_rc "$1" "$2")
  if [[ "$rc" == 124 ]]; then ok "$3 ($1:$2 bi chan, timeout)"
  elif [[ "$rc" == 0 ]]; then bad "$3 ($1:$2 ky vong BI CHAN nhung ket noi duoc)"
  else bad "$3 ($1:$2 ky vong timeout nhung nhan duoc phan hoi tu choi rc=$rc => goi tin da toi dich)"; fi
}
dns_open() {             # server domain mo-ta
  local r; r=$(dig +time=2 +tries=1 +short @"$1" "$2" 2>/dev/null)
  [[ -n "$r" ]] && ok "$3 (@$1 tra loi: $(echo "$r" | head -1))" || bad "$3 (@$1 khong tra loi)"
}
dns_blocked() {          # server domain mo-ta
  dig +time=2 +tries=1 +short @"$1" "$2" >/dev/null 2>&1
  [[ $? == 9 ]] && ok "$3 (@$1 bi chan, khong co phan hoi)" || bad "$3 (@$1 ky vong khong co phan hoi)"
}
check_time() {
  local off
  off=$(chronyc tracking 2>/dev/null | awk '/System time/{print $4}')
  if [[ -n "$off" ]] && awk -v o="$off" 'BEGIN{exit !(o<1.0)}'; then ok "chrony lech ${off}s (< 1s)"
  else bad "chrony: khong doc duoc hoac lech >= 1s (offset='${off}')"; fi
}

echo "== verify-s1 $vm $(date -Is) =="
case "$vm" in
  vm1)
    expect_open    "$VM3_IP" 80   "ext -> DMZ web 80"
    expect_blocked "$VM3_IP" 22   "ext -> DMZ cong khac (ma tran chi 80/443)"
    expect_blocked "$VM4_IP" 3306 "ext -> LAN"
    expect_blocked "$VM6_IP" 22   "ext -> LAN may tram"
    dns_open "$VM1_IP" example.com "INetSim DNS tren VM1 hoat dong"
    expect_open "$VM1_IP" 80 "INetSim HTTP tren VM1"
    check_time ;;
  vm2)
    nft list table inet idps >/dev/null 2>&1 && ok "bang nftables inet idps da nap" || bad "chua nap bang nftables inet idps"
    [[ "$(sysctl -n net.ipv4.ip_forward)" == 1 ]] && ok "ip_forward = 1" || bad "ip_forward != 1"
    systemctl is-active --quiet chrony && ok "chrony server dang chay" || bad "chrony khong chay"
    for n in EXT DMZ LAN MGMT; do
      ifn="VM2_IF_$n"; ip -br a show "${!ifn}" 2>/dev/null | grep -q UP && ok "NIC ${!ifn} ($n) UP" || bad "NIC ${!ifn} ($n) khong UP"
    done
    if [[ "${2:-}" == capture ]]; then
      echo ">> Trong 15 giay toi, tren VM6 chay: ping -c 5 $VM4_IP ; nc -zv $VM4_IP 22"
      n=$(timeout 15 tcpdump -ni "$VM2_IF_LAN" -c 3 "host $VM6_IP and host $VM4_IP" 2>/dev/null | grep -c IP)
      [[ "$n" -ge 1 ]] && ok "VM2 thay luong VM6 <-> VM4 tren NIC LAN ($n goi)" \
                        || bad "VM2 KHONG thay luong VM6 <-> VM4: kiem tra Promiscuous Mode = Allow All cua adapter lan-net"
    else
      echo "(bo qua kiem tra intra-LAN: chay lai voi tham so 'capture')"
    fi ;;
  vm3)
    expect_open    "$VM4_IP" 3306 "DMZ -> LAN MySQL (luong hop le duy nhat)"
    expect_blocked "$VM4_IP" 22   "DMZ -> LAN cong khac"
    expect_blocked "$VM4_IP" 53   "DMZ -> LAN DNS (khong nam trong ma tran)"
    expect_blocked "$VM6_IP" 22   "DMZ -> may tram LAN"
    expect_open    "$VM1_UPDATE_IP" 80 "DMZ -> may chu cap nhat"
    expect_blocked "$VM1_C2_IP" 80     "DMZ -> IP C2 (khong phai may chu cap nhat)"
    expect_blocked "$VM1_IP" 80        "DMZ -> VM1 IP chinh (khong phai may chu cap nhat)"
    check_time ;;
  vm4)
    dns_open       "$VM4_IP" example.com "dnsmasq cuc bo tra loi"
    dns_open       "$VM1_IP" example.com "resolver -> ext DNS"
    expect_open    "$VM1_IP" 80  "LAN -> ext web 80"
    expect_blocked "$VM1_IP" 22  "LAN -> ext cong khac"
    expect_blocked "$VM3_IP" 80  "LAN -> DMZ (khong co trong ma tran)"
    expect_open    "$VM4_IP" 3306 "MySQL dang nghe tren VM4"
    check_time ;;
  vm5)
    expect_open "$VM2_MGMT_IP" 22 "VM5 -> VM2 SSH qua mgmt-net"
    check_time ;;
  vm6)
    dns_open       "$VM4_IP" example.com "may tram hoi DNS qua resolver noi bo"
    dns_blocked    "$VM1_IP" example.com "may tram hoi DNS thang ra ngoai (vi pham dac ta)"
    expect_open    "$VM1_IP" 80  "LAN -> ext web 80"
    expect_blocked "$VM1_IP" 22  "LAN -> ext cong khac"
    expect_blocked "$VM3_IP" 80  "LAN -> DMZ"
    expect_open    "$VM4_IP" 3306 "intra-LAN VM6 -> VM4 MySQL"
    expect_open    "$VM4_IP" 445  "intra-LAN VM6 -> VM4 SMB"
    check_time ;;
esac

echo "== ket qua: PASS=$pass FAIL=$fail  (luu tai $out) =="
[[ $fail -eq 0 ]]
