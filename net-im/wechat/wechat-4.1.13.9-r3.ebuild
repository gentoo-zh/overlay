# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg

DESCRIPTION="Weixin for Linux"
HOMEPAGE="https://linux.weixin.qq.com"
SRC_URI="
	amd64? ( https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb -> wechat-${PV}_x86_64.deb )
	arm64? ( https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_arm64.deb -> wechat_${PV}_arm64.deb )
	loong? ( https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_LoongArch.deb -> wechat_${PV}_loongarch64.deb )
"
S=${WORKDIR}

LICENSE="all-rights-reserved"

SLOT="0"
KEYWORDS="-* ~amd64 ~arm64 ~loong"
IUSE="bwrap wayland"

RESTRICT="strip mirror bindist"
BDEPEND="
	dev-util/patchelf
"
RDEPEND="
	app-accessibility/at-spi2-core
	app-arch/bzip2
	app-crypt/mit-krb5
	dev-libs/nss
	dev-libs/wayland
	media-libs/libpulse
	media-libs/mesa
	net-print/cups
	virtual/jack
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libxkbcommon[X]
	x11-libs/libXrandr
	x11-libs/pango
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
	bwrap? (
		sys-apps/bubblewrap
		x11-misc/xdg-utils
	)
	loong? ( virtual/loong-ow-compat )
"
QA_PREBUILT="*"

src_prepare() {
	default

	# add any QA scanelf alert files here.
	local so_files=(
		"RadiumWMPF/runtime/libilink2.so"
		"libilink2.so"
		"libconfService.so"
		"libvoipChannel.so"
		"libvoipCodec.so"
	)

	for file in "${so_files[@]}"; do
		patchelf --set-rpath '$ORIGIN' "opt/wechat/${file}" || die
	done

	# app-arch/bzip2 provides libbz2.so.1; the 1.0 name is only a symlink
	patchelf --replace-needed libbz2.so.1.0 libbz2.so.1 opt/wechat/libwxtrans.so || die
}

src_install() {
	dodir /opt/wechat
	cp -r opt/wechat/. "${D}/opt/wechat/" || die

	local launcher=wechat.sh
	if use bwrap; then
		launcher=bwrap.sh
		exeinto /opt/wechat
		doexe "${FILESDIR}/xdg-open.sh"
	fi

	cp "${FILESDIR}/${launcher}" "${T}" || die
	if use wayland; then
		sed -i -e "/^EBUILD_WAYLAND=/s/false/true/" "${T}/${launcher}" || die
	fi
	newbin "${T}/${launcher}" wechat

	sed -i \
		-e "s|^Icon=.*|Icon=wechat|" \
		-e "s|^Categories=.*|Categories=Network;InstantMessaging;Chat;|" \
		-e "s|^Exec=.*|Exec=/usr/bin/wechat %U|" \
		usr/share/applications/wechat.desktop || die
	domenu usr/share/applications/wechat.desktop

	for size in 16 32 48 64 128 256; do
		doicon -s "${size}" usr/share/icons/hicolor/"${size}"x"${size}"/apps/wechat.png
	done
}

pkg_postinst() {
	xdg_pkg_postinst
	if use bwrap; then
		elog "Enabled Bubblewrap support."
		elog "WeChat can only access its own sandbox home and XDG Downloads directory by default."
		elog "To send files, put them under your XDG Downloads directory first, then drag"
		elog "them into WeChat or select them from WeChat's file chooser."
		elog "启用 Bubblewrap 支持后，微信默认只能访问自己的沙盒 HOME 和 XDG 下载目录。"
		elog "发送文件前请先把文件放到 XDG 下载目录下，然后拖入微信或从微信文件选择器中选择。"
		elog "Advanced users can extend the sandbox using ~/.config/wechat-bwrap-flags.conf."
	fi
}
