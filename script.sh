#!/bin/bash
cd openwrt

# Pin netifd to the last version compatible with the armsr 6.6 headers.
netifd_makefile="package/network/config/netifd/Makefile"
netifd_patches_dir="package/network/config/netifd/patches"
test -f "$netifd_makefile" || {
  echo "Unable to find $netifd_makefile"
  exit 1
}
sed -i \
  -e 's/^PKG_SOURCE_DATE:=.*/PKG_SOURCE_DATE:=2021-06-04/' \
  -e 's/^PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:=50381d0a2998f6c0fc4823f0c2aa4206063d549e/' \
  -e 's/^PKG_MIRROR_HASH:=.*/PKG_MIRROR_HASH:=2718df3d3538c93ac77accf55716fb341741df3d231aac59e04dd1f80f558889/' \
  "$netifd_makefile" || exit 1
grep -qxF 'PKG_SOURCE_DATE:=2021-06-04' "$netifd_makefile" || exit 1
grep -qxF 'PKG_SOURCE_VERSION:=50381d0a2998f6c0fc4823f0c2aa4206063d549e' "$netifd_makefile" || exit 1
grep -qxF 'PKG_MIRROR_HASH:=2718df3d3538c93ac77accf55716fb341741df3d231aac59e04dd1f80f558889' "$netifd_makefile" || exit 1
rm -rf "$netifd_patches_dir" || exit 1
echo "Pinned netifd to 2021-06-04 (50381d0a2998f6c0fc4823f0c2aa4206063d549e)"

# Set the LAN address generated on the first boot.
config_generate="package/base-files/files/bin/config_generate"
default_lan_ip="${DEFAULT_LAN_IP:-192.168.11.240}"
old_default_lan_rule='lan) ipad=${ipaddr:-"192.168.1.1"} ;;'
new_default_lan_rule="lan) ipad=\${ipaddr:-\"${default_lan_ip}\"} ;;"
test -f "$config_generate" || {
  echo "Unable to find $config_generate"
  exit 1
}
if grep -Fq "$old_default_lan_rule" "$config_generate"; then
  sed -i "s/192\\.168\\.1\\.1/${default_lan_ip}/" "$config_generate" || exit 1
elif ! grep -Fq "$new_default_lan_rule" "$config_generate"; then
  echo "Unable to find the default LAN IP rule in $config_generate"
  exit 1
fi
grep -Fq "$new_default_lan_rule" "$config_generate" || exit 1
echo "Using ${default_lan_ip} as the default LAN IP"

# wifi-scripts owns /sbin/wifi; remove the stale duplicate from base-files.
base_files_wifi="package/base-files/files/sbin/wifi"
wifi_scripts_wifi="package/network/config/wifi-scripts/files/sbin/wifi"
test -f "$wifi_scripts_wifi" || {
  echo "Unable to find replacement $wifi_scripts_wifi"
  exit 1
}
rm -f "$base_files_wifi" || exit 1
echo "Using /sbin/wifi from wifi-scripts"

# wifi-scripts also owns the WPS button and hostapd integration scripts.
hostapd_makefile="package/network/services/hostapd/Makefile"
hostapd_duplicate_rules=(
  './files/hostapd.sh $(1)/lib/netifd/hostapd.sh'
  './files/wps-hotplug.sh $(1)/etc/rc.button/wps'
)
test -f "$hostapd_makefile" || {
  echo "Unable to find $hostapd_makefile"
  exit 1
}
# Newer lede revisions already remove these rules. Keep this compatible with
# both older revisions that still need patching and newer fixed revisions.
sed -i \
  -e '/files\/hostapd\.sh.*lib\/netifd\/hostapd\.sh/d' \
  -e '/files\/wps-hotplug\.sh.*rc\.button\/wps/d' \
  "$hostapd_makefile" || exit 1
for rule in "${hostapd_duplicate_rules[@]}"; do
  if grep -Fq "$rule" "$hostapd_makefile"; then
    echo "Failed to remove hostapd-common install rule: $rule"
    exit 1
  fi
done
echo "Using WPS and hostapd integration scripts from wifi-scripts"

sed -i '1i src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default
./scripts/feeds update -a
rm -rf feeds/luci/applications/{luci-app-dae,luci-app-daed,luci-app-mosdns}
rm -rf feeds/packages/net/{alist,adguardhome,dae,daed,mosdns,xray*,v2ray*,sing*,smartdns} feeds/packages/utils/v2dat feeds/packages/lang/golang
excluded_smpackage_packages=(
  feeds/smpackage/adguardhome
  feeds/smpackage/base-files
  feeds/smpackage/ddns-go
  feeds/smpackage/dnsmasq
  feeds/smpackage/firewall*
  feeds/smpackage/fullconenat
  feeds/smpackage/libnftnl
  feeds/smpackage/luci-app-adguardhome
  feeds/smpackage/luci-app-amlogic
  feeds/smpackage/luci-app-argon-config
  feeds/smpackage/luci-app-ddns-go
  feeds/smpackage/luci-theme-argon
  feeds/smpackage/miniupnpd-iptables
  feeds/smpackage/nftables
  feeds/smpackage/opkg
  feeds/smpackage/ppp
  feeds/smpackage/ucl
  feeds/smpackage/upx
  feeds/smpackage/vsftpd*
  feeds/smpackage/wireless-regdb
)
rm -rf "${excluded_smpackage_packages[@]}"

# luci-app-store and its task service are provided by smpackage.
istore_packages=(
  feeds/smpackage/luci-app-store/Makefile
  feeds/smpackage/luci-lib-taskd/Makefile
  feeds/smpackage/taskd/Makefile
)
for package_makefile in "${istore_packages[@]}"; do
  test -f "$package_makefile" || {
    echo "Unable to find iStore package: $package_makefile"
    exit 1
  }
done

# Use the Argon packages maintained by the matching LuCI feed.
argon_packages=(
  feeds/luci/applications/luci-app-argon-config/Makefile
  feeds/luci/themes/luci-theme-argon/Makefile
)
for package_makefile in "${argon_packages[@]}"; do
  test -f "$package_makefile" || {
    echo "Unable to find $package_makefile"
    exit 1
  }
done
luci_config="feeds/luci/modules/luci-base/root/etc/config/luci"
grep -qF 'option mediaurlbase /luci-static/bootstrap' "$luci_config" || {
  echo "Unable to find the default bootstrap theme in $luci_config"
  exit 1
}
sed -i 's#/luci-static/bootstrap#/luci-static/argon#' "$luci_config" || exit 1
grep -qF 'option mediaurlbase /luci-static/argon' "$luci_config" || exit 1
echo "Using Argon as the default LuCI theme"

docker_packages=(
  feeds/smpackage/cgroupfs-mount
  feeds/smpackage/docker
  feeds/smpackage/docker-lan-bridge
  feeds/smpackage/dockerd
  feeds/smpackage/dockermanager
  feeds/smpackage/luci-app-dockerman
  feeds/smpackage/luci-app-dockermanager
  feeds/smpackage/other/luci-app-dockerman
  feeds/smpackage/other/luci-lib-docker
)
rm -rf "${docker_packages[@]}"
git clone https://github.com/kenzok8/golang -b 1.26 feeds/packages/lang/golang
git clone --depth=1 --filter=blob:none --sparse https://github.com/kenzok8/openwrt-daede package/community/openwrt-daede
git -C package/community/openwrt-daede sparse-checkout set daed luci-app-daede vmlinux-btf
test -f package/community/openwrt-daede/daed/Makefile
test -f package/community/openwrt-daede/luci-app-daede/Makefile

# Redsocks is provided by the packages feed; add its LuCI editor separately.
test -f feeds/packages/net/redsocks/Makefile || {
  echo "Unable to find redsocks in the packages feed"
  exit 1
}
git clone --depth=1 --filter=blob:none --sparse https://github.com/kenzok8/jell package/community/jell-redsocks
git -C package/community/jell-redsocks sparse-checkout set luci-app-redsocks
test -f package/community/jell-redsocks/luci-app-redsocks/Makefile || {
  echo "Unable to find luci-app-redsocks in the jell source"
  exit 1
}
./scripts/feeds update -i packages luci smpackage
for package in \
  luci-app-vsftpd \
  luci-app-vlmcsd \
  luci-app-ssr-plus \
  luci-app-ddns \
  ddns-scripts_aliyun \
  ddns-scripts_dnspod; do
  sed -i -E "s/(^|[[:space:]])${package}([[:space:]]|$)/\\1\\2/g" include/target.mk
done
