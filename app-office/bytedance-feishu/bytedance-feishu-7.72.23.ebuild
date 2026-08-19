# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit desktop unpacker xdg
DESCRIPTION="
飞书（Feishu）
飞书整合即时消息、日历、音视频会议、云文档、工作台等功能于一体，成就团队和个人，更高效、更愉悦。 "
HOMEPAGE="https://www.feishu.cn/download"
SRC_URI="
	amd64? ( https://sf3-cn.feishucdn.com/obj/ee-appcenter/fc38d53a/Feishu-linux_x64-${PV}.deb )
	arm64? ( https://sf3-cn.feishucdn.com/obj/ee-appcenter/8d668c7a/Feishu-linux_arm64-${PV}.deb )
"

S="${WORKDIR}"
LICENSE="Feishu-EULA"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="strip mirror bindist"

DEPEND="
	app-misc/ca-certificates
	dev-libs/nss
	media-libs/mesa
	media-libs/alsa-lib
	media-libs/libpulse
	x11-libs/gtk+:3[cups,X]
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libXext
	x11-libs/libxkbcommon
	x11-misc/xdg-utils
"
BDEPEND="
	dev-util/patchelf
"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	unpacker "${S}/usr/share/man/man1/bytedance-feishu-stable.1.gz"
	unpacker "${S}/usr/share/doc/bytedance-feishu-stable/changelog.gz"
}

src_install() {
	local rpath_libs=( libbv-screen-capture.so libbyteview-bytertc.so )
	if use arm64; then
		# upstream ships an x86-64 build of this library in the arm64 package, so
		# it can never load there
		rm "${S}/opt/bytedance/feishu/libbyteview-record.so" || die
	else
		rpath_libs+=( libbyteview-record.so )
	fi

	# fix scanelf rpath error: https://github.com/microcai/gentoo-zh/issues/7666
	local f
	for f in "${rpath_libs[@]}"; do
		patchelf --set-rpath '$ORIGIN' "${S}/opt/bytedance/feishu/${f}" || die "patchelf failed on ${f}"
	done
	insinto "/"
	doins -r "${S}/opt/"
	dosym -r /opt/bytedance/feishu/bytedance-feishu /usr/bin/bytedance-feishu-stable
	domenu "${S}/usr/share/applications/bytedance-feishu.desktop"
	doman "${S}/bytedance-feishu-stable.1"
	dodoc "${S}/changelog"
	local size
	for size in 16 24 32 48 64 128 256 ; do
		newicon -s ${size} "${S}/opt/bytedance/feishu/product_logo_${size}.png" ${PN}.png
	done
	newicon -s scalable "${S}/opt/bytedance/feishu/product_logo_256.svg" ${PN}.svg

	fperms +x "/opt/bytedance/feishu/bytedance-feishu"
	fperms +x "/opt/bytedance/feishu/feishu"
}
