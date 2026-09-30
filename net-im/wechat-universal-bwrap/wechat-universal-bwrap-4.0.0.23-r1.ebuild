# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop toolchain-funcs unpacker xdg

DESCRIPTION="WeChat (Universal) with bwrap sandbox"
HOMEPAGE="https://weixin.qq.com https://github.com/7Ji-PKGBUILDs/wechat-universal-bwrap"

APP_NAME="com.tencent.wechat"
URL_ROOT="https://home-store-packages.uniontech.com/appstore/pool/appstore/c/${APP_NAME}"
DEB_STEM="${APP_NAME}_${PV}"
AUR_REPO_REF="8ee52cb9ff6e00a0a6910e1863cac9bf4c2d386f"
SRC_URI="
	amd64? ( ${URL_ROOT}/${DEB_STEM}_amd64.deb )
	arm64? ( ${URL_ROOT}/${DEB_STEM}_arm64.deb )
	loong? ( ${URL_ROOT}/${DEB_STEM}_loongarch64.deb )
	https://github.com/7Ji-PKGBUILDs/wechat-universal-bwrap/archive/${AUR_REPO_REF}.tar.gz
		-> wechat-universal-bwrap-${AUR_REPO_REF}.tar.gz
"

S="${WORKDIR}"
LICENSE="Tencent-Weixin GPL-2+"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64 ~loong"
RESTRICT="bindist strip mirror"

# the sonames are gathered with the following trick
#
# objdump -p /path/weixin | grep NEEDED | awk '{print $2}' | xargs equery b | sort | uniq
BLOB_RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl-compat:1.1.1
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libglvnd
	media-libs/libpulse
	media-libs/mesa
	media-libs/tiff-compat:4
	sys-apps/dbus
	virtual/jack
	virtual/zlib
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/pango
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
"

RDEPEND="
	${BLOB_RDEPEND}
	sys-apps/bubblewrap
	sys-apps/lsb-release
	x11-misc/flatpak-xdg-utils
	x11-misc/xdg-user-dirs
	loong? ( virtual/loong-ow-compat )
"
BDEPEND="dev-util/patchelf"

QA_PREBUILT="*"

src_prepare() {
	elog "Start patch wechat-universal.sh about launcher fs layout"
	pushd "${S}/wechat-universal-bwrap-${AUR_REPO_REF}" > /dev/null
	eapply "${FILESDIR}/adjust-launcher-fs-layout-2.patch"
	popd > /dev/null

	default
}

call_cc() {
	local cc="$(tc-getCC)"
	echo "$cc" "$@"
	"$cc" "$@" || die
}

call_patchelf() {
	echo patchelf "$@"
	patchelf "$@" || die
}

src_compile() {
	einfo "Fixing blob RUNPATHs"
	pushd "${S}/opt/apps/${APP_NAME}/files" > /dev/null
	# originally $ORIGIN:$ORIGIN
	call_patchelf --set-rpath '$ORIGIN' RadiumWMPF/runtime/WeChatAppEx
	# orginally /data/devops-xwechat/workspace/translib_linux_test/linux/3rd_x86_64/lib
	call_patchelf --set-rpath '$ORIGIN' libwxtrans.so
	# originally $ORIGIN:/home/ubuntu/.wconan2/ilink/fcafc08e_1712581517/libs/Release/
	# clang-llvm-12.0.0/libs
	call_patchelf --set-rpath '$ORIGIN' RadiumWMPF/runtime/libilink2.so
	# originally /home/ubuntu/.wconan2/ilink_network/7fd99102_1712579641/ilink-network/libs/Release/
	# clang-llvm-12.0.0/libs:
	call_patchelf --set-rpath '$ORIGIN' RadiumWMPF/runtime/libilink_network.so
	# originally ./ (!!!)
	call_patchelf --remove-rpath libvoipChannel.so
	call_patchelf --remove-rpath libvoipCodec.so
	call_patchelf --remove-rpath libconfService.so

	call_patchelf --remove-rpath libilink2.so
	call_patchelf --remove-rpath libilink_network.so
	# look like without meaning, same lib on my system
	call_patchelf --remove-needed libbz2.so.1.0 wechat
	call_patchelf --add-needed libbz2.so.1 wechat

	einfo 'Stripping executable permission of non-ELF files...'
	local _file
	for _file in $(find -type f -perm /111); do
		readelf -h "${_file}" &>/dev/null && continue || true
		stat --printf '  %A => ' "${_file}"
		chmod u-x,g-x,o-x "${_file}"
		stat --format '%A %n' "${_file}"
	done

	popd > /dev/null

	einfo "Building stub libuosdevicea.so"
	pushd "${S}/wechat-universal-bwrap-${AUR_REPO_REF}" > /dev/null
	call_cc -fPIC -shared ${CFLAGS} ${LDFLAGS} -o libuosdevicea.so libuosdevicea.c || die
	popd > /dev/null
}

src_install() {
	LIB_DIR=/usr/lib/wechat-universal
	pushd "${S}/wechat-universal-bwrap-${AUR_REPO_REF}" > /dev/null
	domenu wechat-universal.desktop
	exeinto /usr/lib/wechat-universal
	newexe wechat-universal.sh start.sh
	newexe wechat-universal.sh stop.sh

	exeinto ${LIB_DIR}/usr/bin
	newexe fake_dde-file-manager dde-file-manager

	insinto /opt/wechat-universal
	doins libuosdevicea.so
	insinto ${LIB_DIR}/usr/lib/license
	doins libuosdevicea.so
	popd > /dev/null

	# needed on the host side for bwrap to be able to do the bind-mount
	keepdir /usr/lib/license

	insinto ${LIB_DIR}/etc
	newins "${FILESDIR}/stub-uos-release" lsb-release

	insinto /opt/wechat-universal
	doins -r "${S}/opt/apps/${APP_NAME}/files/"*
	fperms 0755 /opt/wechat-universal/{crashpad_handler,wechat,wxocr,wxplayer}
	fperms 0755 /opt/wechat-universal/RadiumWMPF/runtime/WeChatAppEx{,_crashpad_handler}

	einfo "Installing icons..."
	for i in 16 32 64 128 256; do
		png_file="${S}/opt/apps/${APP_NAME}/entries/icons/hicolor/${i}x${i}/apps/${APP_NAME}.png"
		if [ -e "${png_file}" ]; then
			newicon -s "${i}" -c apps "${png_file}" "wechat-universal.png"
		fi
	done
}

pkg_postinst() {
	xdg_pkg_postinst

	if [[ "$LANG" == "zh_CN.UTF-8" ]]; then
		elog '>> 注意！升级至4.0版本后，环境变量已统一至WECHAT_ 前缀'
		elog '>> 执行 `wechat-universal --help` 来查看相关帮助信息'
	else
		elog '>> Warning! After updating to v4.0, all environment variables are unified to be prefixed with WECHAT_'
		elog '>> Run `wechat-universal --help` to check for the help message'
	fi
}

pkg_postrm() {
	xdg_pkg_postrm
}
