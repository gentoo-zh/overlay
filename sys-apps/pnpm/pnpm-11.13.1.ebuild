# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Fast, disk space efficient package manager"
HOMEPAGE="https://pnpm.io"
SRC_URI="https://registry.npmjs.org/${PN}/-/${P}.tgz"
S="${WORKDIR}/package"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="net-libs/nodejs"
RDEPEND="${DEPEND}"

src_compile() {
	:
}

src_install(){
	local install_dir="/usr/$(get_libdir)/node_modules/${PN}" path shebang
	insinto "${install_dir}"
	doins -r .
	dosym "../$(get_libdir)/node_modules/${PN}/bin/pnpm.cjs" "/usr/bin/pnpm"
	dosym "../$(get_libdir)/node_modules/${PN}/bin/pnpx.cjs" "/usr/bin/pnpx"
	fperms +x "/usr/bin/pnpm" "/usr/bin/pnpx"
	fperms +x "${install_dir}/bin/pnpm.cjs" "${install_dir}/bin/pnpx.cjs"
	fperms +x "${install_dir}/dist/node-gyp-bin/node-gyp"
	fperms +x "${install_dir}/dist/node_modules/node-gyp/bin/node-gyp.js"
}
