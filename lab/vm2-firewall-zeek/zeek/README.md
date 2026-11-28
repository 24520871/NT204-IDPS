# Zeek sensor (VM2)

VM2 chạy Zeek 8.0.11 và ZeekControl 2.6.0 trên Ubuntu Server 22.04.5. Zeek thu thập thụ động trên ba interface EXT, DMZ và LAN; không cấu hình worker trên interface quản trị MGMT.

## Cấu hình

- [`node.cfg`](node.cfg) khai báo ba worker: `worker-ext` trên `enp0s3`, `worker-dmz` trên `enp0s8`, `worker-lan` trên `enp0s9`.
- [`local.zeek`](local.zeek) nạp `policy/tuning/json-logs` để ghi log JSON và `policy/protocols/conn/community-id-logging` để ghi Community ID trong `conn.log`.
- Log được thu thập bởi UF từ `/opt/zeek/spool/logger/*.log`.

Interface phải tương ứng với adapter EXT/DMZ/LAN của VM2. Xác nhận ánh xạ bằng `ip -br link` trước khi áp dụng cấu hình.

## Cài đặt và kiểm tra

Zeek/ZeekControl đã được cài trên VM2. Sau khi áp dụng cấu hình site qua ZeekControl:

```bash
sudo zeekctl check
sudo zeekctl status
sudo zeekctl deploy
sudo zeekctl diag
```

Đường dẫn dữ liệu thường dùng là `/opt/zeek/spool/logger/`; kiểm tra `conn.log` có trường `community_id` và log có định dạng JSON. Kết quả lab đã xác nhận Zeek events xuất hiện trên Splunk index `zeek_all`; ảnh về Community ID và sự kiện nằm trong [`evaluation/evidence/s2/`](../../../evaluation/evidence/s2/).

## Checklist trạng thái

- [x] Cụm Zeek có worker cho EXT, DMZ và LAN theo `node.cfg`.
- [x] JSON logging được nạp từ policy `policy/tuning/json-logs`.
- [x] Community ID logging được nạp; đã có ảnh xác nhận `conn.log` chứa Community ID.
- [ ] Intel feed: chưa cấu hình/xác minh.
- [ ] Signature detection: chưa có kết quả kiểm chứng tính năng phát hiện; không tính script mặc định trong `local.zeek` là kiểm thử hoàn tất.
- [ ] Detection, dashboard, Block Agent và các giai đoạn sau nằm ngoài phạm vi S1–S2.
