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

# wifi-scripts owns /sbin/wifi; remove the stale duplicate from base-files.
base_files_wifi="package/base-files/files/sbin/wifi"
wifi_scripts_wifi="package/network/config/wifi-scripts/files/sbin/wifi"
test -f "$wifi_scripts_wifi" || {
  echo "Unable to find replacement $wifi_scripts_wifi"
  exit 1
}
rm -f "$base_files_wifi" || exit 1
echo "Using /sbin/wifi from wifi-scripts"

# Add luci-app-adguardhome
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package-temp/luci-app-adguardhome
mv -f package-temp/luci-app-adguardhome package/lean/
rm -rf package-temp

# Add luci-theme-opentomcat
git clone https://github.com/Leo-Jo-My/luci-theme-opentomcat.git theme-temp/luci-theme-opentomcat
rm -rf theme-temp/luci-theme-opentomcat/LICENSE
rm -rf theme-temp/luci-theme-opentomcat/README.md
mv -f theme-temp/luci-theme-opentomcat package/lean/
rm -rf theme-temp
default_theme='opentomcat'
sed -i "s/bootstrap/$default_theme/g" feeds/luci/modules/luci-base/root/etc/config/luci

# Add luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git  package-temp/luci-app-amlogic
mv -f package-temp/luci-app-amlogic/luci-app-amlogic package/lean/
rm -rf package-temp
sed -i '1i src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default
./scripts/feeds update -a
rm -rf feeds/luci/applications/{luci-app-dae,luci-app-daed,luci-app-mosdns}
rm -rf feeds/packages/net/{alist,adguardhome,dae,daed,mosdns,xray*,v2ray*,sing*,smartdns} feeds/packages/utils/v2dat feeds/packages/lang/golang
rm -rf feeds/smpackage/{base-files,ddns-go,dnsmasq,firewall*,fullconenat,libnftnl,luci-app-ddns-go,nftables,ppp,opkg,ucl,upx,vsftpd*,miniupnpd-iptables,wireless-regdb}
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
