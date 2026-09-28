rm -rf package/emortal/luci-app-athena-led








git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led








chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led








# QModem: manual copy (bypass feeds system - feeds install breaks dep resolution)
rm -rf /tmp/qmodem-src package/qmodem package/luci-app-qmodem-next 2>/dev/null || true
git clone --depth 1 https://github.com/FUjr/QModem.git /tmp/qmodem-src
cp -r /tmp/qmodem-src/application/qmodem package/qmodem
cp -r /tmp/qmodem-src/luci/luci-app-qmodem-next package/luci-app-qmodem-next
# Fix version.mk include (relative path breaks)
sed -i '/include ..\/..\/version.mk/d' package/qmodem/Makefile package/luci-app-qmodem-next/Makefile 2>/dev/null || true
sed -i 's/PKG_VERSION:=$(QMODEM_VERSION)/PKG_VERSION:=3.4.0_rc3/' package/qmodem/Makefile 2>/dev/null || true
sed -i 's/PKG_RELEASE:=$(QMODEM_RELEASE)/PKG_RELEASE:=1/' package/qmodem/Makefile 2>/dev/null || true
[ -f package/qmodem/Makefile ] || { echo "ERROR: qmodem manual copy failed"; exit 1; }
[ -f package/luci-app-qmodem-next/Makefile ] || { echo "ERROR: luci-app-qmodem-next manual copy failed"; exit 1; }
echo "qmodem manual copy OK"



