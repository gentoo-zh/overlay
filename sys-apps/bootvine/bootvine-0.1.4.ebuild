# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.91.0"

inherit cargo systemd

DESCRIPTION="Boot and shutdown progress for systemd or OpenRC, as a dependency tree"
HOMEPAGE="https://codeberg.org/wvhulle/bootvine"
SRC_URI="
	https://github.com/gentoo-zh-drafts/bootvine/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/bootvine/releases/download/v${PV}/${P}-crates.tar.xz
"

# The mirror's tag carries the upstream tree plus its injected dist workflow; build
# in the bootvine workspace member so the scripted-demos and xtask members are not
# built.
S="${WORKDIR}/${P}/bootvine"

LICENSE="GPL-3+"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 ISC LGPL-2.1+ MIT Unicode-3.0 Unicode-DFS-2016
	Unlicense WTFPL-2 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+openrc systemd"
REQUIRED_USE="|| ( systemd openrc )"

# The systemd feature links libdbus and libsystemd; the openrc feature is pure Rust.
DEPEND="
	systemd? (
		>=sys-apps/dbus-1.6
		>=sys-apps/systemd-246:=
	)
"
RDEPEND="${DEPEND}"

BDEPEND="
	systemd? ( virtual/pkgconfig )
"

# rustc takes LDFLAGS via cargo.eclass's RUSTFLAGS but not the full CFLAGS set,
# so the binary would otherwise trip portage's "Files built without respecting
# CFLAGS" install notice.
QA_FLAGS_IGNORED="usr/bin/bootvine"

src_configure() {
	local myfeatures=(
		$(usev systemd)
		$(usev openrc)
	)

	# Upstream defaults to the systemd feature; drop it so the feature list
	# above alone decides the wiring.
	cargo_src_configure --no-default-features
}

src_install() {
	cargo_src_install

	local files="${S}/system-files"

	if use systemd; then
		systemd_dounit "${files}"/systemd/bootvine.service
		systemd_dounit "${files}"/systemd/bootvine-shutdown.service
		insinto /usr/lib/systemd/system/systemd-hibernate-resume.service.d
		doins "${files}"/systemd/systemd-hibernate-resume.service.d/bootvine.conf

		# Dracut module for the initrd-stage display; it pulls the systemd
		# units into the initramfs, so it is meaningless without the feature.
		exeinto /usr/lib/dracut/modules.d/90bootvine
		doexe "${files}"/dracut/90bootvine/module-setup.sh
	fi

	if use openrc; then
		doinitd "${files}"/openrc/bootvine
	fi
}

src_test() {
	# The '--' keeps cargo_src_test's splitter from treating '-p' as a skip filter.
	# The systemd feature belongs to bootvine, so every tested member must be
	# selected in one invocation for the feature to resolve.
	if use systemd; then
		cargo_src_test -p bootvine -p bootvine-screen -p bootvine-openrc-link -p bootvine-systemd-link --
	else
		cargo_src_test -p bootvine -p bootvine-screen -p bootvine-openrc-link --
	fi
}
