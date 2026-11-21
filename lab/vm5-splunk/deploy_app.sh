#!/usr/bin/env bash
# VM5 – build Splunk app tu repo roi deploy. Dung sau moi lan: git pull.
# Chay: sudo bash lab/vm5-splunk/deploy_app.sh
source "$(dirname "$0")/../common.sh"
require_root
load_env

APP=idps_lab
BUILD_DIR="$REPO_ROOT/build/$APP"

log "Build app (ghep detections/*/*.spl -> savedsearches.conf)"
bash "$REPO_ROOT/scripts/build_app.sh"

log "Deploy vao $SPLUNK_HOME/etc/apps/$APP"
mkdir -p "$SPLUNK_HOME/etc/apps/$APP"
cp -a "$BUILD_DIR/." "$SPLUNK_HOME/etc/apps/$APP/"

# TODO (S2): "$SPLUNK_HOME/bin/splunk" restart  (hoac debug/refresh)
log "deploy xong"
