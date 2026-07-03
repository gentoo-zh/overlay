# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 autotools
DESCRIPTION="Java bindings for ZeroMQ"
HOMEPAGE="https://zeromq.org/languages/java/"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/zeromq/jzmq.git"
	vcs=git-r3
fi
S="${WORKDIR}/${P}/${PN}-jni"

LICENSE="LGPL-3"
SLOT="0"

DEPEND="net-libs/zeromq
	>=virtual/jre-1.7:*"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	if [[ -e configure.in ]]; then
		mv configure.in configure.ac || die
	fi
	eautoreconf
}

src_configure() {
	PATH=/etc/java-config-2/current-system-vm/bin:$PATH
	PKG_CONFIG=/usr/lib64/pkgconfig/
	econf
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	rm -f "${ED}"/usr/share/doc/${PF}/{README,ChangeLog} || die
	dodoc ../README.md ../Changelog.md || die "dodoc failed"
}
