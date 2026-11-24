# Network plan và hướng dẫn dựng lab (S1)

> Lab gồm **6 VM** (lệch đề cương gốc ghi 5 VM: thay 2 container macvlan bằng 1 VM workstation VM6, vì lưu lượng macvlan cùng NIC không ra dây nên Zeek không thấy). Quyết định của trưởng nhóm; ghi rõ trong báo cáo cuối.

## 1. Sơ đồ IP

| VM | Vùng | Interface | IP |
|---|---|---|---|
| VM1 Kali | ext-net 10.0.0.0/24 | 1 NIC | 10.0.0.10; alias 10.0.0.11 (update), .12 (C2), .13 (exfil) |
| VM2 Firewall + Zeek | 4 NIC | ext / dmz / lan / mgmt | 10.0.0.1 / 10.0.1.1 / 10.0.2.1 / 10.0.9.1 |
| VM3 Web | dmz-net 10.0.1.0/24 | 1 NIC | 10.0.1.10, gateway 10.0.1.1 |
| VM4 LAN server | lan-net 10.0.2.0/24 | 1 NIC | 10.0.2.10 (MySQL, file share, dnsmasq), gateway 10.0.2.1 |
| VM6 LAN workstation | lan-net | 1 NIC | 10.0.2.21; alias 10.0.2.22, gateway 10.0.2.1 |
| VM5 Splunk | mgmt-net 10.0.9.0/24 | 2 NIC | 10.0.9.10; Host-only 192.168.56.10 |

Không dùng NAT giữa các vùng: VM2 chỉ định tuyến. VM1 cần route tới `10.0.1.0/24`, `10.0.2.0/24` qua `10.0.0.1` để trả lời lưu lượng.

## 2. VirtualBox
Tạo 4 Internal Network tên `ext-net`, `dmz-net`, `lan-net`, `mgmt-net`.

| VM | Adapter |
|---|---|
| VM1 | 1: Internal `ext-net` |
| VM2 | 1: `ext-net`, 2: `dmz-net`, 3: `lan-net`, 4: `mgmt-net`. **Adapter 3 (lan-net): Promiscuous Mode = Allow All.** Nên đặt Allow All cho cả adapter 2 (dmz-net) |
| VM3 | 1: `dmz-net` |
| VM4, VM6 | 1: `lan-net` |
| VM5 | 1: `mgmt-net`, 2: **Host-only** (mở Splunk Web và SSH từ máy host, IP 192.168.56.10) |

Tên interface trong guest có thể khác (`enp0s3`, `enp0s8`...). Kiểm tra bằng `ip -br a` và nếu khác `lab/lab.env` thì ghi đè trong `lab/lab.local.env` (không commit).

## 3. Hai giai đoạn
**Giai đoạn A (có Internet, cài gói):** mỗi VM dùng 1 adapter **NAT** thay cho adapter nội bộ. Cài Ubuntu, `apt` cập nhật, cài openssh-server, clone repo, tải file cài nặng (Splunk) bằng tay. Snapshot `base`.

**Giai đoạn B (cô lập):** đổi adapter sang Internal Network theo bảng trên, áp netplan cố định, chạy `install.sh`/`apply.sh` từng VM. Snapshot `s1-done` sau khi `scripts/verify-s1.sh` đạt.

Lưu ý: các gói cần Internet (Zeek, Splunk Add-on...) phải cài xong ở giai đoạn A.

## 4. Các bước dựng
1. Tạo 6 VM ở giai đoạn A, cài OS (Ubuntu 24.04 LTS Server cho VM2–VM6, Kali cho VM1). Cấu hình tối thiểu: VM6 1 vCPU/1 GB.
2. Trên mỗi VM: `git clone`; nếu tên interface khác `lab/lab.env` thì tạo `lab/lab.local.env` để ghi đè.
3. Giai đoạn B: đổi adapter, áp netplan: `sudo bash lab/render-netplan.sh <vm>` (vm = `vm1`…`vm6`) rồi `sudo netplan apply`.
4. Chạy `install.sh` / `apply.sh` của từng VM (xem `lab/README.md`).
5. chrony: VM2 là nguồn thời gian, các VM còn lại đồng bộ với VM2.
6. Chạy `scripts/verify-s1.sh` và lưu output vào `evaluation/evidence/s1/`.

## 5. Kiểm chứng intra-LAN
Mục tiêu: Zeek ở VM2 phải thấy lưu lượng VM6 ↔ VM4. Ở S1 kiểm bằng `tcpdump -ni <IF_LAN của VM2> host 10.0.2.21 and host 10.0.2.10` khi VM6 ping/connect tới VM4. Xác nhận lại bằng `conn.log` ở S2.

## 6. Truy cập các VM
- **VM5:** Splunk Web `http://192.168.56.10:8000` và SSH `ssh <user>@192.168.56.10` từ máy host. Từ VM5 có thể SSH sang VM2 qua mgmt-net (`10.0.9.1`).
- **VM1, VM3, VM4, VM6:** thao tác qua cửa sổ console của VirtualBox (không có adapter Host-only).
- Adapter Host-only nằm ngoài lab: VM2 không định tuyến qua nó và Zeek không thấy.

## 7. Chạy các script
Mỗi `install.sh` nhận một tham số chế độ:
```bash
sudo bash lab/<vm>/install.sh packages    # giai đoạn A (cần Internet)
sudo bash lab/<vm>/install.sh configure   # giai đoạn B (offline)
```
Riêng VM3 có thêm `init` (tạo DB DVWA sau khi VM4 sẵn sàng); VM5 có `splunk` (cần file `.deb`, xem đầu file `lab/vm5-splunk/install.sh`). Kiểm thử: `bash scripts/verify-s1.sh <vm>` (VM2 thêm `capture`).
