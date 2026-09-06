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

# Customize the firmware identity shown by LuCI and system release files.
firmware_dist="${FIRMWARE_DIST:-Go-Laoji N1}"
firmware_version="${FIRMWARE_VERSION:-R$(date +%y.%m.%d)}"
openwrt_release="package/base-files/files/etc/openwrt_release"
os_release="package/base-files/files/usr/lib/os-release"
default_settings="package/lean/default-settings/files/zzz-default-settings"
for release_file in "$openwrt_release" "$os_release" "$default_settings"; do
  test -f "$release_file" || {
    echo "Unable to find $release_file"
    exit 1
  }
done
sed -i \
  -e "s#^DISTRIB_REVISION=.*#DISTRIB_REVISION='${firmware_version}'#" \
  -e "s#^DISTRIB_DESCRIPTION=.*#DISTRIB_DESCRIPTION='${firmware_dist} '#" \
  "$openwrt_release" || exit 1
sed -i \
  -e "s#^NAME=.*#NAME=\"${firmware_dist}\"#" \
  -e "s#^VERSION=.*#VERSION=\"${firmware_version}\"#" \
  -e "s#^PRETTY_NAME=.*#PRETTY_NAME=\"${firmware_dist} ${firmware_version}\"#" \
  -e "s#^BUILD_ID=.*#BUILD_ID=\"${firmware_version}\"#" \
  -e "s#^OPENWRT_RELEASE=.*#OPENWRT_RELEASE=\"${firmware_dist} \"#" \
  "$os_release" || exit 1
sed -i \
  -e "s#DISTRIB_REVISION='[^']*'#DISTRIB_REVISION='${firmware_version}'#" \
  -e "s#DISTRIB_DESCRIPTION='[^']*'#DISTRIB_DESCRIPTION='${firmware_dist} '#" \
  -e "s#OPENWRT_RELEASE=\"[^\"]*\"#OPENWRT_RELEASE=\"${firmware_dist} \"#" \
  "$default_settings" || exit 1
grep -qxF "DISTRIB_REVISION='${firmware_version}'" "$openwrt_release" || exit 1
grep -qxF "DISTRIB_DESCRIPTION='${firmware_dist} '" "$openwrt_release" || exit 1
grep -qxF "BUILD_ID=\"${firmware_version}\"" "$os_release" || exit 1
grep -qxF "OPENWRT_RELEASE=\"${firmware_dist} \"" "$os_release" || exit 1
grep -qF "DISTRIB_REVISION='${firmware_version}'" "$default_settings" || exit 1
grep -qF "DISTRIB_DESCRIPTION='${firmware_dist} '" "$default_settings" || exit 1
grep -qF "OPENWRT_RELEASE=\"${firmware_dist} \"" "$default_settings" || exit 1
echo "Using ${firmware_dist} ${firmware_version} as the firmware version"

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

# lede reverted the standalone wifi-scripts package and restored the legacy
# files to base-files and hostapd-common. Remove its stale mac80211 dependency
# only while the standalone package is absent.
wifi_scripts_dir="package/network/config/wifi-scripts"
mac80211_makefile="package/kernel/mac80211/Makefile"
wifi_scripts_dependency='(^|[[:space:]])\+wifi-scripts([[:space:]]|$)'
test -f "$mac80211_makefile" || {
  echo "Unable to find $mac80211_makefile"
  exit 1
}
if [ ! -d "$wifi_scripts_dir" ]; then
  if grep -Eq "$wifi_scripts_dependency" "$mac80211_makefile"; then
    sed -i -E 's/[[:space:]]+\+wifi-scripts([[:space:]]|$)/\1/g' "$mac80211_makefile" || exit 1
  fi
  if grep -Eq "$wifi_scripts_dependency" "$mac80211_makefile"; then
    echo "Failed to remove the stale wifi-scripts dependency from $mac80211_makefile"
    exit 1
  fi
  echo "Using legacy Wi-Fi files from base-files and hostapd-common"
fi

sed -i '1i src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default
./scripts/feeds update -a

# Override the branch label displayed on the LuCI overview page.
luci_makefile="feeds/luci/luci.mk"
luci_display="${LUCI_DISPLAY:-LuCI openwrt-25.12}"
test -f "$luci_makefile" || {
  echo "Unable to find $luci_makefile"
  exit 1
}
if ! grep -qxF "PKG_GITBRANCH:=${luci_display}" "$luci_makefile"; then
  grep -qF 'PKG_GITBRANCH?=' "$luci_makefile" || {
    echo "Unable to find PKG_GITBRANCH in $luci_makefile"
    exit 1
  }
  sed -i "s#^PKG_GITBRANCH?=.*#PKG_GITBRANCH:=${luci_display}#" "$luci_makefile" || exit 1
fi
grep -qxF "PKG_GITBRANCH:=${luci_display}" "$luci_makefile" || exit 1
echo "Using ${luci_display} as the LuCI display version"

rm -rf feeds/luci/applications/{luci-app-dae,luci-app-daed,luci-app-mosdns}
rm -rf feeds/packages/net/{alist,adguardhome,dae,daed,mosdns,xray*,v2ray*,sing*,smartdns} feeds/packages/utils/v2dat feeds/packages/lang/golang
excluded_smpackage_packages=(
  feeds/smpackage/adguardhome
  feeds/smpackage/base-files
  feeds/smpackage/clashoo
  feeds/smpackage/ddns-go
  feeds/smpackage/dnsmasq
  feeds/smpackage/firewall*
  feeds/smpackage/frp
  feeds/smpackage/fullconenat
  feeds/smpackage/libnftnl
  feeds/smpackage/luci-app-adguardhome
  feeds/smpackage/luci-app-amlogic
  feeds/smpackage/luci-app-argon-config
  feeds/smpackage/luci-app-clashoo
  feeds/smpackage/luci-app-ddns-go
  feeds/smpackage/luci-theme-argon
  feeds/smpackage/miniupnpd-iptables
  feeds/smpackage/nftables
  feeds/smpackage/opkg
  feeds/smpackage/other/lean/luci-app-frpc
  feeds/smpackage/ppp
  feeds/smpackage/ucl
  feeds/smpackage/upx
  feeds/smpackage/vsftpd*
  feeds/smpackage/wireless-regdb
)
rm -rf "${excluded_smpackage_packages[@]}"

# Use FRPC and its LuCI application from the matching official feeds.
frpc_packages=(
  feeds/packages/net/frp/Makefile
  feeds/luci/applications/luci-app-frpc/Makefile
)
for package_makefile in "${frpc_packages[@]}"; do
  test -f "$package_makefile" || {
    echo "Unable to find FRPC package: $package_makefile"
    exit 1
  }
done

# luci-app-store and its task service are provided by smpackage.
istore_packages=(
  feeds/smpackage/luci-app-store/Makefile
  feeds/smpackage/luci-app-store/src/Makefile
  feeds/smpackage/luci-app-store/src/po/zh-cn/iStore.po
  feeds/smpackage/luci-lib-taskd/Makefile
  feeds/smpackage/taskd/Makefile
)
for package_makefile in "${istore_packages[@]}"; do
  test -f "$package_makefile" || {
    echo "Unable to find iStore package: $package_makefile"
    exit 1
  }
done

# iStore bundles its translations in the main package. Its custom source
# Makefile must iterate over the real po directory names (such as zh-cn), not
# the BCP 47 names (such as zh_Hans) normalized by current LuCI.
istore_src_makefile="feeds/smpackage/luci-app-store/src/Makefile"
if grep -qF '$(foreach lang,$(LUCI_LANGUAGES),' "$istore_src_makefile"; then
  sed -i 's/$(foreach lang,$(LUCI_LANGUAGES),/$(foreach lang,$(LUCI_LANGUAGES_RAW),/' "$istore_src_makefile" || exit 1
elif ! grep -qF '$(foreach lang,$(LUCI_LANGUAGES_RAW),' "$istore_src_makefile"; then
  echo "Unable to find the iStore translation install rule in $istore_src_makefile"
  exit 1
fi
grep -qF '$(foreach lang,$(LUCI_LANGUAGES_RAW),' "$istore_src_makefile" || exit 1
echo "Using the Chinese translation bundled with luci-app-store"

# QuickStart provides the default LuCI home page and supports the N1 aarch64
# target. Keep the package, LuCI application, and verified Chinese source
# together so feed changes fail early instead of silently dropping the page.
quickstart_packages=(
  feeds/smpackage/quickstart/Makefile
  feeds/smpackage/luci-app-quickstart/Makefile
  feeds/smpackage/luci-app-quickstart/po/zh-cn/quickstart.po
)
for package_makefile in "${quickstart_packages[@]}"; do
  test -f "$package_makefile" || {
    echo "Unable to find QuickStart package: $package_makefile"
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
