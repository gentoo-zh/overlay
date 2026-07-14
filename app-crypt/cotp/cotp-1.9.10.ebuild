EAPI=8

CRATES=""
RUST_MIN_VER="1.88.0"

inherit cargo

DESCRIPTION="command-line TOTP/HOTP authenticator app"
HOMEPAGE="https://github.com/replydev/cotp"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/replydev/cotp.git"
else
	SRC_URI="
		https://github.com/replydev/cotp/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/huaji2369/ebuild-crate-dist-replydev-cotp/releases/download/v${PV}/${P}-crates.tar.xz
		${CARGO_CRATE_URIS}
	"
	KEYWORDS="~amd64 ~arm64"
fi
LICENSE="GPL-3+"
# Dependent crate licenses
LICENSE+="
	Apache-2.0
	BSD-2
	BSD
	Boost-1.0
	ISC
	MIT
	MPL-2.0
	Unicode-3.0
	Unicode-DFS-2016
	WTFPL-2
	ZLIB
"
SLOT="0"
IUSE="converter"
RDEPEND="
	x11-libs/libxcb
	x11-libs/libxkbcommon
"
DEPEND="${RDEPEND}"

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		git-r3_src_unpack
		cargo_live_src_unpack
	else
		cargo_src_unpack
	fi
}

src_install() {
	cargo_src_install
	use converter && (
		insinto "/usr/share/${P}/converters/"
		doins -r converters/
	)
}
