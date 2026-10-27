# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Qoder Wake, Qoder's local agent runtime for coding agents"
HOMEPAGE="https://qoder.com/"
SRC_URI="
	amd64? (
		https://download.qoder.com/qoderwake/releases/${PV}/qoderwake_${PV}_linux_amd64.tar.gz -> ${P}-amd64.tar.gz
	)
	arm64? (
		https://download.qoder.com/qoderwake/releases/${PV}/qoderwake_${PV}_linux_arm64.tar.gz -> ${P}-arm64.tar.gz
	)
"

S="${WORKDIR}"

LICENSE="Qoder-EULA"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="mirror bindist strip"

QA_PREBUILT="opt/qoderwake/*"

src_install() {
	local dest=/opt/qoderwake

	exeinto ${dest}
	doexe qoderwake
	exeinto ${dest}/qodercli
	doexe qodercli/qodercli-wake

	insinto ${dest}
	doins -r resources

	dosym -r /opt/qoderwake/qoderwake /usr/bin/qoderwake
}
