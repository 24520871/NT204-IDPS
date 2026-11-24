# VM6 – LAN workstation

Máy trạm LAN, thay cho 2 container macvlan trong đề cương gốc (lưu lượng macvlan cùng NIC không ra dây nên Zeek không thấy). Dùng làm:
- nguồn lưu lượng lành tính (web, DNS qua resolver VM4, cron update, backup đêm);
- máy bị chiếm quyền trong UC1 (dò quét SSH/SMB tới VM4), nguồn tunnel UC2, beacon UC4, exfil UC3;
- IP `10.0.2.21` (chính) và alias `10.0.2.22` để có 2 danh tính máy trạm.

Cấu hình tối thiểu: Ubuntu 24.04 Server, 1 vCPU, 1 GB RAM.

## Checklist
- [ ] Netplan (`lab/render-netplan.sh vm6`)
- [ ] `install.sh`: gói cần thiết (dnsutils, curl, python3, cron), chrony client
- [ ] Chỉ dùng resolver VM4 (`10.0.2.10`) làm DNS
- [ ] Kiểm tra: VM2 thấy lưu lượng VM6 ↔ VM4 (tcpdump, rồi `conn.log` ở S2)
