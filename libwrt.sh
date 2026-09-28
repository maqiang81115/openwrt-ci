rm -rf package/emortal/luci-app-athena-led
git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led
chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led

# QModem feed: qmodem core + luci-app-qmodem-next (with Chinese LuCI UI)
grep -q "^src-git qmodem" feeds.conf.default || echo "src-git qmodem https://github.com/FUjr/QModem.git;main" >> feeds.conf.default
./scripts/feeds update qmodem
./scripts/feeds install -a -p qmodem

# Verify qmodem feed installed correctly (fail fast, don't waste a 2h build)
[ -f package/feeds/qmodem/qmodem/Makefile ] || { echo "ERROR: qmodem feed install failed"; exit 1; }
[ -f package/feeds/qmodem/luci-app-qmodem-next/Makefile ] || { echo "ERROR: luci-app-qmodem-next not installed"; exit 1; }
echo "qmodem feed OK"
