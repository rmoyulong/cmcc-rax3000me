cd openwrt

cp -rf $GITHUB_WORKSPACE/patch/mt7981/filogic.mk target/linux/mediatek/image/filogic.mk
cp -rf $GITHUB_WORKSPACE/patch/mt7981/mt7981b-cmcc-rax3000me.dts target/linux/mediatek/dts/mt7981b-cmcc-rax3000me.dts
ls -l target/linux/mediatek