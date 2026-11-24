#!/usr/bin/env bash
# VM3 Web DMZ – chay MOT LAN.
#   sudo bash lab/vm3-web-dmz/install.sh packages    # giai doan A (can Internet, clone DVWA)
#   sudo bash lab/vm3-web-dmz/install.sh configure   # giai doan B (offline)
#   sudo bash lab/vm3-web-dmz/install.sh init        # sau khi VM4 (MySQL) da san sang: tao DB DVWA
# Luu y: cac buoc DVWA chua duoc kiem chung tren may that; DVWA co the doi cau truc config giua cac ban.
MODE="${1:-all}"
source "$(dirname "$0")/../common.sh"
require_root
set -a; load_env; set +a

DVWA_DIR=/var/www/html/dvwa

if want packages; then
  log "[packages]"
  apt-get update
  apt_install apache2 php libapache2-mod-php php-mysql php-gd mysql-client git chrony openssh-server
  if [[ ! -d "$DVWA_DIR" ]]; then
    git clone --depth 1 https://github.com/digininja/DVWA.git "$DVWA_DIR"
  fi
fi

if want configure; then
  chrony_client "$VM2_DMZ_IP"

  [[ -d "$DVWA_DIR" ]] || die "Chua co $DVWA_DIR (chay 'packages' o giai doan A)"
  log "[dvwa] config.inc.php: DB -> ${VM4_IP}, security level low"
  cfg="$DVWA_DIR/config/config.inc.php"
  [[ -f "$cfg" ]] || cp "$DVWA_DIR/config/config.inc.php.dist" "$cfg"
  setkey() { sed -i -E "s|^(\\\$_DVWA\\[ *'$1' *\\]).*|\\1 = '$2';|" "$cfg"; }
  setkey db_server "$VM4_IP"
  setkey db_database dvwa
  setkey db_user dvwa
  setkey db_password "$LAB_ONLY_DB_PASSWORD"
  setkey default_security_level low
  chown -R www-data:www-data "$DVWA_DIR"
  systemctl enable --now apache2
  systemctl restart apache2
  log "Apache chi chay HTTP (80). Web server co ma tran cho phep 80/443 nhung DVWA chua dung 443."
fi

if want init; then
  log "[init] tao/reset DB DVWA (can VM4 MySQL san sang va cho phep ${VM3_IP})"
  cj="$(mktemp)"; trap 'rm -f "$cj"' EXIT
  tok="$(curl -s -c "$cj" http://127.0.0.1/dvwa/setup.php | grep -oP "user_token' value='\K[^']+" || true)"
  [[ -n "$tok" ]] || die "Khong lay duoc user_token tu setup.php (kiem tra Apache/PHP)"
  curl -s -b "$cj" -c "$cj" -d "create_db=Create+%2F+Reset+Database&user_token=$tok" http://127.0.0.1/dvwa/setup.php >/dev/null
  log "Da gui yeu cau tao DB. Kiem tra bang cach mo http://${VM3_IP}/dvwa/ (dang nhap admin/password)"
fi
