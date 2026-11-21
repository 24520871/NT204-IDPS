# UC5 – Multi-Stage Correlation

Dùng cả 3 kỹ thuật. Cảnh báo khi >= 3 giai đoạn trong 2 giờ. Làm sau khi UC1–UC4 ổn định.

## Cấu trúc thư mục

- `README.md` – giả thuyết, dữ liệu đầu vào, logic phát hiện, kỹ thuật phát hiện, kịch bản kiểm thử lành tính/đáng ngờ, hành động chặn, kết quả đánh giá
- `*.spl` – truy vấn phát hiện (ghi kết quả vào index `detections` theo `docs/integration-contract.md`)
- `tests/` – test cases

## Checklist

- [ ] Giả thuyết + dữ liệu đầu vào
- [ ] SPL
- [ ] Test case đáng ngờ + lành tính (FP control)
- [ ] Playbook chặn
- [ ] Kết quả đánh giá
