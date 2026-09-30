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
