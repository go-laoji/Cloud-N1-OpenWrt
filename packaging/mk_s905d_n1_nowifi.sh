#!/bin/bash
set -eu

# flippy-openwrt-actions clones unifreq/openwrt_packit before invoking this
# script. Its N1 recipe deliberately overrides ENABLE_WIFI_K510 to 1 and
# always installs a wireless UCI config. Patch only those two N1 defaults and
# then execute the upstream recipe so the rest of the packaging flow remains
# unchanged.
source_script="${PWD}/mk_s905d_n1.sh"
patched_script="${PWD}/.mk_s905d_n1_nowifi.sh"

test -f "$source_script" || {
  echo "Unable to find upstream N1 packaging script: $source_script"
  exit 1
}

grep -qxF 'ENABLE_WIFI_K510=1' "$source_script" || {
  echo "Upstream N1 Wi-Fi switch changed; refusing to patch an unknown script"
  exit 1
}
grep -qxF 'WIRELESS_CONFIG="${PWD}/files/s905d/wireless"' "$source_script" || {
  echo "Upstream N1 wireless config rule changed; refusing to patch an unknown script"
  exit 1
}

cp -f "$source_script" "$patched_script"
sed -i \
  -e 's/^ENABLE_WIFI_K510=1$/ENABLE_WIFI_K510=0/' \
  -e 's#^WIRELESS_CONFIG="${PWD}/files/s905d/wireless"$#WIRELESS_CONFIG=""#' \
  "$patched_script"

grep -qxF 'ENABLE_WIFI_K510=0' "$patched_script"
grep -qxF 'WIRELESS_CONFIG=""' "$patched_script"
chmod +x "$patched_script"

exec "$patched_script" "$@"
