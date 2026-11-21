# Lab – hướng dẫn dựng 5 VM (thủ công)

Xem bảng cấu hình ở [docs/architecture.md](../docs/architecture.md).

## Thứ tự
1. Tạo 4 VirtualBox Internal Network: `ext-net`, `dmz-net`, `lan-net`, `mgmt-net`.
2. VM2 (firewall + Zeek): 4 NIC; NIC LAN bật Promiscuous Mode = Allow All.
3. VM4, VM3, VM1, VM5.
4. chrony: VM2 là nguồn thời gian cho các VM còn lại.
5. Kiểm thử ma trận luồng và intra-LAN visibility (xem BUILD_PLAN S1).

## Thư mục
`vm1-kali/`, `vm2-firewall-zeek/{nftables,zeek,block-agent,uf}`, `vm3-web-dmz/`, `vm4-lan/`, `vm5-splunk/`.

Không commit credential, token hoặc file VM (`.ova`, `.vdi`).
