# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Command line tools for fly.io services"
HOMEPAGE="https://github.com/superfly/flyctl"
BASE_URI="https://github.com/superfly/flyctl/releases/download/v${PV}/flyctl_${PV}"
SRC_URI="
	amd64? ( ${BASE_URI}_Linux_x86_64.tar.gz )
	arm64? ( ${BASE_URI}_Linux_arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RDEPEND="sys-libs/glibc"

QA_PREBUILT="/usr/bin/flyctl"
RESTRICT="strip"

src_install() {
	dobin flyctl
}
