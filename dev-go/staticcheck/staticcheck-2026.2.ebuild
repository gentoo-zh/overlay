# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Go static analysis, detecting bugs, performance issues, and much more"
HOMEPAGE="https://staticcheck.dev https://github.com/dominikh/go-tools"
SRC_URI="
	https://github.com/dominikh/go-tools/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/go-tools/releases/download/${PV}/go-tools-${PV}-vendor.tar.xz
		-> ${P}-vendor.golang-dist-mirror-action.tar.xz
"
S="${WORKDIR}/go-tools-${PV}"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

# go.mod go directive is 1.25.0, above the go-module eclass floor
BDEPEND=">=dev-lang/go-1.26.0"

src_compile() {
	ego build -o "bin/${PN}" "./cmd/${PN}"
}

src_test() {
	ego test ./...
}

src_install() {
	dobin "bin/${PN}"
}
