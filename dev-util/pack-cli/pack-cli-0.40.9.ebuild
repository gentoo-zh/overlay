# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="CLI for building apps using Cloud Native Buildpacks"
HOMEPAGE="https://buildpacks.io https://paketo.io https://github.com/buildpacks/pack"

SRC_URI="https://github.com/buildpacks/pack/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+="
	https://github.com/gentoo-zh-drafts/pack/releases/download/v${PV}/pack-${PV}-vendor.tar.xz
		-> ${P}-vendor.golang-dist-mirror-action.tar.xz
"

S="${WORKDIR}/pack-${PV}"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

RDEPEND="
	|| (
		app-containers/docker-cli
		app-containers/podman
	)
"
RDEPEND+=" !dev-util/pack-cli-bin"
BDEPEND=">=dev-lang/go-1.25.12"

src_compile() {
	local ldflags="-X 'github.com/buildpacks/pack/pkg/client.Version=${PV}'"
	ego build -ldflags "${ldflags}" .
}

src_install() {
	dobin pack
}
