# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit optfeature

DESCRIPTION="Control-plane CLI for portable QM deployments"
HOMEPAGE="https://qm.ycombinator.com https://github.com/yc-software/qm"
SRC_URI="https://registry.npmjs.org/@yc-software/${PN}/-/${P}.tgz"
S="${WORKDIR}/package"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND=">=net-libs/nodejs-24"

src_install() {
	local install_dir="/usr/lib/node_modules/@yc-software/${PN}"

	insinto "${install_dir}"
	doins -r "${S}"/*
	fperms +x "${install_dir}/dist/bin/qm.js"
	dosym "../lib/node_modules/@yc-software/${PN}/dist/bin/qm.js" /usr/bin/qm
}

pkg_postinst() {
	optfeature "Git repository operations" dev-vcs/git
	optfeature "Docker deployments" \
		"app-containers/docker-cli app-containers/docker-buildx"
	optfeature "Fly.io deployments" net-misc/flyctl-bin
	optfeature "AWS deployments" \
		"app-admin/awscli app-admin/terraform app-containers/docker-cli app-containers/docker-buildx"
}
