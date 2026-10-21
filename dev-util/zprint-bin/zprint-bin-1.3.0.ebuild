# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Clojure and Clojurescript source code formatter"
HOMEPAGE="https://github.com/kkinnear/zprint"
SRC_URI="https://github.com/kkinnear/zprint/releases/download/${PV}/zprintl-${PV}"

S="${DISTDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

QA_PREBUILT="usr/bin/zprint"

src_install() {
	newbin "${S}/zprintl-${PV}" zprint
}
