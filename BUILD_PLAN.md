# BUILD_PLAN – IDPS dựa trên Zeek và Splunk (NT204 – Nhóm 7)

Nguồn: `Group7_Proposal_NT204_IDPS_v3.docx`. File này dùng để giám sát tiến độ theo **stage**. Kế hoạch theo tuần do nhóm quản lý ở file task riêng.

**Quy ước trạng thái:** ⬜ chưa bắt đầu · 🟨 đang làm · ✅ hoàn thành · ⛔ bị chặn · ➖ đã gộp/bỏ
**Ưu tiên:** Core = bắt buộc · Sau-S4 = làm khi UC1–UC4 ổn định · Mở rộng = làm cuối nếu còn thời gian
**Cập nhật:** tick checkbox trong stage, rồi cập nhật bảng tổng quan và Changelog ở cuối file.

## Tổng quan tiến độ

| Stage | Tên | Ưu tiên | Người nhận | Trạng thái | % |
|---|---|---|---|---|---|
| S0 | Repo & Integration Contract | Core | Cả nhóm | ✅ | 100 |
| S1 | Lab infrastructure (6 VM, network, nftables) | Core | M1 | ⬜ | 0 |
| S2 | Log ingestion & data quality | Core | M1 | ⬜ | 0 |
| S3 | ~~Benign traffic & baseline~~ (gộp vào S4) | — | — | ➖ | — |
| S4 | Detection engineering (Basic rules + UC1–UC4, kèm benign backtest) | Core | M1 (Basic) · M3 (UC1, UC2, `.sig`/`.intel`, benign) · M4 (UC3, UC4) | ⬜ | 0 |
| S5 | Prevention & response (Block Agent, playbook) | Core | M2 | ⬜ | 0 |
| S6 | UC5 multi-stage correlation & dashboard | Sau-S4 | M2 | ⬜ | 0 |
| S7 | Testing & evaluation | Core | M4 (tổng hợp) · mỗi người chạy UC của mình | ⬜ | 0 |
| S8 | Tuning, evasion, báo cáo & demo | Mở rộng/Final | Cả nhóm | ⬜ | 0 |

## Cách làm việc: tuần tự, mỗi stage làm trọn một lần

**Thứ tự:** S0 → S1 → S2 → S4 → S5 → S6 → S7 → S8 (S3 đã gộp vào S4, giữ số hiệu để không đổi tham chiếu `[S4]`, `[S5]`... trong repo). Mỗi stage nghiệm thu trọn vẹn (tick đủ DoD) rồi mới sang stage kế.

**Viết nháp trước, nghiệm thu sau:** người chưa tới lượt được soạn bản nháp cho stage sau (SPL, Block Agent, script tấn công...), test bằng log Zeek công khai hoặc mock. Chỉ tick DoD sau khi chạy thử trên lab thật khi stage trước đã xong.

- **Phân công:** theo cột "Người nhận" ở bảng trên (chi tiết trong `docs/integration-contract.md`). M1 làm liền S1 + S2 để chỉ có **một điểm chờ** (lab + log sẵn sàng, xuất OVA một lần); trong lúc đó M2 soạn sẵn config S2 cho M1 áp, M3/M4 soạn SPL trên log Zeek công khai, M2 soạn Block Agent. Mỗi người đều có phần dựng/nền tảng, viết SPL và chạy attack thật.
- **Song song trong stage:** S4 chia theo use case (mỗi UC một thư mục, theo Integration Contract); S7 mỗi người chạy chiến dịch cho UC của mình, M4 tổng hợp.
- **Người chưa tới lượt** soạn nháp stage sau và review PR của stage hiện tại (xem "Viết nháp trước, nghiệm thu sau").
- **Bàn giao:** code/config qua git (PR đã merge). VM có dữ liệu hoặc cài đặt tốn công qua OVA đưa lên Drive nhóm, ngoài git (`.gitignore` chặn `.ova`, `.vdi`). Mỗi lần bàn giao ghi vào Changelog: ngày, link, kích thước, ghi chú (version Splunk).

| Bàn giao | OVA cần xuất | Ghi chú |
|---|---|---|
| S1 → S2 | Không cần | Cùng người (M1) làm liền; chỉ snapshot `s1-done` |
| S2 → S4, S5 | Cả 6 VM (VM5 có index + app), M1 gửi M2, M3, M4 | S4 cần chạy tấn công từ VM1; Splunk trial tính từ ngày cài, xuất muộn nhất có thể |
| S4 → S6 trở đi | Không bắt buộc | Tiếp tục trên lab đã nhập, chỉ kéo code mới qua git |

Cả lab nặng (có thể vài chục GB): xuất và gửi **VM5 trước**; các VM còn lại gửi sau, hoặc người nhận dựng lại bằng `install.sh` rồi áp config. Nếu người nhận chỉ viết SPL mà chưa chạy thử thì VM5 là đủ.

Trước khi nhập OVA: đặt đúng tên Internal Network trong `lab/lab.env`, không gửi OVA ra ngoài nhóm (chứa mật khẩu/token Splunk).

**Nút thắt thời gian:** S1 phải chạy trên VM thật trước khi nghiệm thu bất kỳ stage nào sau nó. S6 cần UC1–UC4 và Block Agent nên đứng sau S5. Không còn giai đoạn baseline 24–48 giờ: ngưỡng ban đầu lấy từ rule công khai, chỉ cần một đoạn benign ngắn ở cuối S4 để backtest.

---

## S0 – Repo & Integration Contract
**Mục tiêu:** Có repo chuẩn và thỏa thuận chung để phát triển song song.
**Phụ thuộc:** không.
- [x] Skeleton repo, `.gitignore` (không commit credential, `.ova/.vdi`, pcap), `.editorconfig`
- [x] Quy ước branch/PR (feature branch, review chéo trước khi merge), template PR/issue
- [x] Điền `docs/integration-contract.md`: index/sourcetype, tên trường, timestamp, severity, risk_score
- [x] Chốt schema index `detections` (detection_name, src_ip, dest_ip, first_seen, last_seen, severity, evidence, risk_score, technique)
- [x] Chốt schema `ground_truth` và `fw_audit`
- [x] Gán owner cho từng stage/UC (xem cột "Người nhận" và `docs/integration-contract.md`)
- [x] Tạo thư mục cho từng use case để tránh xung đột
- [x] Chốt bảng `risk_score`, ngưỡng UC5 (≥ 3 giai đoạn / 2 giờ) và macro sourcetype Zeek
- [x] Mời M2–M4 vào repo, bật bảo vệ nhánh `main` (cần PR + 1 review)
- [x] Mỗi thành viên merge 1 PR nhỏ để kiểm chứng quy trình
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
- [ ] VM5 Splunk Enterprise trên mgmt-net + adapter Host-only (192.168.56.10) để mở Splunk Web/SSH từ host; các VM khác dùng console (ghi **ngày bắt đầu trial 60 ngày**)
- [ ] chrony: tất cả VM đồng bộ với VM2
- [ ] NIC LAN của VM2: promiscuous "Allow All"; **test S1**: VM6 ↔ VM4 thấy bằng `tcpdump` trên NIC LAN của VM2 (xác nhận bằng `conn.log` ở S2)
- [x] Viết `scripts/verify-s1.sh`
- [ ] Chạy `verify-s1.sh` trên từng VM: mọi dòng ma trận luồng (cho phép + bị từ chối) PASS, lưu output vào `evaluation/evidence/s1/`
- [ ] Chỉnh `lab/lab.env` theo interface thật (VM khác thì dùng `lab/lab.local.env`); áp netplan bằng `lab/render-netplan.sh <vm>`
- [x] Viết `install.sh` cho VM1–VM6 và `apply.sh` cho VM2 (phần S1; chế độ `packages`/`configure`)
- [ ] Chạy `install.sh`/`apply.sh` trên VM thật thành công và chạy lại được (idempotent), sửa lỗi phát sinh
- [ ] Đường đưa repo/gói vào VM Internal Network: NIC NAT tạm hoặc `scp`/shared folder; gỡ NIC NAT sau khi cài xong
- [ ] Snapshot VM sau khi dựng xong
- [ ] Snapshot `s1-done` (không cần xuất OVA: M1 làm tiếp S2 trên cùng lab)

**DoD:** Các luồng hợp lệ chạy được, luồng ngoài ma trận bị drop và Zeek thấy; intra-LAN visibility được kiểm chứng.
**Deliverable:** `lab/**`, `docs/architecture.md`, sơ đồ topology.
**Rủi ro:** tài nguyên host (tổng ~8 vCPU, ~16–19 GB RAM) → điều chỉnh cấu hình.

## S2 – Log ingestion & data quality
**Mục tiêu:** Log Zeek/nftables/Block Agent vào Splunk đúng index, đúng field.
**Phụ thuộc:** S1.
- [ ] Zeek trên 3 NIC (ext, DMZ, LAN), JSON output, bật `community_id`. NIC ext để thấy cả lưu lượng bị firewall chặn (scan/brute force từ ngoài)
- [ ] Zeek log: conn, dns, http, ssl, ssh, weird, signatures, notice, intel
- [ ] Splunk UF trên VM2 (inputs/outputs)
- [ ] Splunk Add-on for Zeek (CIM mapping)
- [ ] Tạo 6 index: `zeek_ext`, `zeek_dmz`, `zeek_lan`, `fw_audit`, `ground_truth`, `detections`
- [ ] Dedup theo `community_id` cho luồng đi qua VM2 bị thấy trên nhiều NIC (ext↔DMZ, DMZ↔LAN, LAN↔ext)
- [ ] Data quality checks (đủ log, timestamp khớp, field src/dst/port/proto parse đúng, dedup hoạt động)
- [ ] Lưu cấu hình dưới dạng Splunk app `splunk/apps/idps_lab`
- [ ] Hoàn thiện `scripts/build_app.sh` + `lab/vm5-splunk/deploy_app.sh` (ghép `detections/*/*.spl` → `savedsearches.conf`, deploy vào VM5)
- [ ] Hoàn thiện `lab/vm2-firewall-zeek/apply.sh` cho Zeek (.sig, .intel, local.zeek) và Universal Forwarder
- [ ] Dashboard tình trạng ingest
- [ ] Bàn giao: xuất OVA cả 6 VM (VM5 đã có index + app; gửi VM5 trước) lên Drive nhóm cho M2, M3, M4, ghi Changelog; push `macros.conf` với sourcetype thật

**DoD:** Dashboard ingest xanh; truy vấn mẫu trả đúng; dedup xác nhận không nhân đôi.
**Deliverable:** `lab/vm2-firewall-zeek/{zeek,uf}`, `splunk/apps/idps_lab`, `scripts/`.

## S3 – (đã gộp vào S4)
Không còn là stage riêng. Rule bắt đầu từ rule công khai với ngưỡng ban đầu; traffic lành tính và baseline chỉ cần một đoạn ngắn, đặt ở cuối S4 để backtest và chỉnh ngưỡng (rule chỉ xét cửa sổ gần nhất, log lành tính cũ chỉ dùng để tính ngưỡng và backtest). Số hiệu S3 được giữ để không đổi tham chiếu trong repo.

## S4 – Detection engineering
**Mục tiêu:** Detection cho Basic rules và UC1–UC4, ghi vào index `detections`; kiểm chứng không báo nhầm trên traffic lành tính.
**Phụ thuộc:** S2 (có thể soạn nháp sớm, nghiệm thu sau khi S2 xong).
**Chung**
- [ ] Mượn rule công khai (Splunk Security Content, Sigma, Zeek script/signature) làm điểm xuất phát; sửa sang macro `` `zeek_*` `` và schema `detections`; ghi nguồn trong README từng detection
- [ ] Zeek signature (.sig): payload khai thác web DMZ, User-Agent công cụ scan
- [ ] Zeek Intel: IOC lab (IP/domain C2, domain tunnel, hash)
- [ ] Specification-based: ma trận 3.2, đặc tả DNS, đặc tả DMZ, đặc tả HTTP; `weird.log` chỉ bổ trợ
- [ ] Anomaly-based: entropy/độ dài DNS, độ đều chu kỳ, volume, cặp host mới (ngưỡng ban đầu từ rule công khai, chỉnh sau backtest)
- [ ] Alert: scheduled search (1 phút Basic, 5 phút UC), cửa sổ chồng lấn
- [ ] Mỗi detection ghi đúng schema chung vào `detections`
- [ ] Script traffic lành tính trong `traffic/`: web browsing tới INetSim, DNS hợp lệ (gồm tên dài hợp lệ), cron update có chu kỳ (FP control UC4), backup lớn (FP control UC3), truy cập web DMZ từ IP ngoài lành tính
- [ ] Thu một đoạn benign-only ngắn (vài giờ, trước khi chạy attack lần đầu), ghi khoảng thời gian
- [ ] Backtest: chạy SPL từng rule trên đoạn benign đó (`earliest/latest` trỏ vào khoảng đã thu); 0 kết quả là đạt, ngược lại chỉnh ngưỡng; (tùy chọn) tính p95/p99 theo host từ đoạn này, lưu lookup trong app Splunk
- [ ] Script tấn công cho từng UC trong `attacks/<uc>/`, ghi `ground_truth` (theo định dạng trong contract) ngay từ đầu; S5 và S7 dùng lại, không viết lại

Người phụ trách mục "Chung": `.sig`, `.intel`, script benign và backtest là M3; mỗi người tự backtest rule của mình trên đoạn benign M3 thu.

**Basic Attack Rules** (`detections/basic-attack-rules`) – M1
- [ ] Port scan (conn.log: số cổng/host khác nhau, tỷ lệ fail)
- [ ] Brute force (http.log mã trạng thái login hoặc ssh.log/conn.log)
- [ ] Script tấn công scan + brute force (ghi `ground_truth`)

**UC1 – Lateral movement & internal recon** (spec + anomaly) – M3
- [ ] DMZ→LAN sai cổng/đích; nhiều REJ/S0; cặp host mới
- [ ] Script tấn công (ghi `ground_truth`); test đáng ngờ + lành tính, README use case

**UC2 – DNS tunneling** (anomaly + spec) – M3
- [ ] Subdomain dài/entropy cao, unique subdomain/domain gốc, tỷ lệ TXT/NULL, vi phạm đặc tả DNS
- [ ] Script dnscat2/iodine (ghi `ground_truth`); test + DNS dài hợp lệ (FP control)

**UC3 – Data exfiltration** (anomaly + spec) – M4
- [ ] Tỷ lệ bytes out/in, volume > p95/p99, đích mới, thời lượng phiên (HTTPS: chỉ ssl.log/conn.log, nêu giới hạn)
- [ ] Script exfil (ghi `ground_truth`); test + backup đêm (FP control)

**UC4 – C2 beaconing** (anomaly + signature) – M4
- [ ] Độ lệch chuẩn/trung bình khoảng cách kết nối, kích thước ổn định, khớp intel.log
- [ ] Script beacon (ghi `ground_truth`); test + cron update (FP control)

**DoD:** Mỗi detection fire đúng trên ít nhất 1 lần chạy thử, backtest trên đoạn benign không báo nhầm; code merge qua PR có review.
**Deliverable:** `detections/**`, `zeek/**`, `attacks/**` (bản chạy thử), `traffic/`.

## S5 – Prevention & response
**Mục tiêu:** Từ cảnh báo Splunk dẫn tới chặn trên nftables một cách an toàn.
**Phụ thuộc:** S1 (nftables), S2 (Splunk, index `fw_audit`). Phần lớn làm được ngay sau S2, test alert action bằng alert giả (`makeresults`) theo schema `detections` đã chốt ở S0. S4 chỉ cần cho bước nghiệm thu end-to-end (thay alert giả bằng rule thật).
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
**Phụ thuộc:** S4, S5.
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
**Phụ thuộc:** S6 (kéo theo S4, S5). Dùng lại script tấn công và script benign đã viết ở S4, không viết mới.
**Phân công:** mỗi người chạy chiến dịch cho UC của mình (M1: Basic; M3: UC1, UC2; M4: UC3, UC4; M2: UC5); M4 viết SPL đối chiếu, tính metrics và tổng hợp.
- [ ] Ingest `ground_truth` từ script tấn công vào index `ground_truth`
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
| 2026-11-27 | Kế hoạch | Chuyển sang làm tuần tự từng stage trọn vẹn, bỏ gán sẵn người, thêm quy ước bàn giao OVA |
| 2026-11-27 | Kế hoạch | Gộp S3 vào S4 (rule công khai + benign ngắn để backtest, bỏ baseline 24–48h); cho phép soạn nháp stage sau, nghiệm thu sau |
| 2026-11-27 | Kế hoạch | Phân công: M1 S1+S2+Basic; M2 S5+S6; M3 UC1, UC2, `.sig`/`.intel`, benign; M4 UC3, UC4 + tổng hợp S7. Script tấn công + `ground_truth` chuyển vào S4; S5 phụ thuộc S1, S2 |
