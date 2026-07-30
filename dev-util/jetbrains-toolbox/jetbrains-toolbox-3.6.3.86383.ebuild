# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Manage all your JetBrains Projects and Tools"
HOMEPAGE="https://www.jetbrains.com/toolbox-app/"
SRC_URI="
	amd64? ( https://download.jetbrains.com/toolbox/${P}.tar.gz )
	arm64? ( https://download.jetbrains.com/toolbox/${P}-arm64.tar.gz )
"

S="${WORKDIR}/${PN}/bin"

LICENSE="JetBrainsToolbox"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	media-libs/alsa-lib
	sys-fs/fuse:0
"

RESTRICT="strip mirror"

QA_PREBUILT="/opt/${PN}/${PN}"

src_unpack() {
	default
	# Normalize directory name for arm64
	if use arm64; then
		mv "${WORKDIR}/${P}-arm64" "${WORKDIR}/${PN}" || die
	else
		mv "${WORKDIR}/${P}" "${WORKDIR}/${PN}" || die
	fi
}

src_install() {
	dodir /opt/"${PN}"
	cp -PR --preserve=mode,timestamps . "${ED}/opt/${PN}" || die
	rm -f "${ED}/opt/${PN}"/._* || die

	fperms +x "/opt/${PN}/${PN}"

	dosym "../../opt/${PN}/${PN}" /usr/bin/jetbrains-toolbox

	# Fix desktop file: add Categories
	cp "${PN}.desktop" "${T}/${PN}.desktop" || die
	sed -i '/^MimeType=/a Categories=Development;IDE;' "${T}/${PN}.desktop" || die
	domenu "${T}/${PN}".desktop
}

pkg_postinst() {
	xdg_pkg_postinst

	# Required for app to behave correctly
	chmod -R 777 /opt/"${PN}"
}
