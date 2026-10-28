# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Qoder CLI, Qoder's command-line coding agent"
HOMEPAGE="https://qoder.com/cli/"
SRC_URI="
	amd64? (
		https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/${PV}/qodercli-linux-x64.tar.gz -> ${P}-amd64.tar.gz
	)
	arm64? (
		https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/${PV}/qodercli-linux-arm64.tar.gz -> ${P}-arm64.tar.gz
	)
"

S="${WORKDIR}"

LICENSE="Qoder-EULA"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="mirror bindist strip"

QA_PREBUILT="usr/bin/qodercli"

src_install() {
	dobin qodercli
}
