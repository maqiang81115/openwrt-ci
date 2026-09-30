rm -rf package/emortal/luci-app-athena-led

git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led
chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led

# QModem: full clone (qmodem DEPENDS references sibling packages in the same repo;
# a partial copy breaks apk dependency resolution at package/install stage)
rm -rf package/qmodem package/luci-app-qmodem-next 2>/dev/null || true
git clone --depth 1 -b main https://github.com/FUjr/QModem.git package/qmodem
[ -f package/qmodem/application/qmodem/Makefile ] || { echo "ERROR: qmodem clone failed"; exit 1; }
[ -f package/qmodem/luci/luci-app-qmodem-next/Makefile ] || { echo "ERROR: luci-app-qmodem-next missing"; exit 1; }
echo "qmodem full clone OK"
### NSS rmnet fix (ref: openwrt-ci-roc Roc-script.sh) ###
# qca-nss-ecm 无条件引用 nss_rmnet_rx_get_ifnum；NSS_DRV_RMNET_ENABLE 在
# qca-nss-drv/Config.in 里 depends on ipq807x||ipq50xx，ipq60xx 上 make defconfig
# 会静默丢弃该选项，因此直接改驱动 Makefile 强制开启 RMNET。
DRV_MAKEFILE="feeds/nss_packages/qca-nss-drv/Makefile"
if [ -f "$DRV_MAKEFILE" ]; then
  sed -i "/^ifndef CONFIG_NSS_DRV_RMNET_ENABLE$/,/^endif$/d" "$DRV_MAKEFILE"
  sed -i "s|^DRV_MAKE_OPTS:=|DRV_MAKE_OPTS:\nDRV_MAKE_OPTS += NSS_DRV_RMNET_ENABLE=y|" "$DRV_MAKEFILE"
  grep -q "NSS_DRV_RMNET_ENABLE=y" "$DRV_MAKEFILE" && echo "NSS rmnet Makefile fix OK" || { echo "ERROR: NSS rmnet Makefile fix failed"; exit 1; }
else
  echo "ERROR: $DRV_MAKEFILE not found"; exit 1
fi
