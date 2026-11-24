# Giới hạn của hệ thống

- Zeek không inline, không tự chặn; chặn do nftables sau khi phát hiện, một phần lưu lượng tấn công vẫn lọt qua.
- Tường lửa chỉ chặn được luồng đi qua VM2; dò quét giữa hai máy trong cùng LAN không đi qua tường lửa (cô lập máy trạm VM6 thủ công).
- HTTPS: Zeek chỉ thấy `ssl.log` và số bytes trong `conn.log`, detection exfil dựa trên volume/thời gian.
- `weird.log` chủ yếu là bất thường giao thức không đặc thù, chỉ dùng bổ trợ.
- Feed IOC công khai (abuse.ch) chỉ minh họa nạp IOC tự động, không tính vào đánh giá.
- Độ trễ phát hiện tối thiểu = chu kỳ search + độ trễ ingest.
- Splunk trial 60 ngày / 500 MB/ngày; bản Free không chạy alert/scheduled search.
- Lab cô lập, không có traffic Internet thật.

> Bổ sung các giới hạn phát hiện từng use case sau khi tuning (S8).
