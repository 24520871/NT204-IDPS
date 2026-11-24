# BUILD_PLAN – IDPS dựa trên Zeek và Splunk (NT204 – Nhóm 7)

Nguồn: `Group7_Proposal_NT204_IDPS_v3.docx`. File này dùng để giám sát tiến độ theo **stage**. Kế hoạch theo tuần do nhóm quản lý ở file task riêng.

**Quy ước trạng thái:** ⬜ chưa bắt đầu · 🟨 đang làm · ✅ hoàn thành · ⛔ bị chặn
**Ưu tiên:** Core = bắt buộc · Sau-S4 = làm khi UC1–UC4 ổn định · Mở rộng = làm cuối nếu còn thời gian
**Cập nhật:** tick checkbox trong stage, rồi cập nhật bảng tổng quan và Changelog ở cuối file.

## Tổng quan tiến độ

| Stage | Tên | Ưu tiên | Owner | Trạng thái | % |
|---|---|---|---|---|---|
| S0 | Repo & Integration Contract | Core | Cả nhóm | ✅ | 100 |
| S1 | Lab infrastructure (5 VM, network, nftables) | Core | M1 | ⬜ | 0 |
| S2 | Log ingestion & data quality | Core | M2 | ⬜ | 0 |
| S3 | Benign traffic & baseline | Core | M2 | ⬜ | 0 |
| S4 | Detection engineering (Basic rules + UC1–UC4) | Core | M3 (Basic, UC1, UC2) · M4 (UC3, UC4) | ⬜ | 0 |
| S5 | Prevention & response (Block Agent, playbook) | Core | M1 | ⬜ | 0 |
| S6 | UC5 multi-stage correlation & dashboard | Sau-S4 | M2 | ⬜ | 0 |
| S7 | Testing & evaluation | Core | M4 | ⬜ | 0 |
| S8 | Tuning, evasion, báo cáo & demo | Mở rộng/Final | Cả nhóm | ⬜ | 0 |

**Phụ thuộc:** S0 → S1 → S2 → S3 → S4 → S5 → S7 → S8. S6 sau S4 (cần UC1–UC4) và dùng S5. S4 có thể chia song song giữa các thành viên (mỗi UC một thư mục) nhờ Integration Contract ở S0. Thiết kế playbook (S5) và script tấn công (S7) có thể viết sớm song song với S4.

---

## S0 – Repo & Integration Contract
**Mục tiêu:** Có repo chuẩn và thỏa thuận chung để phát triển song song.
**Phụ thuộc:** không.
- [x] Skeleton repo, `.gitignore` (không commit credential, `.ova/.vdi`, pcap), `.editorconfig`
- [x] Quy ước branch/PR (feature branch, review chéo trước khi merge), template PR/issue
- [x] Điền `docs/integration-contract.md`: index/sourcetype, tên trường, timestamp, severity, risk_score
- [x] Chốt schema index `detections` (detection_name, src_ip, dest_ip, first_seen, last_seen, severity, evidence, risk_score, technique)
- [x] Chốt schema `ground_truth` và `fw_audit`
- [x] Gán owner cho từng stage/UC
- [x] Tạo thư mục cho từng use case để tránh xung đột
- [x] Chốt bảng `risk_score`, ngưỡng UC5 (≥ 3 giai đoạn / 2 giờ) và macro sourcetype Zeek
- [x] Mời M2–M4 vào repo, bật bảo vệ nhánh `main` (cần PR + 1 review)
- [x] Mỗi thành viên merge 1 PR nhỏ để kiểm chứng quy trình
- [x] Thay M1–M4 bằng tên thật trong BUILD_PLAN và contract
- [x] Chốt quy ước triển khai: monorepo, mỗi VM clone repo + chạy script của VM đó (`lab/<vm>/install.sh` lần đầu, `apply.sh` / `deploy_app.sh` sau mỗi `git pull`)
- [x] Quy ước header file `.spl` (`name/uc/technique/severity/risk_score/cron/earliest/latest`) để `scripts/build_app.sh` sinh `savedsearches.conf`

**DoD:** Cả nhóm clone repo, đọc contract, merge được PR đầu tiên.
**Deliverable:** `README.md`, `docs/integration-contract.md`, `.github/`.

## S1 – Lab infrastructure
**Mục tiêu:** Dựng 6 VM VirtualBox (5 VM đề cương + VM6 workstation), 3 vùng mạng + mgmt, luồng khớp Bảng 3.2.
**Phụ thuộc:** S0.
- [ ] 4 VirtualBox Internal Network: `ext-net`, `dmz-net`, `lan-net`, `mgmt-net`
- [ ] VM1 Kali: IP alias (update server / C2 / exfil), INetSim
- [ ] VM2 Ubuntu: 4 NIC, IP forwarding, nftables default-deny theo Bảng 3.2
- [ ] VM3 Web DMZ: ứng dụng có lỗ hổng thực thi lệnh; config chứa thông tin DB (pivot UC5)
- [ ] VM4 LAN server: MySQL, file share, resolver nội bộ (dnsmasq)
- [ ] VM6 LAN workstation (thay 2 container macvlan; IP chính + 1 alias) (quyết định của trưởng nhóm: 5 → 6 VM)
- [ ] VM5 Splunk Enterprise trên mgmt-net (ghi **ngày bắt đầu trial 60 ngày**)
- [ ] chrony: tất cả VM đồng bộ với VM2
- [ ] NIC LAN của VM2: promiscuous "Allow All"; **test S1**: VM6 ↔ VM4 thấy bằng `tcpdump` trên NIC LAN của VM2 (xác nhận bằng `conn.log` ở S2)
- [ ] Viết `scripts/verify-s1.sh`; kiểm thử từng dòng ma trận luồng (cho phép + bị từ chối), lưu output vào `evaluation/evidence/s1/`
- [ ] Điền `lab/lab.env` (từ `lab/lab.env.example`) với interface thật; áp netplan bằng `lab/render-netplan.sh <vm>`
- [ ] Hoàn thiện `install.sh` cho VM1–VM6 và `apply.sh` cho VM2 (idempotent, chạy lại được)
- [ ] Đường đưa repo/gói vào VM Internal Network: NIC NAT tạm hoặc `scp`/shared folder; gỡ NIC NAT sau khi cài xong
- [ ] Snapshot VM sau khi dựng xong

**DoD:** Các luồng hợp lệ chạy được, luồng ngoài ma trận bị drop và Zeek thấy; intra-LAN visibility được kiểm chứng.
**Deliverable:** `lab/**`, `docs/architecture.md`, sơ đồ topology.
**Rủi ro:** tài nguyên host (tổng ~8 vCPU, ~16–19 GB RAM) → điều chỉnh cấu hình.

## S2 – Log ingestion & data quality
**Mục tiêu:** Log Zeek/nftables/Block Agent vào Splunk đúng index, đúng field.
**Phụ thuộc:** S1.
- [ ] Zeek trên 2 NIC (DMZ, LAN), JSON output, bật `community_id`
- [ ] Zeek log: conn, dns, http, ssl, ssh, weird, signatures, notice, intel
- [ ] Splunk UF trên VM2 (inputs/outputs)
- [ ] Splunk Add-on for Zeek (CIM mapping)
- [ ] Tạo 5 index: `zeek_dmz`, `zeek_lan`, `fw_audit`, `ground_truth`, `detections`
- [ ] Dedup theo `community_id` cho luồng DMZ↔LAN thấy trên 2 NIC
- [ ] Data quality checks (đủ log, timestamp khớp, field src/dst/port/proto parse đúng, dedup hoạt động)
- [ ] Lưu cấu hình dưới dạng Splunk app `splunk/apps/idps_lab`
- [ ] Hoàn thiện `scripts/build_app.sh` + `lab/vm5-splunk/deploy_app.sh` (ghép `detections/*/*.spl` → `savedsearches.conf`, deploy vào VM5)
- [ ] Hoàn thiện `lab/vm2-firewall-zeek/apply.sh` cho Zeek (.sig, .intel, local.zeek) và Universal Forwarder
- [ ] Dashboard tình trạng ingest

**DoD:** Dashboard ingest xanh; truy vấn mẫu trả đúng; dedup xác nhận không nhân đôi.
**Deliverable:** `lab/vm2-firewall-zeek/{zeek,uf}`, `splunk/apps/idps_lab`, `scripts/`.

## S3 – Benign traffic & baseline
**Mục tiêu:** Baseline sạch, tách khỏi dữ liệu kiểm thử.
**Phụ thuộc:** S2.
- [ ] Web browsing tới INetSim
- [ ] DNS query danh sách domain hợp lệ qua resolver
- [ ] Cron job cập nhật có chu kỳ (FP control UC4)
- [ ] Backup lớn ban đêm (FP control UC3)
- [ ] Truy cập web DMZ từ IP ngoài lành tính
- [ ] Thu baseline tối thiểu 24–48 giờ (đánh dấu khoảng thời gian, tách riêng)
- [ ] Tính p95/p99 theo host cho các chỉ số (DNS length/entropy, interval, bytes out, cặp host)
- [ ] Lưu baseline (lookup/summary index)

**DoD:** Baseline đủ 24–48h, có bảng ngưỡng p95/p99 theo host.
**Deliverable:** `traffic/`, lookup baseline trong app Splunk.

## S4 – Detection engineering
**Mục tiêu:** Detection cho Basic rules và UC1–UC4, ghi vào index `detections`.
**Phụ thuộc:** S3 (có thể bắt đầu viết song song từ S2).
**Chung**
- [ ] Zeek signature (.sig): payload khai thác web DMZ, User-Agent công cụ scan
- [ ] Zeek Intel: IOC lab (IP/domain C2, domain tunnel, hash)
- [ ] Specification-based: ma trận 3.2, đặc tả DNS, đặc tả DMZ, đặc tả HTTP; `weird.log` chỉ bổ trợ
- [ ] Anomaly-based: entropy/độ dài DNS, độ đều chu kỳ, volume, cặp host mới (ngưỡng p95/p99)
- [ ] Alert: scheduled search (1 phút Basic, 5 phút UC), cửa sổ chồng lấn
- [ ] Mỗi detection ghi đúng schema chung vào `detections`

**Basic Attack Rules** (`detections/basic-attack-rules`)
- [ ] Port scan (conn.log: số cổng/host khác nhau, tỷ lệ fail)
- [ ] Brute force (http.log mã trạng thái login hoặc ssh.log/conn.log)

**UC1 – Lateral movement & internal recon** (spec + anomaly)
- [ ] DMZ→LAN sai cổng/đích; nhiều REJ/S0; cặp host mới
- [ ] Test đáng ngờ + lành tính, README use case

**UC2 – DNS tunneling** (anomaly + spec)
- [ ] Subdomain dài/entropy cao, unique subdomain/domain gốc, tỷ lệ TXT/NULL, vi phạm đặc tả DNS
- [ ] Test dnscat2/iodine + DNS dài hợp lệ (FP control)

**UC3 – Data exfiltration** (anomaly + spec)
- [ ] Tỷ lệ bytes out/in, volume > p95/p99, đích mới, thời lượng phiên (HTTPS: chỉ ssl.log/conn.log, nêu giới hạn)
- [ ] Test exfil + backup đêm (FP control)

**UC4 – C2 beaconing** (anomaly + signature)
- [ ] Độ lệch chuẩn/trung bình khoảng cách kết nối, kích thước ổn định, khớp intel.log
- [ ] Test beacon + cron update (FP control)

**DoD:** Mỗi detection fire đúng trên ít nhất 1 lần chạy thử, không fire trên benign mẫu; code merge qua PR có review.
**Deliverable:** `detections/**`, `zeek/**`, `attacks/**` (bản chạy thử).

## S5 – Prevention & response
**Mục tiêu:** Từ cảnh báo Splunk dẫn tới chặn trên nftables một cách an toàn.
**Phụ thuộc:** S1 (nftables), S4 (alert để kích hoạt).
- [ ] nftables set có timeout (blocked_src/dst/egress, isolated_hosts)
- [ ] Block Agent Python (`lab/vm2-firewall-zeek/block-agent`): chỉ nghe mgmt-net, chỉ nhận IP VM5 + token
- [ ] 4 action cố định (block_src, block_dst, block_egress, isolate_host), validate tham số, không chạy lệnh tùy ý
- [ ] Allowlist (VM2, VM5, gateway, admin)
- [ ] Audit log → index `fw_audit`
- [ ] Splunk webhook/custom alert action gửi yêu cầu chặn
- [ ] Playbook Bảng 3.3 (`playbooks/`): basic tự động; UC1–UC5 analyst duyệt
- [ ] Queue cảnh báo chờ duyệt trên dashboard
- [ ] Unit test Block Agent; test an toàn (không chặn allowlist)
- [ ] Ghi giới hạn: intra-LAN isolate thủ công, chặn sau phát hiện

**DoD:** Basic rule tự động chặn IP ngoài, lệnh hết hạn đúng timeout; UC chặn được sau khi analyst duyệt; mọi hành động có audit log.
**Deliverable:** `lab/vm2-firewall-zeek/block-agent`, `playbooks/`, alert action trong app.

## S6 – UC5 multi-stage correlation & dashboard
**Mục tiêu:** Nhận diện chuỗi tấn công ≥ 3 giai đoạn trong cửa sổ 2 giờ.
**Phụ thuộc:** S4 ổn định, S5.
- [ ] Cộng dồn `risk_score` theo thực thể từ index `detections`
- [ ] Đếm số giai đoạn/kỹ thuật khác nhau; cảnh báo khi ≥ 3 giai đoạn / 2 giờ
- [ ] Kịch bản chuỗi: web exploit → egress trái spec → pivot DB/dò LAN → C2 → exfil
- [ ] Playbook UC5 (block_src + isolate_host + block_dst)
- [ ] Dashboard tổng hợp (theo detection/kỹ thuật, host nhiều cảnh báo, IP/domain đáng chú ý, xu hướng, ingest, hành động chặn, queue duyệt)
- [ ] **Fallback** nếu thiếu thời gian: trình diễn bằng dashboard tương quan + chặn thủ công

**DoD:** Chạy end-to-end chuỗi UC5, cảnh báo chuỗi fire, ghi lại các giai đoạn hoàn thành trước khi chặn.
**Deliverable:** `detections/uc5-multistage`, dashboard trong app.

## S7 – Testing & evaluation
**Mục tiêu:** Số liệu đánh giá có thể tái lập.
**Phụ thuộc:** S4, S5 (S6 cho UC5).
- [ ] Script tấn công ghi `ground_truth` (start/end, src/dst, action) → ingest
- [ ] Mỗi use case chạy ≥ 5 lần ở các thời điểm khác nhau, xen traffic lành tính
- [ ] Kịch bản FP chạy song song (cron, backup, DNS dài hợp lệ)
- [ ] Đơn vị: attack episode = mẫu dương; cửa sổ lành tính 15 phút/host = mẫu âm
- [ ] SPL đối chiếu tự động ground truth ↔ detections
- [ ] Metrics: Precision, Recall, FPR
- [ ] Latency 3 đoạn: attack→alert; alert→analyst duyệt (chỉ ghi nhận); yêu cầu chặn→rule có hiệu lực
- [ ] Lượng traffic lọt trước khi chặn; tỷ lệ chặn nhầm
- [ ] Basic rules đánh giá riêng
- [ ] Lưu kết quả (`evaluation/results`) và bằng chứng (`evaluation/evidence`)

**DoD:** Bảng metrics theo từng UC + Basic rules, kèm bằng chứng và mô tả giới hạn.
**Deliverable:** `evaluation/**`.

## S8 – Tuning, evasion, báo cáo & demo
**Mục tiêu:** Hoàn thiện và đóng gói.
**Phụ thuộc:** S7.
- [ ] Tuning ngưỡng/logic; ghi FP/FN và giới hạn từng detection
- [ ] (Mở rộng) Evasion: scan chậm, DNS tunneling giảm tốc, beacon jitter, exfil chia nhỏ/chậm, payload biến đổi
- [ ] (Mở rộng) Đo trước/sau tuning
- [ ] `docs/limitations.md` hoàn chỉnh
- [ ] README triển khai, sơ đồ topology, response playbook cuối
- [ ] Báo cáo đánh giá
- [ ] Kịch bản demo + chạy thử
- [ ] Kiểm tra repo không có credential/file VM; tag release

**DoD:** Repo hoàn chỉnh, demo chạy trơn tru, báo cáo nộp.
**Deliverable:** báo cáo, `docs/`, `README.md`, tag.

---

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Splunk trial 60 ngày, sau đó alert ngừng | Dựng VM5 sao cho phát triển + đánh giá nằm trọn trong trial; lưu cấu hình dưới dạng app trong GitHub |
| Thiếu tài nguyên host | Điều chỉnh cấu hình VM (VM6 chỉ 1 vCPU/1 GB); tổng 6 VM |
| Không thấy traffic intra-LAN | Máy trạm là VM riêng (VM6) thay container macvlan; promiscuous "Allow All" + tcpdump ở S1; nếu không được, nêu giới hạn |
| HTTPS làm hạn chế phát hiện exfil | Dựa vào volume/thời gian; nêu rõ trong báo cáo |
| Trùng lặp bản ghi DMZ↔LAN | `community_id` + dedup |
| Thiếu thời gian UC5 | Fallback dashboard + chặn thủ công |
| Block nhầm | Allowlist, timeout, analyst duyệt cho UC |

## Changelog tiến độ

| Ngày | Stage | Ghi chú |
|---|---|---|
| | | |
