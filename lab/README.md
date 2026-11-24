# Lab – hướng dẫn dựng 5 VM (thủ công)

Xem bảng cấu hình ở [docs/architecture.md](../docs/architecture.md).

## Thứ tự
1. Tạo 4 VirtualBox Internal Network: `ext-net`, `dmz-net`, `lan-net`, `mgmt-net`.
2. VM2 (firewall + Zeek): 4 NIC; NIC LAN bật Promiscuous Mode = Allow All.
3. VM4, VM3, VM1, VM5.
4. chrony: VM2 là nguồn thời gian cho các VM còn lại.
5. Kiểm thử ma trận luồng và intra-LAN visibility (xem BUILD_PLAN S1).

## Cách áp dụng repo vào VM
Một repo (monorepo); mỗi VM clone cả repo và chỉ chạy script của mình.

```bash
git clone https://github.com/24520871/NT204-IDPS.git && cd NT204-IDPS
cp lab/lab.env.example lab/lab.env   # điền IP/interface thật (file này không commit)
sudo bash lab/<vm>/install.sh        # lần đầu
# về sau, sau mỗi git pull:
sudo bash lab/vm2-firewall-zeek/apply.sh   # VM2: nftables, Zeek, forwarder, Block Agent
sudo bash lab/vm5-splunk/deploy_app.sh     # VM5: build + deploy Splunk app
```
VM1, VM3, VM4, VM6 chạy script `attacks/` và `traffic/` trực tiếp từ bản clone.
Các script hiện là khung (TODO) và được hoàn thiện ở S1–S2.

VM trong Internal Network không ra Internet: dùng NIC NAT tạm hoặc `scp`/shared folder để đưa repo/gói vào, rồi gỡ NIC NAT.

## Thư mục
`vm1-kali/`, `vm2-firewall-zeek/{nftables,zeek,block-agent,uf}`, `vm3-web-dmz/`, `vm4-lan/`, `vm5-splunk/`, `vm6-workstation/`.
Hướng dẫn IP/VirtualBox/hai giai đoạn: [docs/network-plan.md](../docs/network-plan.md). Áp IP: `sudo bash lab/render-netplan.sh <vm>`.

Không commit credential, token hoặc file VM (`.ova`, `.vdi`).
