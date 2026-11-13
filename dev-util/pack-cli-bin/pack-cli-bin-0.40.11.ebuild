# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="CLI for building apps using Cloud Native Buildpacks"
HOMEPAGE="https://buildpacks.io https://paketo.io https://github.com/buildpacks/pack"

SRC_URI="
	amd64? ( https://github.com/buildpacks/pack/releases/download/v${PV}/pack-v${PV}-linux.tgz )
	arm64? ( https://github.com/buildpacks/pack/releases/download/v${PV}/pack-v${PV}-linux-arm64.tgz )
"

S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

QA_PRESTRIPPED="usr/bin/pack"

RDEPEND="
	|| (
		app-containers/docker-cli
		app-containers/podman
	)
"
RDEPEND+=" !dev-util/pack-cli"

src_install() {
	dobin pack
}
