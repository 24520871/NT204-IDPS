# VM5 – Splunk Enterprise

VM5 là máy chủ thu thập log trong mạng quản trị. Splunk Enterprise đã được cài đặt và đang chạy trong lab.

## Truy cập và cấu hình

- Splunk Web từ máy host: `http://192.168.56.10:8000`.
- Receiving port: TCP 9997, khai báo trong [`inputs.conf`](inputs.conf).
- [`indexes.conf`](indexes.conf) khai báo hai index: `zeek_all` và `fw_audit`.
- VM2 forward dữ liệu tới `10.0.9.10:9997`.

Chưa xác nhận Splunk Add-on for Zeek đã được cài; do đó không dựa vào field extraction của add-on trong các truy vấn kiểm tra dưới đây. Trial/license và ngày bắt đầu chưa được ghi nhận trong repository.

## Kiểm tra

Trên Splunk Web, tìm kiếm các event mới nhận:

```spl
index=zeek_all
```

```spl
index=fw_audit "nft-deny"
```

Trong trang Settings > Forwarding and receiving > Configure receiving, xác nhận port 9997 đang bật. Kết quả đã kiểm chứng: có Zeek events trong `zeek_all` và firewall `nft-deny` events trong `fw_audit`; evidence nằm trong [`evaluation/evidence/s2/`](../../evaluation/evidence/s2/).

## Checklist trạng thái

- [x] Splunk Enterprise đã cài và chạy.
- [x] TCP 9997 receiving và hai index đã cấu hình/được dùng trong lab.
- [ ] Cài Add-on for Zeek: chưa xác minh.
- [ ] Ghi nhận trạng thái/ngày bắt đầu license: chưa xác minh.
- [ ] Deploy app `idps_lab`: chưa thuộc bàn giao S1–S2.
