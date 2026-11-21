# Block Agent (VM2)

Dịch vụ Python chỉ nghe trên mgmt-net, nhận yêu cầu từ VM5 kèm token.

## Checklist

- [ ] agent.py: block_src/block_dst/block_egress/isolate_host
- [ ] Validate tham số, không chạy lệnh tùy ý
- [ ] Allowlist (VM2, VM5, gateway, admin)
- [ ] Audit log -> fw_audit
- [ ] systemd unit
- [ ] Unit tests (tests/)
