# Splunk Universal Forwarder (VM2)

Universal Forwarder (UF) trên VM2 chuyển log Zeek và log kernel của firewall tới Splunk Enterprise trên VM5 qua TCP 9997.

## Cấu hình trong repository

- [`inputs.conf`](inputs.conf) theo dõi `/opt/zeek/spool/logger/*.log`, gửi vào index `zeek_all` với sourcetype `zeek:json`.
- Cùng file theo dõi `/var/log/kern.log`, gửi vào index `fw_audit` với sourcetype `linux:kernel`.
- [`outputs.conf`](outputs.conf) định tuyến tới `10.0.9.10:9997` qua output group `splunk_vm5`.
- User dịch vụ UF phải đọc được `/var/log/kern.log`; trong máy lab đã được thêm vào group `adm`.

## Cài đặt và áp dụng

VM2 dùng Ubuntu Server 22.04.5. Đã cài Splunk Universal Forwarder 10.6.2.5. Khi cài đặt hoặc cập nhật cấu hình, dùng gói và tài khoản dịch vụ UF đã chuẩn bị trên VM; không commit thông tin xác thực.

Sau khi đặt hai file cấu hình vào thư mục cấu hình của UF, khởi động lại dịch vụ UF. Đường dẫn cài đặt mặc định thường là `/opt/splunkforwarder/etc/system/local/`; xác nhận `SPLUNK_HOME` thực tế trên VM trước khi chép file.

## Kiểm tra trên VM2

```bash
sudo -u splunkforwarder /opt/splunkforwarder/bin/splunk list forward-server
sudo -u splunkforwarder /opt/splunkforwarder/bin/splunk btool inputs list --debug
sudo -u splunkforwarder /opt/splunkforwarder/bin/splunk btool outputs list --debug
id splunkforwarder
sudo -u splunkforwarder test -r /var/log/kern.log && echo "kern.log readable"
```

Tên user dịch vụ có thể khác theo cách cài đặt. Kết quả đã kiểm chứng trong lab: UF báo Active forward tới `10.0.9.10:9997`; Splunk nhận Zeek events trong `zeek_all` và sự kiện `nft-deny` trong `fw_audit`. Ảnh kiểm chứng nằm trong [`evaluation/evidence/s2/`](../../../evaluation/evidence/s2/).

## Phạm vi hiện tại

Chỉ cấu hình hai nguồn log ở trên. Chưa cấu hình input riêng cho audit Block Agent; Block Agent là phần việc giai đoạn sau.
