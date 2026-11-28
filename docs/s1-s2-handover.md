# Bàn giao lab S1–S2

Tài liệu này mô tả trạng thái đã kiểm chứng của hạ tầng sáu VM (S1) và pipeline Zeek/firewall tới Splunk (S2). Các file evidence nằm trong [`evaluation/evidence/s1/`](../evaluation/evidence/s1/) và [`evaluation/evidence/s2/`](../evaluation/evidence/s2/).

## Sáu VM

| VM | Vai trò | Mạng/IP chính |
|---|---|---|
| VM1 Kali | Máy kiểm thử, giả lập Internet | EXT `10.0.0.10`; alias `10.0.0.11` (update), `.12` (C2), `.13` (exfil) |
| VM2 Firewall/Zeek | nftables, định tuyến, cảm biến Zeek, UF | EXT `10.0.0.1`; DMZ `10.0.1.1`; LAN `10.0.2.1`; MGMT `10.0.9.1` |
| VM3 Web Server | Web server trong DMZ | DMZ `10.0.1.10`, gateway `10.0.1.1` |
| VM4 LAN Server | MySQL, chia sẻ file, dịch vụ LAN | LAN `10.0.2.10`, gateway `10.0.2.1` |
| VM5 Splunk | Splunk Enterprise, nhận log | MGMT `10.0.9.10`; Host-only `192.168.56.10` |
| VM6 Workstation | Máy trạm LAN | LAN `10.0.2.21`, alias `.22`, gateway `10.0.2.1` |

Các mạng nội bộ là `ext-net` (`10.0.0.0/24`), `dmz-net` (`10.0.1.0/24`), `lan-net` (`10.0.2.0/24`) và `mgmt-net` (`10.0.9.0/24`). VM5 mở Splunk Web cho máy host tại `http://192.168.56.10:8000`. VM2 dùng các interface EXT/DMZ/LAN `enp0s3`/`enp0s8`/`enp0s9` cho Zeek; MGMT không được sniff. Tên interface có thể cần đối chiếu trong VirtualBox và guest trước khi khởi động.

## Thứ tự bật máy đề xuất

1. VM2 Firewall/Zeek để mạng và thời gian lab sẵn sàng.
2. VM4 LAN Server và VM3 Web Server.
3. VM5 Splunk, chờ dịch vụ Splunk và receiving TCP 9997 sẵn sàng.
4. VM6 Workstation và VM1 Kali khi cần tạo hoặc kiểm tra traffic.

Nếu máy host không đủ RAM, chỉ bật nhóm VM cần cho buổi làm việc. Có thể tắt VM1/VM6 khi không tạo traffic; không cần chạy đồng thời cả sáu VM cho mọi thao tác tài liệu. VM5 được gợi ý 6–8 GB RAM trong thiết kế; điều chỉnh số máy chạy đồng thời theo tài nguyên thực tế.

## Kiểm tra S1

Evidence `evaluation/evidence/s1/` có output cho cả sáu VM. Các file ghi kết quả kiểm tra theo từng VM và số PASS/FAIL; đọc output gốc khi cần phân biệt dịch vụ đã được kiểm tra với những phép thử chỉ ghi phản hồi mạng. Đặc biệt, các dòng DNS trong một số output có nội dung `connection refused` dù script ghi PASS; không xem đó là bằng chứng DNS resolver hoạt động.

## Kiểm tra S2

Trên VM2, kiểm tra Zeek và UF:

```bash
sudo zeekctl status
sudo zeekctl diag
sudo /opt/splunkforwarder/bin/splunk list forward-server
sudo /opt/splunkforwarder/bin/splunk btool inputs list --debug
sudo /opt/splunkforwarder/bin/splunk btool outputs list --debug
```

UF trong lab báo Active tới `10.0.9.10:9997`. Tài khoản dịch vụ UF cần quyền đọc `/var/log/kern.log` (đã thêm vào group `adm`). Log Zeek JSON được đọc tại `/opt/zeek/spool/logger/*.log`; `conn.log` đã được xác minh có trường Community ID.

Trên VM5 hoặc Splunk Web (`http://192.168.56.10:8000`), chạy SPL:

```spl
index=zeek_all
```

```spl
index=zeek_all sourcetype="zeek:json" "conn.log"
```

```spl
index=fw_audit sourcetype="linux:kernel" "nft-deny"
```

Trong lab đã xác nhận Zeek events ở index `zeek_all` và firewall `nft-deny` events ở `fw_audit`. VM5 nhận TCP 9997; UI dùng Host-only IP trên. Không giả định Splunk Add-on for Zeek đã cài.

## Bàn giao máy ảo

Để export OVA, tắt hoàn toàn guest trước, sau đó dùng VirtualBox Manager > File > Export Appliance và chọn VM cần bàn giao. Bảo quản OVA ở nơi phù hợp; OVA có thể chứa dữ liệu máy và không nên commit vào repository. Khi import bản sao để chạy đồng thời với máy gốc, chọn tạo địa chỉ MAC mới cho các adapter để tránh trùng MAC trên cùng mạng. Sau import, đối chiếu lại thứ tự adapter, tên Internal Network/Host-only, interface trong guest và địa chỉ IP trước khi bật nhiều VM.

Danh sách bàn giao: VM1 Kali, VM2 Firewall/Zeek, VM3 Web Server, VM4 LAN Server, VM5 Splunk, VM6 Workstation. Không đưa mật khẩu, token hoặc khóa vào repo hay tài liệu bàn giao; trao đổi thông tin truy cập qua kênh được nhóm phê duyệt.
