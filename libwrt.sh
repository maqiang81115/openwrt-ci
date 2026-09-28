rm -rf package/emortal/luci-app-athena-led

git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led

chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led

# QModem feed: qmodem core + luci-app-qmodem-next (with Chinese LuCI UI)

grep -q "^src-git qmodem" feeds.conf.default || echo "src-git qmodem https://github.com/FUjr/QModem.git;main" >> feeds.conf.default

./scripts/feeds update qmodem

./scripts/feeds install -a -p qmodem

# Fix broken conditional deps in qmodem Makefile that cause `make defconfig`
# to silently drop the package (build #4: qmodem vanished from .config):
# - kmod-mhi-wwan does not exist in any feed
# - quectel-CM-5G is a typo; the real package is quectel-CM-5G-M
QMODEM_MK="package/feeds/qmodem/qmodem/Makefile"
if [ -f "$QMODEM_MK" ]; then
  sed -i '/kmod-mhi-wwan/d' "$QMODEM_MK"
  sed -i 's/quectel-CM-5G \\$/quectel-CM-5G-M \\/' "$QMODEM_MK"
  grep -q "kmod-mhi-wwan" "$QMODEM_MK" && { echo "ERROR: kmod-mhi-wwan still in qmodem Makefile"; exit 1; }
  grep -q "QUCTEL_CM_5G:quectel-CM-5G " "$QMODEM_MK" && { echo "ERROR: quectel-CM-5G typo still in qmodem Makefile"; exit 1; }
  echo "qmodem Makefile deps fixed"
else
  echo "ERROR: qmodem feed install failed"; exit 1
fi

[ -f package/feeds/qmodem/luci-app-qmodem-next/Makefile ] || { echo "ERROR: luci-app-qmodem-next not installed"; exit 1; }

echo "qmodem feed OK"
