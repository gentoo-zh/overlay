# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature shell-completion systemd xdg

DESCRIPTION="Standalone calendar for local, Google, Microsoft, and CalDAV accounts"
HOMEPAGE="https://github.com/duxlabs-dev/dux-calendar"
SRC_URI="
	amd64? (
		https://github.com/duxlabs-dev/dux-calendar/releases/download/v${PV}/dcal-linux-amd64.tar.gz
			-> dcal-${PV}-linux-amd64.tar.gz
	)
	arm64? (
		https://github.com/duxlabs-dev/dux-calendar/releases/download/v${PV}/dcal-linux-arm64.tar.gz
			-> dcal-${PV}-linux-arm64.tar.gz
	)
	https://github.com/duxlabs-dev/dux-calendar/releases/download/v${PV}/dcal-completions-${PV}.tar.gz
	https://raw.githubusercontent.com/duxlabs-dev/dux-calendar/v${PV}/LICENSE -> ${P}-LICENSE
	https://raw.githubusercontent.com/duxlabs-dev/dux-calendar/v${PV}/assets/systemd/dcal.service -> ${P}-dcal.service
"
S="${WORKDIR}"

LICENSE="
	MIT Apache-2.0 BSD BSD-2 CC0-1.0 GPL-2+ MPL-2.0 OFL-1.1
	Unicode-3.0 Unicode-DFS-2016 public-domain
"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="
	dev-qt/qtdeclarative:6[widgets]
	gui-apps/quickshell[sockets,wayland]
"

QA_PREBUILT="usr/bin/dcal"

src_install() {
	newbin "dcal-linux-${ARCH}" dcal
	domenu assets/dev.duxlabs.calendar.desktop
	doicon -s scalable assets/dev.duxlabs.calendar.svg
	insinto /usr/share/metainfo
	doins assets/dev.duxlabs.calendar.metainfo.xml

	dobashcomp dcal
	dofishcomp dcal.fish
	dozshcomp _dcal
	systemd_newuserunit "${DISTDIR}/${P}-dcal.service" dcal.service
	newdoc "${DISTDIR}/${P}-LICENSE" LICENSE
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "reminder sounds" media-video/pipewire[extra] media-libs/libpulse
	optfeature "credential storage" virtual/secret-service
}
