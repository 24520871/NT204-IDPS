# Kiến trúc

Chi tiết IP và cách dựng: [network-plan.md](network-plan.md). Sơ đồ: `docs/diagrams/Zeek_Splunk_System_Architecture.drawio`, `docs/diagrams/nt204.drawio.png`.

## Bảng 3.1 – Máy ảo

| VM | Vùng | Vai trò | Gợi ý cấu hình |
|---|---|---|---|
| VM1 Kali | ext-net | Attacker + giả lập Internet (C2, DNS, exfil, INetSim) | 1 vCPU, 2 GB |
| VM2 Ubuntu FW+Zeek | ext, dmz, lan, mgmt (4 NIC) | nftables, Block Agent, Zeek, Splunk UF | 2 vCPU, 4 GB |
| VM3 Ubuntu Web | dmz-net | Web app có lỗ hổng (DB ở LAN) | 1 vCPU, 1–2 GB |
| VM4 Ubuntu LAN | lan-net | MySQL, file share, DNS resolver (dnsmasq) | 2 vCPU, 3 GB |
| VM6 Ubuntu workstation | lan-net | Máy trạm LAN (thay 2 container macvlan; 2 IP) — lệch đề cương gốc 5 VM | 1 vCPU, 1 GB |
| VM5 Splunk | mgmt-net | Splunk Enterprise + Add-on for Zeek | 2 vCPU, 6–8 GB |

## Network
4 VirtualBox Internal Network: `ext-net`, `dmz-net`, `lan-net`, `mgmt-net`. VM2 là router và điểm kiểm soát duy nhất. Chrony đồng bộ về VM2.

## Bảng 3.2 – Ma trận luồng cho phép

| Luồng | Dịch vụ |
|---|---|
| ext → DMZ | TCP 80/443 tới web server |
| DMZ → LAN | TCP 3306 web → DB |
| DMZ → ext | TCP 80/443 chỉ tới IP update server |
| LAN client → resolver nội bộ | UDP/TCP 53 |
| Resolver → ext | UDP/TCP 53 |
| LAN → ext | TCP 80/443 |
| VM2 ↔ VM5 | TCP 9997, HTTPS tới Block Agent |
| Còn lại | Deny (Zeek vẫn ghi nhận) |

## Luồng dữ liệu
Zeek (VM2) → JSON logs → Splunk UF → VM5 (index `zeek_ext`/`zeek_dmz`/`zeek_lan`) → SPL detections → index `detections` → correlation/alert → webhook → Block Agent (VM2) → nftables.

## Vị trí sensor Zeek
Zeek trên VM2 nghe **3 NIC: ext, DMZ, LAN** (không nghe mgmt).
- NIC ext: thấy cả lưu lượng từ Internet giả (VM1) **bị firewall chặn** (scan, brute force); gói bị drop ở VM2 chỉ xuất hiện trên NIC này. Dữ liệu này nhiều và nhiễu hơn: SPL phải loại trừ IP đã bị block để không tạo cảnh báo lặp.
- NIC DMZ và LAN: thấy luồng DMZ↔LAN và lưu lượng LAN ra ngoài.
- Luồng intra-LAN (VM6 ↔ VM4) chỉ thấy được khi NIC LAN bật promiscuous "Allow All" (kiểm chứng ở S1).
- Một luồng đi qua VM2 bị thấy trên hai NIC: khử trùng lặp theo `community_id`.
