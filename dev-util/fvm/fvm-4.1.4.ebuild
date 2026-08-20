# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit wrapper

DESCRIPTION="Flutter Version Management"
HOMEPAGE="https://github.com/leoafarias/fvm https://fvm.app"
# cookbook: https://lingchengling.feishu.cn/docx/McWLdmV2Zo8xSlx6bPUc0wF7ntc
SRC_URI="
	https://github.com/leoafarias/fvm/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-pubcache.tar.xz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="dev-lang/dart"
DEPEND="${RDEPEND}"

src_compile() {
	export PUB_CACHE=pubcache
	dart --disable-analytics
	dart pub get --offline
	dart compile aot-snapshot -o bin/fvm.snapshot bin/main.dart
}

src_install() {
	insinto /usr/$(get_libdir)
	doins bin/fvm.snapshot
	make_wrapper fvm "/usr/bin/dartaotruntime /usr/$(get_libdir)/fvm.snapshot"
}
