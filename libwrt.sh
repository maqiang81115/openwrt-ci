rm -rf package/emortal/luci-app-athena-led


git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led


chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led


# QModem feed: qmodem core + luci-app-qmodem-next (with Chinese LuCI UI)


grep -q "^src-git qmodem" feeds.conf.default || echo "src-git qmodem https://github.com/FUjr/QModem.git;main" >> feeds.conf.default


./scripts/feeds update qmodem


# Install only needed qmodem packages. Do NOT use -a: the qmodem feed ships an
# ancient ndisc6 (1.0.2) that overwrites the standard packages feed ndisc6 and
# breaks the dep chain, causing defconfig to silently drop ALL qmodem feed
# packages (build #5 root cause).
# Full qmodem feed install (build #5 used -a and compiled OK; selective install may break dep resolution)
./scripts/feeds install -a -p qmodem
# Remove ancient ndisc6 bundled in qmodem feed (1.0.2) - it overrides the standard ndisc6 and breaks the dependency chain
rm -rf package/feeds/qmodem/ndisc6 feeds/qmodem/ndisc6 2>/dev/null || true
# Remove broken ../../version.mk include and hardcode version (feeds install breaks the relative path)
sed -i '/include ..\/..\/version.mk/d' package/feeds/qmodem/*/Makefile 2>/dev/null || true
sed -i 's/PKG_VERSION:=$(QMODEM_VERSION)/PKG_VERSION:=3.4.0_rc3/' package/feeds/qmodem/*/Makefile 2>/dev/null || true
sed -i 's/PKG_RELEASE:=$(QMODEM_RELEASE)/PKG_RELEASE:=1/' package/feeds/qmodem/*/Makefile 2>/dev/null || true


# Fix broken conditional deps in qmodem Makefile that cause `make defconfig`
# to silently drop the package:
# - kmod-mhi-wwan, kmod-mhi-pci-generic, kmod-pcie_mhi do not exist in any feed
# - quectel-CM-5G is a typo; the real package is quectel-CM-5G-M
QMODEM_MK="package/feeds/qmodem/qmodem/Makefile"
if [ -f "$QMODEM_MK" ]; then
  sed -i '/kmod-mhi-wwan/d; /kmod-mhi-pci-generic/d; /kmod-pcie_mhi/d' "$QMODEM_MK"
  sed -i 's/quectel-CM-5G \\/quectel-CM-5G-M \\/g; s/quectel-CM-5G$/quectel-CM-5G-M/g' "$QMODEM_MK"
  if grep -q "kmod-mhi-wwan\|kmod-mhi-pci-generic\|kmod-pcie_mhi" "$QMODEM_MK"; then
    echo "ERROR: broken MHI dep still in qmodem Makefile"; exit 1
  fi
  if grep -Eq ":quectel-CM-5G([ \\]|$)" "$QMODEM_MK"; then
    echo "ERROR: quectel-CM-5G typo still in qmodem Makefile"; exit 1
  fi
  echo "qmodem Makefile deps fixed"
else
  echo "ERROR: qmodem feed install failed"; exit 1
fi


[ -f package/feeds/qmodem/luci-app-qmodem-next/Makefile ] || { echo "ERROR: luci-app-qmodem-next not installed"; exit 1; }


echo "qmodem feed OK"
