# nftables – Firewall (VM2)

Ruleset default-deny theo Bảng 3.2; set có timeout cho block động.

## Checklist

- [ ] ruleset.nft (4 NIC, default deny)
- [ ] Set có timeout: blocked_src, blocked_dst, blocked_egress, isolated_hosts
- [ ] Log luồng bị từ chối
- [ ] Kiểm thử từng dòng ma trận luồng
