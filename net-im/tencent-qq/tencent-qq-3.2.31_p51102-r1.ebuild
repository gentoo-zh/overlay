# Copyright 2019-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

MY_PV="${PV/_p/-}"

qq_src_uri() {
	echo "${1}? ( https://qqdl.gtimg.cn/qqfile/QQNT/9.9.32/release/c390e792/QQ_${PV%_p*}_260710_${2:-$1}_01.deb -> ${P}_${1}.deb )"
}

DESCRIPTION="The new version of the official linux-qq"
HOMEPAGE="https://im.qq.com/index/#/linux"
SRC_URI="
	$(qq_src_uri amd64)
	$(qq_src_uri arm64)
	$(qq_src_uri loong loongarch64)
"

S="${WORKDIR}"

LICENSE="Tencent"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

IUSE="bwrap system-fdk-aac system-libssh2 system-openh264 system-zlib gnome"

RESTRICT="strip mirror"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	bwrap? (
		sys-apps/bubblewrap
		x11-misc/flatpak-xdg-utils
	)
	dev-libs/nss
	gnome? ( dev-libs/gjs )
	loong? ( virtual/loong-ow-compat )
	media-libs/alsa-lib
	media-libs/libpulse
	media-libs/mesa
	media-libs/openslide
	net-print/cups
	sys-apps/keyutils
	system-fdk-aac? ( media-libs/fdk-aac )
	system-libssh2? ( net-libs/libssh2 )
	system-openh264? ( media-libs/openh264 )
	system-zlib? ( virtual/zlib )
	virtual/krb5
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-libs/libXdamage
	x11-libs/libXcomposite
	x11-libs/libXft
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/libxkbcommon
	x11-misc/xdg-utils
"

src_unpack() {
	:
}

src_install() {
	dodir /
	cd "${D}" || die

	unpacker "${DISTDIR}/${P}_${ARCH}.deb"

	rm -rv "${D}/usr/share/doc" || die

	if use system-fdk-aac; then
		rm -v "${D}/opt/QQ/resources/app/avsdk/libfdk-aac.so" || die
	fi
	if use system-libssh2; then
		rm -v "${D}/opt/QQ/resources/app/libssh2.so.1" "${D}/opt/QQ/resources/app/avsdk/bugly/libssh2.so.1" || die
	fi
	if use system-openh264; then
		rm -v "${D}/opt/QQ/resources/app/avsdk/libopenh264.so" || die
	fi
	if use system-zlib; then
		rm -v "${D}/opt/QQ/libz.so.1" || die
	fi

	if use bwrap; then
		newbin "${FILESDIR}/bwrap.sh" qq

		insinto /opt/QQ/workarounds
		doins "${FILESDIR}"/{config.json,vercmp.sh}
		fperms +x /opt/QQ/workarounds/vercmp.sh

		sed -i "s|__BASE_VER__|${MY_PV}|g;s|__CURRENT_VER__|${MY_PV}|g;s|__BUILD_VER__|${MY_PV#*-}|g" \
			"${D}/opt/QQ/workarounds/config.json" \
			"${D}/usr/bin/qq" || die
	else
		newbin "${FILESDIR}/qq.sh" qq
	fi

	sed -i 's:^Exec=.*$:Exec=/usr/bin/qq %U:g;s:^Icon=.*$:Icon=qq:g' "${D}/usr/share/applications/qq.desktop" || die
}

pkg_postinst() {
	xdg_pkg_postinst
	if use bwrap; then
		elog "-EN-----------------------------------------------------------------"
		elog "Enabled Bubblewrap support."
		elog "If you want to download files to system download folder in QQ,"
		elog "please set the download folder to the system download folder in the QQ settings."
		elog "You can also define other bwrap parameters in \"~/.config/qq-bwrap-flags.conf\"."
		elog "--------------------------------------------------------------------"
		elog "-ZH-----------------------------------------------------------------"
		elog "Bubblewrap 支持已启用。"
		elog "如果需要在 QQ 中下载文件至系统下载文件夹，"
		elog "请在「设置」->「存储管理」中把下载文件夹更改为系统的下载文件夹。"
		elog "可在 \"~/.config/qq-bwrap-flags.conf\" 中设置其他 bwrap 参数。"
		elog "--------------------------------------------------------------------"
	fi
}
