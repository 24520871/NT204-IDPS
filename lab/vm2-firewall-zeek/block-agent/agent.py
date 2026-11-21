"""Block Agent skeleton (VM2).

Chi nghe tren mgmt-net, chi nhan yeu cau tu IP cua VM5 kem token.
Chi chap nhan tap hanh dong co dinh; khong bao gio chay lenh tuy y.
"""
import ipaddress
import logging

ALLOWED_ACTIONS = ("block_src", "block_dst", "block_egress", "isolate_host")

# TODO: doc tu file cau hinh (khong commit token). Allowlist: VM2, VM5, gateway, may quan tri.
ALLOWLIST: set = set()
DEFAULT_TIMEOUT_S = 1800  # 30 phut cho Basic rules

log = logging.getLogger("block-agent")


def validate_ip(value: str) -> str:
    return str(ipaddress.ip_address(value))


def handle_request(action: str, params: dict) -> dict:
    """Validate -> kiem tra allowlist -> them vao nftables set (co timeout) -> audit log."""
    if action not in ALLOWED_ACTIONS:
        return {"result": "rejected", "reason": "unknown action"}
    # TODO: validate params, check allowlist, goi nft qua danh sach tham so (khong dung shell),
    #       ghi audit -> fw_audit
    raise NotImplementedError


def main() -> None:
    # TODO: HTTPS server, kiem tra IP nguon = VM5 va token
    raise NotImplementedError


if __name__ == "__main__":
    main()
