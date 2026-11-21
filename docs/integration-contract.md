# Integration Contract

Thống nhất trước khi phát triển song song. Mọi thay đổi phải qua PR và thông báo cả nhóm.

## Index

| Index | Nguồn | Ghi chú |
|---|---|---|
| `zeek_dmz` | Zeek, NIC phía DMZ | JSON, có `community_id` |
| `zeek_lan` | Zeek, NIC phía LAN | JSON, có `community_id` |
| `fw_audit` | log nftables + audit Block Agent | |
| `ground_truth` | log của script tấn công | đối chiếu đánh giá |
| `detections` | kết quả mọi detection | summary index, định dạng chung bên dưới |

## Sourcetype (dự kiến – chốt ở S2)
- Zeek: sourcetype theo Splunk Add-on for Zeek (ví dụ `bro:conn:json`, `bro:dns:json`, ...) – **TODO xác nhận theo phiên bản add-on**
- `idps:blockagent:audit`, `idps:nftables`, `idps:groundtruth`, `idps:detection`

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
| `risk_score` | int | Dùng cộng dồn ở UC5 (**TODO: bảng điểm theo detection**) |
| `evidence` | string | Chuỗi bằng chứng/ngắn gọn, kèm link tới search |
| `uc` | string | `basic`, `uc1`..`uc5` |

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
