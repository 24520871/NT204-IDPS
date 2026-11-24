# NT204 – IDPS dựa trên Zeek và Splunk (Nhóm 7)

Hệ thống phát hiện và ngăn chặn xâm nhập cho lab mô phỏng doanh nghiệp nhỏ (ext / DMZ / LAN / mgmt). Zeek phân tích lưu lượng thụ động, Splunk tiếp nhận/tương quan/cảnh báo, nftables thực thi chặn qua Block Agent.

- Tiến độ: xem [BUILD_PLAN.md](BUILD_PLAN.md)
- Hợp đồng tích hợp: [docs/integration-contract.md](docs/integration-contract.md)
- Kiến trúc: [docs/architecture.md](docs/architecture.md)
- Giới hạn: [docs/limitations.md](docs/limitations.md)

## Cấu trúc

| Thư mục | Nội dung |
|---|---|
| `lab/` | Hướng dẫn và cấu hình cho 5 VM (kali, firewall+zeek, web DMZ, LAN, Splunk) |
| `zeek/` | Signature `.sig` và IOC Intel |
| `splunk/apps/idps_lab/` | Splunk app (indexes, macros, savedsearches, dashboards) |
| `detections/` | Basic rules, UC1–UC5 (SPL, README, tests) |
| `attacks/` | Script tấn công có ghi ground truth, evasion |
| `traffic/` | Script sinh traffic lành tính |
| `evaluation/` | Ground truth, SPL đánh giá, kết quả, bằng chứng |
| `playbooks/` | Response playbook |
| `scripts/` | Tiện ích chung |

## Quy ước làm việc
- Nhánh `<stage>/<use-case>-<mô-tả>` (VD `s4/uc2-entropy-rule`), commit bắt đầu bằng `[S4][UC2]`; mỗi PR cần 1 reviewer khác, squash merge. Chi tiết trong `docs/integration-contract.md`.
- Không commit credential, token, pcap hoặc file máy ảo.
- Docs tiếng Việt; code, tên file và tên trường tiếng Anh.
