# Basic Attack Rules

Port scan, brute force (SPL theo ngưỡng). Tự động chặn block_src, timeout 30 phút.

## Checklist

- [ ] port-scan.spl
- [ ] brute-force.spl
- [ ] Test cases
- [ ] Cấu hình alert 1 phút + overlap window

## Dữ liệu đầu vào
Dùng index `zeek_ext` (NIC ext, thấy cả scan/brute force bị firewall chặn). Loại trừ IP nguồn đã nằm trong danh sách block để không tạo cảnh báo lặp sau khi chặn.
