# Integration Contract

Thống nhất trước khi phát triển song song. Mọi thay đổi phải qua PR và thông báo cả nhóm.

## Index

| Index | Nguồn | Ghi chú |
|---|---|---|
| `zeek_ext` | Zeek, NIC phía ext | JSON, có `community_id`; gồm cả lưu lượng bị firewall chặn |
| `zeek_dmz` | Zeek, NIC phía DMZ | JSON, có `community_id` |
| `zeek_lan` | Zeek, NIC phía LAN | JSON, có `community_id` |
| `fw_audit` | log nftables + audit Block Agent | |
| `ground_truth` | log của script tấn công | đối chiếu đánh giá |
| `detections` | kết quả mọi detection | summary index, định dạng chung bên dưới |

## Sourcetype
- Zeek: dùng sourcetype do Splunk Add-on for Zeek tạo. **Không hard-code trong SPL**: mọi SPL dùng macro (`` `zeek_conn` ``, `` `zeek_dns` ``, `` `zeek_http` ``, ...) định nghĩa trong `splunk/apps/idps_lab/default/macros.conf`. Ghi tên sourcetype thật vào macro ở S2 sau khi cài add-on.
- Tự định nghĩa: `idps:blockagent:audit`, `idps:nftables`, `idps:groundtruth`, `idps:detection`

## Định dạng `detections` (Common Detection Output)

| Trường | Kiểu | Mô tả |
|---|---|---|
| `detection_name` | string | Ví dụ `uc2_dns_tunneling`, `basic_port_scan` |
| `technique` | enum | `signature` \| `specification` \| `anomaly` |
| `src_ip` | ip | Thực thể nguồn |
| `dest_ip` | ip | Có thể rỗng |
| `first_seen` | epoch/ISO8601 | |
| `last_seen` | epoch/ISO8601 | |
| `severity` | enum | `low` \| `medium` \| `high` \| `critical` |
| `risk_score` | int | Điểm cố định theo bảng bên dưới, thang 0–100, cộng dồn ở UC5 |
| `evidence` | string | Chuỗi bằng chứng/ngắn gọn, kèm link tới search |
| `uc` | string | `basic`, `uc1`..`uc5` |

## Bảng `risk_score` (đã chốt)

| Detection | risk_score |
|---|---|
| Basic: port scan, brute force | 20 |
| Signature khớp payload khai thác web | 50 |
| Vi phạm ma trận luồng (specification) | 40 |
| Web server khởi tạo kết nối trái đặc tả | 60 |
| UC1 dò quét nội bộ | 40 |
| UC2 DNS tunneling | 50 |
| UC3 data exfiltration | 60 |
| UC4 C2 beaconing | 50 (+20 nếu khớp IOC C2) |

`severity` suy ra từ `risk_score`: < 30 `low`, 30–49 `medium`, 50–69 `high`, ≥ 70 `critical`.

**UC5:** cảnh báo chuỗi khi một host tích lũy tín hiệu từ **ít nhất 3 giai đoạn khác nhau trong 2 giờ** (bắt buộc). Các giai đoạn: exploit, egress trái spec, pivot/dò quét, C2, exfil. Tổng `risk_score` ≥ 120 chỉ dùng để xếp hạng.

## Header file `.spl`

Mỗi file `detections/<uc>/*.spl` bắt đầu bằng header; `scripts/build_app.sh` đọc header để sinh `savedsearches.conf` và tự thêm các field chuẩn (`detection_name`, `uc`, `technique`, `severity`, `risk_score`) cùng `| collect index=detections` vào cuối search. Tác giả SPL phải tự tạo các field `src_ip`, `dest_ip`, `first_seen`, `last_seen`, `evidence`.

```
# name: UC2 - DNS Tunneling
# uc: uc2
# technique: anomaly
# severity: high
# risk_score: 50
# cron: */5 * * * *
# earliest: -15m
# latest: now
```

## Quy ước Git
- `main` được bảo vệ, không push trực tiếp sau khi S0 hoàn thành.
- Tên nhánh: `<stage>/<use-case>-<mô-tả>`, ví dụ `s4/uc2-entropy-rule`.
- Mỗi PR cần 1 reviewer khác người viết, squash merge.
- Commit message bắt đầu bằng `[S4][UC2]`.
- Mỗi PR tick checklist tương ứng trong `BUILD_PLAN.md`.

## Phân công (đã chốt)

| Người | Phụ trách |
|---|---|
| M1 | S1 lab/nftables; S5 Block Agent và playbook |
| M2 | S2 ingest; S3 baseline; S6 UC5 và dashboard |
| M3 | S4: Basic rules, UC1, UC2 |
| M4 | S4: UC3, UC4; S7 evaluation |

S0 và S8 làm chung.

## Định dạng `ground_truth`

| Trường | Mô tả |
|---|---|
| `episode_id` | ID duy nhất mỗi lần chạy tấn công |
| `uc` | `basic`, `uc1`..`uc5`, `evasion_*` |
| `start_time`, `end_time` | thời điểm bắt đầu/kết thúc |
| `src_host`, `dest_host` | máy nguồn/đích |
| `action` | mô tả hành động |

## Định dạng audit Block Agent (`fw_audit`)

`ts`, `action` (`block_src|block_dst|block_egress|isolate_host`), `params`, `requested_by`, `result` (`ok|rejected|error`), `timeout_s`, `reason`.

## Quy ước chung
- Timestamp: UTC, đồng bộ chrony với VM2.
- Dedup luồng DMZ↔LAN theo `community_id`.
- Tên file/field: tiếng Anh, `snake_case`.
- Scheduled search: 1 phút (Basic), 5 phút (UC), cửa sổ chồng lấn.
