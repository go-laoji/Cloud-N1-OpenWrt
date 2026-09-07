#!/bin/bash
cd openwrt
# 禁用 ksmbd 及相关包，避免内核 6.12 与 ksmbd 3.5.4 不兼容
# ksmbd-server 和 autosamba 依赖 kmod-fs-ksmbd，必须一起禁用
rm -rf package/kernel/ksmbd
cat >> .config <<EOF
CONFIG_KMOD_FS_KSMBD=n
CONFIG_PACKAGE_kmod-fs-ksmbd=n
CONFIG_PACKAGE_ksmbd-server=n
CONFIG_PACKAGE_autosamba=n
CONFIG_TARGET_armsr=y
CONFIG_TARGET_armsr_armv8=y
CONFIG_TARGET_armsr_armv8_DEVICE_generic=y
# CONFIG_BRCMFMAC_PCIE is not set
# CONFIG_BRCMFMAC_SDIO is not set
# CONFIG_BRCMFMAC_USB is not set
CONFIG_BTRFS_PROGS_ZSTD=y
# CONFIG_CGROUPFS_MOUNT_KERNEL_CGROUPS is not set
# CONFIG_DRIVER_11AC_SUPPORT is not set
CONFIG_KERNEL_ARM_PMU=y
# CONFIG_KERNEL_CFQ_GROUP_IOSCHED is not set
# CONFIG_KERNEL_CGROUP_DEVICE is not set
# CONFIG_KERNEL_CGROUP_FREEZER is not set
# CONFIG_KERNEL_CGROUP_HUGETLB is not set
# CONFIG_KERNEL_CGROUP_NET_PRIO is not set
# CONFIG_KERNEL_CGROUP_PERF is not set
CONFIG_KERNEL_EXT4_FS_POSIX_ACL=y
CONFIG_KERNEL_EXT4_FS_SECURITY=y
CONFIG_KERNEL_FS_POSIX_ACL=y
# CONFIG_KERNEL_HUGETLBFS is not set
# CONFIG_KERNEL_HUGETLB_PAGE is not set
# CONFIG_KERNEL_MEMCG_SWAP_ENABLED is not set
# CONFIG_KERNEL_NET_CLS_CGROUP is not set
CONFIG_KERNEL_PERF_EVENTS=y
# CONFIG_KERNEL_TRANSPARENT_HUGEPAGE is not set
# CONFIG_KERNEL_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_MBEDTLS_AES_C=y
CONFIG_MBEDTLS_CMAC_C=y
CONFIG_MBEDTLS_DES_C=y
CONFIG_MBEDTLS_ECP_DP_CURVE25519_ENABLED=y
CONFIG_MBEDTLS_ECP_DP_SECP256K1_ENABLED=y
CONFIG_MBEDTLS_ECP_DP_SECP256R1_ENABLED=y
CONFIG_MBEDTLS_ECP_DP_SECP384R1_ENABLED=y
CONFIG_MBEDTLS_ENTROPY_FORCE_SHA256=y
CONFIG_MBEDTLS_GCM_C=y
CONFIG_MBEDTLS_KEY_EXCHANGE_ECDHE_ECDSA_ENABLED=y
CONFIG_MBEDTLS_KEY_EXCHANGE_ECDHE_PSK_ENABLED=y
CONFIG_MBEDTLS_KEY_EXCHANGE_ECDHE_RSA_ENABLED=y
CONFIG_MBEDTLS_KEY_EXCHANGE_PSK_ENABLED=y
CONFIG_MBEDTLS_NIST_KW_C=y
CONFIG_MBEDTLS_RSA_NO_CRT=y
CONFIG_PACKAGE_6in4=y
# CONFIG_PACKAGE_MAC80211_DEBUGFS is not set
# CONFIG_PACKAGE_MAC80211_MESH is not set
CONFIG_PACKAGE_TAR_BZIP2=y
CONFIG_PACKAGE_TAR_GZIP=y
CONFIG_PACKAGE_TAR_XZ=y
CONFIG_PACKAGE_TAR_ZSTD=y
# CONFIG_PACKAGE_adguardhome is not set
CONFIG_PACKAGE_aliyundrive-webdav=y
CONFIG_PACKAGE_attr=y
CONFIG_PACKAGE_bash=y
CONFIG_PACKAGE_blkid=y
# CONFIG_PACKAGE_brcmfmac-firmware-usb is not set
CONFIG_PACKAGE_bsdtar=y
CONFIG_PACKAGE_btrfs-progs=y
CONFIG_PACKAGE_bzip2=y
# CONFIG_PACKAGE_cgroupfs-mount is not set
CONFIG_PACKAGE_chattr=y
# CONFIG_PACKAGE_clashoo is not set
# CONFIG_PACKAGE_containerd is not set
# CONFIG_PACKAGE_ddns-go is not set
CONFIG_PACKAGE_dosfstools=y
CONFIG_PACKAGE_e2fsprogs=y
# CONFIG_PACKAGE_f2fs-tools is not set
# CONFIG_PACKAGE_f2fsck is not set
CONFIG_PACKAGE_fdisk=y
CONFIG_PACKAGE_frpc=y
CONFIG_PACKAGE_gawk=y
CONFIG_PACKAGE_getopt=y
# CONFIG_PACKAGE_hostapd-common is not set
CONFIG_PACKAGE_ip6tables=y
CONFIG_PACKAGE_iptables-mod-conntrack-extra=y
CONFIG_PACKAGE_iptables-mod-iprange=y
CONFIG_PACKAGE_iptables-mod-socket=y
CONFIG_PACKAGE_ipv6helper=y
# CONFIG_PACKAGE_iw is not set
# CONFIG_PACKAGE_iwinfo is not set
CONFIG_PACKAGE_jq=y
# CONFIG_PACKAGE_kmod-asn1-encoder is not set
# CONFIG_PACKAGE_kmod-br-netfilter is not set
# CONFIG_PACKAGE_kmod-brcmfmac is not set
# CONFIG_PACKAGE_kmod-brcmutil is not set
# CONFIG_PACKAGE_kmod-cfg80211 is not set
CONFIG_PACKAGE_kmod-crypto-cbc=y
CONFIG_PACKAGE_kmod-crypto-ccm=y
CONFIG_PACKAGE_kmod-crypto-cmac=y
CONFIG_PACKAGE_kmod-crypto-crc32c=y
CONFIG_PACKAGE_kmod-crypto-ctr=y
CONFIG_PACKAGE_kmod-crypto-gcm=y
CONFIG_PACKAGE_kmod-crypto-gf128=y
CONFIG_PACKAGE_kmod-crypto-ghash=y
CONFIG_PACKAGE_kmod-crypto-hmac=y
CONFIG_PACKAGE_kmod-crypto-lib-chacha20=y
CONFIG_PACKAGE_kmod-crypto-lib-chacha20poly1305=y
CONFIG_PACKAGE_kmod-crypto-lib-curve25519=y
CONFIG_PACKAGE_kmod-crypto-lib-poly1305=y
CONFIG_PACKAGE_kmod-crypto-rng=y
CONFIG_PACKAGE_kmod-crypto-seqiv=y
CONFIG_PACKAGE_kmod-crypto-sha256=y
CONFIG_PACKAGE_kmod-crypto-sha512=y
# CONFIG_PACKAGE_kmod-dax is not set
# CONFIG_PACKAGE_kmod-dm is not set
# CONFIG_PACKAGE_kmod-dummy is not set
# CONFIG_PACKAGE_kmod-e1000 is not set
CONFIG_PACKAGE_kmod-fs-btrfs=y
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-ikconfig=y
CONFIG_PACKAGE_kmod-inet-diag=y
CONFIG_PACKAGE_kmod-ip6tables=y
CONFIG_PACKAGE_kmod-ipt-conntrack-extra=y
CONFIG_PACKAGE_kmod-ipt-iprange=y
CONFIG_PACKAGE_kmod-ipt-nat6=y
# CONFIG_PACKAGE_kmod-ipt-physdev is not set
CONFIG_PACKAGE_kmod-ipt-socket=y
CONFIG_PACKAGE_kmod-iptunnel=y
CONFIG_PACKAGE_kmod-iptunnel4=y
# CONFIG_PACKAGE_kmod-keys-encrypted is not set
# CONFIG_PACKAGE_kmod-keys-trusted is not set
CONFIG_PACKAGE_kmod-lib-crc32c=y
CONFIG_PACKAGE_kmod-lib-raid6=y
CONFIG_PACKAGE_kmod-lib-xor=y
CONFIG_PACKAGE_kmod-lib-zlib-deflate=y
CONFIG_PACKAGE_kmod-lib-zlib-inflate=y
CONFIG_PACKAGE_kmod-lib-zstd=y
# CONFIG_PACKAGE_kmod-mac80211 is not set
CONFIG_PACKAGE_kmod-mmc=y
CONFIG_PACKAGE_kmod-netlink-diag=y
CONFIG_PACKAGE_kmod-nf-ipt6=y
# CONFIG_PACKAGE_kmod-nf-ipvs is not set
CONFIG_PACKAGE_kmod-nf-log6=y
CONFIG_PACKAGE_kmod-nf-nat6=y
CONFIG_PACKAGE_kmod-nf-reject6=y
CONFIG_PACKAGE_kmod-nf-socket=y
# CONFIG_PACKAGE_kmod-oid-registry is not set
CONFIG_PACKAGE_kmod-random-core=y
CONFIG_PACKAGE_kmod-sit=y
# CONFIG_PACKAGE_kmod-tpm is not set
CONFIG_PACKAGE_kmod-udptunnel4=y
CONFIG_PACKAGE_kmod-udptunnel6=y
CONFIG_PACKAGE_kmod-usb-core=y
CONFIG_PACKAGE_kmod-wireguard=y
CONFIG_PACKAGE_libarchive=y
CONFIG_PACKAGE_libatomic=y
CONFIG_PACKAGE_libattr=y
CONFIG_PACKAGE_libbz2=y
CONFIG_PACKAGE_libcap=y
CONFIG_PACKAGE_libcap-bin=y
CONFIG_PACKAGE_libcap-bin-capsh-shell="/bin/sh"
CONFIG_PACKAGE_libexpat=y
CONFIG_PACKAGE_libfdisk=y
CONFIG_PACKAGE_libgmp=y
CONFIG_PACKAGE_libltdl=y
CONFIG_PACKAGE_liblua5.3=y
CONFIG_PACKAGE_liblzma=y
CONFIG_PACKAGE_liblzo=y
CONFIG_PACKAGE_libmbedtls=y
CONFIG_PACKAGE_libmount=y
CONFIG_PACKAGE_libncurses=y
CONFIG_PACKAGE_libparted=y
CONFIG_PACKAGE_libreadline=y
# CONFIG_PACKAGE_libseccomp is not set
CONFIG_PACKAGE_libstdcpp=y
CONFIG_PACKAGE_libuv=y
CONFIG_PACKAGE_libwebsockets-full=y
CONFIG_PACKAGE_libzstd=y
CONFIG_PACKAGE_losetup=y
CONFIG_PACKAGE_lsattr=y
CONFIG_PACKAGE_lsblk=y
# CONFIG_PACKAGE_luci-app-accesscontrol is not set
# CONFIG_PACKAGE_luci-app-adguardhome is not set
# CONFIG_PACKAGE_luci-app-amlogic is not set
CONFIG_PACKAGE_luci-app-argon-config=y
# CONFIG_PACKAGE_luci-app-arpbind is not set
# CONFIG_PACKAGE_luci-app-clashoo is not set
# CONFIG_PACKAGE_luci-app-ddns is not set
# CONFIG_PACKAGE_luci-app-ddns-go is not set
CONFIG_PACKAGE_luci-app-frpc=y
CONFIG_PACKAGE_luci-app-quickstart=y
CONFIG_PACKAGE_luci-app-store=y
# CONFIG_PACKAGE_luci-app-rclone_INCLUDE_rclone-ng is not set
# CONFIG_PACKAGE_luci-app-rclone_INCLUDE_rclone-webui is not set
CONFIG_PACKAGE_luci-app-turboacc=y
CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_BBR_CCA=y
# CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_OFFLOADING is not set
# CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_PDNSD is not set
# CONFIG_PACKAGE_luci-app-unblockmusic_INCLUDE_UnblockNeteaseMusic_Go is not set
CONFIG_PACKAGE_luci-app-upnp=y
# CONFIG_PACKAGE_luci-app-vsftpd is not set
# CONFIG_PACKAGE_luci-i18n-amlogic-zh-cn is not set
CONFIG_PACKAGE_luci-proto-ipv6=y
CONFIG_PACKAGE_luci-theme-argon=y
# CONFIG_PACKAGE_luci-theme-opentomcat is not set
# CONFIG_PACKAGE_miniupnpd is not set
CONFIG_PACKAGE_mount-utils=y
CONFIG_PACKAGE_odhcp6c=y
CONFIG_PACKAGE_odhcp6c_ext_cer_id=0
CONFIG_PACKAGE_odhcpd-ipv6only=y
CONFIG_PACKAGE_odhcpd_ipv6only_ext_cer_id=0
CONFIG_PACKAGE_parted=y
# CONFIG_PACKAGE_pdnsd-alt is not set
CONFIG_PACKAGE_perl=y
CONFIG_PACKAGE_perl-http-date=y
CONFIG_PACKAGE_perlbase-base=y
CONFIG_PACKAGE_perlbase-bytes=y
CONFIG_PACKAGE_perlbase-charnames=y
CONFIG_PACKAGE_perlbase-class=y
CONFIG_PACKAGE_perlbase-config=y
CONFIG_PACKAGE_perlbase-cwd=y
CONFIG_PACKAGE_perlbase-dynaloader=y
CONFIG_PACKAGE_perlbase-errno=y
CONFIG_PACKAGE_perlbase-essential=y
CONFIG_PACKAGE_perlbase-fcntl=y
CONFIG_PACKAGE_perlbase-file=y
CONFIG_PACKAGE_perlbase-filehandle=y
CONFIG_PACKAGE_perlbase-getopt=y
CONFIG_PACKAGE_perlbase-i18n=y
CONFIG_PACKAGE_perlbase-integer=y
CONFIG_PACKAGE_perlbase-io=y
CONFIG_PACKAGE_perlbase-list=y
CONFIG_PACKAGE_perlbase-locale=y
CONFIG_PACKAGE_perlbase-params=y
CONFIG_PACKAGE_perlbase-posix=y
CONFIG_PACKAGE_perlbase-re=y
CONFIG_PACKAGE_perlbase-scalar=y
CONFIG_PACKAGE_perlbase-selectsaver=y
CONFIG_PACKAGE_perlbase-socket=y
CONFIG_PACKAGE_perlbase-symbol=y
CONFIG_PACKAGE_perlbase-tie=y
CONFIG_PACKAGE_perlbase-time=y
CONFIG_PACKAGE_perlbase-unicode=y
CONFIG_PACKAGE_perlbase-unicore=y
CONFIG_PACKAGE_perlbase-utf8=y
CONFIG_PACKAGE_perlbase-xsloader=y
CONFIG_PACKAGE_pigz=y
CONFIG_PACKAGE_pv=y
CONFIG_PACKAGE_quickstart=y
# CONFIG_PACKAGE_runc is not set
CONFIG_PACKAGE_tar=y
CONFIG_PACKAGE_terminfo=y
# CONFIG_PACKAGE_tini is not set
CONFIG_PACKAGE_ttyd=y
CONFIG_PACKAGE_uuidgen=y
CONFIG_PACKAGE_wireguard-tools=y
# CONFIG_PACKAGE_wireless-regdb is not set
# CONFIG_PACKAGE_wpa-cli is not set
# CONFIG_PACKAGE_wpad-basic is not set
# CONFIG_PACKAGE_wpad-basic-mbedtls is not set
# CONFIG_PACKAGE_xfs-fsck is not set
# CONFIG_PACKAGE_xfs-mkfs is not set
CONFIG_PACKAGE_xz=y
CONFIG_PACKAGE_xz-utils=y
CONFIG_PARTED_READLINE=y
CONFIG_PERL_NOCOMMENT=y
CONFIG_PERL_THREADS=y
# CONFIG_TARGET_ROOTFS_CPIOGZ is not set
# CONFIG_TARGET_ROOTFS_EXT4FS is not set
# CONFIG_TARGET_ROOTFS_INITRAMFS is not set
CONFIG_TARGET_ROOTFS_PARTSIZE=512
CONFIG_TARGET_ROOTFS_TARGZ=y
# CONFIG_TARGET_ROOTFS_SQUASHFS is not set
CONFIG_WPA_MSG_MIN_PRIORITY=3
CONFIG_ZSTD_OPTIMIZE_O3=y
# CONFIG_PACKAGE_grub2-efi-arm is not set
# CONFIG_PACKAGE_kmod-crypto-kpp is not set
CONFIG_PACKAGE_kmod-fs-vfat=y
CONFIG_PACKAGE_kmod-ipt-offload=y
CONFIG_PACKAGE_kmod-nf-flow=y
CONFIG_PACKAGE_kmod-nls-cp437=y
CONFIG_PACKAGE_kmod-nls-iso8859-1=y
CONFIG_PACKAGE_kmod-nls-utf8=y
CONFIG_PACKAGE_kmod-tcp-bbr=y
# CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_SHORTCUT_FE_CM is not set
CONFIG_PACKAGE_vsftpd-alt=y
CONFIG_VSFTPD_USE_UCI_SCRIPTS=y

# Enable luci-app-daede with the daed backend
CONFIG_PACKAGE_luci-app-daede=y
CONFIG_PACKAGE_luci-app-daede_daed=y
# CONFIG_PACKAGE_luci-app-daede_dae is not set
CONFIG_PACKAGE_daed=y
# CONFIG_PACKAGE_dae is not set
# The current armsr configuration does not retain integrated kernel BTF after defconfig.
# Use the detached BTF package, which is the proven working fallback for daed.
# CONFIG_DAED_USE_KERNEL_BTF is not set
CONFIG_DAED_USE_VMLINUX_BTF=y
CONFIG_PACKAGE_vmlinux-btf=y

# eBPF / BTF kernel options required by DAE
CONFIG_KERNEL_BPF_EVENTS=y
CONFIG_DEVEL=y
CONFIG_CCACHE=y
CONFIG_BPF_TOOLCHAIN_HOST=y
CONFIG_BPF_TOOLCHAIN_HOST_PATH="/usr"
# CONFIG_BPF_TOOLCHAIN_NONE is not set
CONFIG_KERNEL_XDP_SOCKETS=y
CONFIG_PACKAGE_kmod-sched-core=y
CONFIG_PACKAGE_kmod-sched-bpf=y
CONFIG_PACKAGE_kmod-veth=y
CONFIG_PACKAGE_kmod-xdp-sockets-diag=y

# Container runtimes and their management applications are intentionally excluded
# CONFIG_PACKAGE_docker is not set
# CONFIG_PACKAGE_docker-lan-bridge is not set
# CONFIG_PACKAGE_dockerd is not set
# CONFIG_PACKAGE_dockermanager is not set
# CONFIG_PACKAGE_libLXC is not set
# CONFIG_PACKAGE_liblxc is not set
# CONFIG_PACKAGE_lxc is not set
# CONFIG_PACKAGE_lxc-auto is not set
# CONFIG_PACKAGE_lxc-common is not set
# CONFIG_PACKAGE_lxc-configs is not set
# CONFIG_PACKAGE_lxc-hooks is not set
# CONFIG_PACKAGE_lxc-init is not set
# CONFIG_PACKAGE_lxc-templates is not set
# CONFIG_PACKAGE_lxc-unprivileged is not set
# CONFIG_PACKAGE_luci-app-dockerman is not set
# CONFIG_PACKAGE_luci-app-dockermanager is not set
# CONFIG_PACKAGE_luci-app-lxc is not set
# CONFIG_PACKAGE_luci-lib-docker is not set

CONFIG_PACKAGE_luci-i18n-argon-config-zh-cn=y
# CONFIG_PACKAGE_luci-i18n-clashoo-zh-cn is not set
# CONFIG_PACKAGE_luci-i18n-ddns-go-zh-cn is not set
CONFIG_PACKAGE_luci-i18n-frpc-zh-cn=y
CONFIG_PACKAGE_luci-i18n-quickstart-zh-cn=y
CONFIG_PACKAGE_luci-i18n-turboacc-zh-cn=y
CONFIG_PACKAGE_luci-i18n-upnp-zh-cn=y
EOF
