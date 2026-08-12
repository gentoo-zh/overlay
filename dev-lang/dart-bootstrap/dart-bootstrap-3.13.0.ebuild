# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Binary bootstrap package for dev-lang/dart"
HOMEPAGE="https://dart.dev https://github.com/dart-lang/sdk"
SRC_URI="
	amd64? (
		https://storage.googleapis.com/dart-archive/channels/stable/release/${PV}/sdk/dartsdk-linux-x64-release.zip
			-> dartsdk-${PV}-amd64.zip
	)
"

S="${WORKDIR}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="-* ~amd64"

RDEPEND="sys-libs/glibc"
BDEPEND="app-arch/unzip"

RESTRICT="strip"
QA_PREBUILT="
	usr/lib/dart-bootstrap/bin/dart
	usr/lib/dart-bootstrap/bin/dartaotruntime
	usr/lib/dart-bootstrap/bin/dartaotruntime_asan
	usr/lib/dart-bootstrap/bin/dartaotruntime_msan
	usr/lib/dart-bootstrap/bin/dartaotruntime_tsan
	usr/lib/dart-bootstrap/bin/dartvm
	usr/lib/dart-bootstrap/bin/snapshots/*.snapshot
	usr/lib/dart-bootstrap/bin/utils/gen_snapshot
	usr/lib/dart-bootstrap/bin/utils/wasm-opt
"

src_install() {
	dodir /usr/lib
	mv dart-sdk "${ED}/usr/lib/dart-bootstrap" || die
}
