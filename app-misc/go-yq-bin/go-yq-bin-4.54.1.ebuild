# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="yq is a portable command-line YAML, JSON and XML processor"
HOMEPAGE="https://github.com/mikefarah/yq"

SRC_URI="
	amd64? ( https://github.com/mikefarah/yq/releases/download/v${PV}/yq_linux_amd64.tar.gz -> ${P}.tar.gz )
	arm64? ( https://github.com/mikefarah/yq/releases/download/v${PV}/yq_linux_arm64.tar.gz -> ${P}-arm64.tar.gz )
"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RDEPEND="!app-misc/yq"

QA_PREBUILT="*"

src_install() {
	doman yq.1
	newbin yq_linux_$(usex arm64 arm64 amd64) yq
}
